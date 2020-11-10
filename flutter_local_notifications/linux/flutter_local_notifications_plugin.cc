#include "include/flutter_local_notifications/flutter_local_notifications_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>
#include <string_view>
#include <string>
#include <cassert>
#include <unordered_map>
#include <utility>

#define FLUTTER_LOCAL_NOTIFICATIONS_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_local_notifications_plugin_get_type(), \
                              FlutterLocalNotificationsPlugin))

namespace {
  enum class IconSource {
    File,
    Bytes,
    Theme,
  };

  enum class RepeatInterval {
    EveryMinute = 60,
    Hourly = EveryMinute * 60,
    Daily = Hourly * 24,
    Weekly = Daily * 7,
  };

  inline constexpr RepeatInterval RepeatIntervalMap[] = {
    RepeatInterval::EveryMinute,
    RepeatInterval::Hourly,
    RepeatInterval::Daily,
    RepeatInterval::Weekly
  };

  enum class DateTimeComponents {
    Time,
    DayOfWeekAndTime,
  };

  template <typename T>
  using TypeIdentity = T;

  enum class ModType {
    Normal,
    NoZero,
  };

  template <ModType UsingModType = ModType::Normal, typename NumT>
  constexpr NumT Mod(NumT a, TypeIdentity<NumT> b) {
    using std::abs;
    b = abs(b);
    const auto result = a % b;
    if (std::conditional_t<UsingModType == ModType::NoZero, std::less_equal<>, std::less<>>{}(result, 0)) {
      return result + b;
    }
    return result;
  }

  GDateTime* GetNextNotifyTime(GDateTime* now, GDateTime* value, DateTimeComponents component) {
    const auto usingTimeZone = g_date_time_get_timezone(now);
    const auto nowTimeStamp = g_date_time_to_unix(now);
    const auto valueTimeStamp = g_date_time_to_unix(value);
    auto diff = valueTimeStamp - nowTimeStamp;
    switch (component)
    {
    default:
      assert(!"Invalid component");
      [[fallthrough]];
    case DateTimeComponents::Time:
      diff = Mod(diff, static_cast<gint64>(RepeatInterval::Daily));
      break;
    case DateTimeComponents::DayOfWeekAndTime:
      diff = Mod(diff, static_cast<gint64>(RepeatInterval::Weekly));
      break;
    }
    g_autoptr(GDateTime) utcResult = g_date_time_new_from_unix_utc(nowTimeStamp + diff);
    return g_date_time_to_timezone(utcResult, usingTimeZone);
  }

  template <typename T>
  class SimpleGPtr {
  public:
    SimpleGPtr() : m_Ptr{} {
    }

    SimpleGPtr(T* ptr) : m_Ptr{ ptr } {
    }

    SimpleGPtr(SimpleGPtr&& other) noexcept : m_Ptr{ std::exchange(other.m_Ptr, nullptr) } {
    }

    SimpleGPtr& operator=(SimpleGPtr&& other) noexcept {
      SimpleGPtr{ std::move(other) }.swap(*this);
      return *this;
    }

    ~SimpleGPtr() {
      if (m_Ptr) {
        g_object_unref(m_Ptr);
      }
    }

    operator T*() const {
      return m_Ptr;
    }

    void swap(SimpleGPtr& other) noexcept {
      std::swap(m_Ptr, other.m_Ptr);
    }

  private:
    T* m_Ptr;
  };

  GIcon* CreateIconFromFlValue(FlValue* v) {
    const auto icon = fl_value_lookup_string(v, "icon");
    const auto source = fl_value_lookup_string(v, "iconSource");
    if (!icon || !source || fl_value_get_type(source) != FL_VALUE_TYPE_INT) {
      return nullptr;
    }

    switch (static_cast<IconSource>(fl_value_get_int(source))) {
    case IconSource::File:
    {
      if (fl_value_get_type(icon) != FL_VALUE_TYPE_STRING) {
        return nullptr;
      }
      const auto iconFilePath = fl_value_get_string(icon);
      const SimpleGPtr iconFile = g_file_new_for_commandline_arg(iconFilePath);
      return g_file_icon_new(iconFile);
    }
    case IconSource::Bytes:
    {
      if (fl_value_get_type(icon) != FL_VALUE_TYPE_UINT8_LIST) {
        return nullptr;
      }
      const auto size = fl_value_get_length(icon);
      const auto data = fl_value_get_uint8_list(icon);
      const SimpleGPtr bytes = g_bytes_new_static(data, size);
      return g_bytes_icon_new(bytes);
    }
    case IconSource::Theme:
    {
      if (fl_value_get_type(icon) != FL_VALUE_TYPE_STRING) {
        return nullptr;
      }
      const auto themeName = fl_value_get_string(icon);
      return g_themed_icon_new(themeName);
    }
    default:
      return nullptr;
    }
  }

  FlMethodResponse* RequiredArgumentAbsentError(std::string methodName, std::string requiredArgName, FlValue* detail = nullptr) {
    methodName += "_error";
    requiredArgName += " is absent, which is required for this operation";
    return FL_METHOD_RESPONSE(fl_method_error_response_new(methodName.data(), requiredArgName.data(), detail));
  }

  FlMethodResponse* RequiredArgumentTypeError(std::string methodName, std::string requiredArgName, FlValue* detail = nullptr) {
    methodName += "_error";
    requiredArgName += " has wrong type, which is required for this operation";
    return FL_METHOD_RESPONSE(fl_method_error_response_new(methodName.data(), requiredArgName.data(), detail));
  }

  FlMethodResponse* OptionalArgument(const char* funcName, const char* argName, FlValue*& arg, FlValueType requiredType) {
    if (arg) {
      const auto type = fl_value_get_type(arg);
      if (type == FL_VALUE_TYPE_NULL) {
        arg = nullptr;
        return nullptr;
      }
      return type == requiredType ? nullptr : RequiredArgumentTypeError(funcName, argName);
    }
    return nullptr;
  }

  FlMethodResponse* RequireArgument(const char* funcName, const char* argName, FlValue* arg, FlValueType requiredType) {
    if (!arg) {
      return RequiredArgumentAbsentError(funcName, argName);
    }
    if (fl_value_get_type(arg) != requiredType) {
      return RequiredArgumentTypeError(funcName, argName);
    }
    return nullptr;
  }

  inline constexpr const char NotificationActionName[] = "flutter-local-notifications-action";
  inline constexpr const char NotificationButtonActionName[] = "flutter-local-notifications-button-action";

  inline constexpr const char NotificationActionBindingName[] = "app.flutter-local-notifications-action";
  inline constexpr const char NotificationButtonActionBindingName[] = "app.fflutter-local-notifications-button-action";
}

#define RequireArg(arg, requiredType) if (const auto resp = ::RequireArgument(__func__, #arg, arg, requiredType)) { return resp; }
#define OptionalArg(arg, requiredType) if (const auto resp = ::OptionalArgument(__func__, #arg, arg, requiredType)) { return resp; }

struct _FlutterLocalNotificationsPlugin {
  GObject parent_instance;

  FlPluginRegistrar* registrar;
  FlMethodChannel* channel;

  GIcon* default_icon;

  // Key: notification id, Value: task id
  std::unordered_map<int64_t, int>* periodic_notification_map;

  GtkWidget* getTopLevel() const {
    const auto view = GTK_WIDGET(fl_plugin_registrar_get_view(registrar));
    const auto topLevel = gtk_widget_get_toplevel(view);
    return topLevel;
  }

  GtkApplication* getApplication() const {
    return gtk_window_get_application(GTK_WINDOW(getTopLevel()));
  }

  std::string getApplicationId() const {
    GValue id = G_VALUE_INIT;
    g_object_get_property(G_OBJECT(getApplication()), "application-id", &id);
    std::string ret = g_value_get_string(&id);
    g_value_unset(&id);
    return ret;
  }

  FlMethodResponse* initialize(FlMethodCall* call) {
    const auto args = fl_method_call_get_args(call);
    if (args && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      const auto defaultIconValue = fl_value_lookup_string(args, "defaultIcon");
      if (defaultIconValue && fl_value_get_type(defaultIconValue) == FL_VALUE_TYPE_MAP) {
        default_icon = CreateIconFromFlValue(defaultIconValue);
      }
    }

    const auto app = getApplication();
    const GActionEntry actionEntries[] = {
      {
        NotificationActionName,
        [](GSimpleAction* action, GVariant* param, gpointer opaque) {
          const SimpleGPtr id = g_variant_get_child_value(param, 0);
          const auto idValue = g_variant_get_int64(id);
          const SimpleGPtr payload = g_variant_get_child_value(param, 1);
          const auto payloadValue = g_variant_get_string(payload, nullptr);

          const auto plugin = static_cast<FlutterLocalNotificationsPlugin*>(opaque);

          const SimpleGPtr arg = fl_value_new_map();
          fl_value_set_string_take(arg, "id", fl_value_new_int(idValue));
          fl_value_set_string_take(arg, "payload", fl_value_new_string(payloadValue));
          fl_method_channel_invoke_method(plugin->channel, "selectNotification", arg, nullptr, nullptr, nullptr);
        },
        "(xs)"
      },
      {
        NotificationButtonActionName,
        [](GSimpleAction* action, GVariant* param, gpointer opaque) {
          const SimpleGPtr id = g_variant_get_child_value(param, 0);
          const auto idValue = g_variant_get_int64(id);
          const SimpleGPtr buttonId = g_variant_get_child_value(param, 1);
          const auto buttonIdValue = g_variant_get_string(buttonId, nullptr);

          const auto plugin = static_cast<FlutterLocalNotificationsPlugin*>(opaque);

          const SimpleGPtr arg = fl_value_new_map();
          fl_value_set_string_take(arg, "id", fl_value_new_int(idValue));
          fl_value_set_string_take(arg, "buttonId", fl_value_new_string(buttonIdValue));
          fl_method_channel_invoke_method(plugin->channel, "selectNotificationButton", arg, nullptr, nullptr, nullptr);
        },
        "(xs)"
      }
    };
    g_action_map_add_action_entries(G_ACTION_MAP(app), actionEntries, std::size(actionEntries), this);
    return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  }

  FlMethodResponse* show(FlMethodCall* call) {
    const auto args = fl_method_call_get_args(call);
    RequireArg(args, FL_VALUE_TYPE_MAP);

    const auto id = fl_value_lookup_string(args, "id");
    RequireArg(id, FL_VALUE_TYPE_INT);
    auto title = fl_value_lookup_string(args, "title");
    OptionalArg(title, FL_VALUE_TYPE_STRING);
    auto body = fl_value_lookup_string(args, "body");
    OptionalArg(body, FL_VALUE_TYPE_STRING);
    const auto payload = fl_value_lookup_string(args, "payload");
    RequireArg(payload, FL_VALUE_TYPE_STRING);
    auto platformSpecifics = fl_value_lookup_string(args, "platformSpecifics");
    OptionalArg(platformSpecifics, FL_VALUE_TYPE_MAP);

    // for periodicallyShow
    auto repeatInterval = fl_value_lookup_string(args, "repeatInterval");
    OptionalArg(repeatInterval, FL_VALUE_TYPE_INT);

    // for zonedSchedule
    auto timeZoneName = fl_value_lookup_string(args, "timeZoneName");
    OptionalArg(timeZoneName, FL_VALUE_TYPE_STRING);

    const auto idValue = fl_value_get_int(id);
    const auto titleValue = title ? fl_value_get_string(title) : "";
    const auto bodyValue = body ? fl_value_get_string(body) : nullptr;
    const auto payloadValue = fl_value_get_string(payload);

    SimpleGPtr notification = g_notification_new(titleValue);
    if (bodyValue) {
      g_notification_set_body(notification, bodyValue);
    }
    g_notification_set_default_action_and_target(notification, NotificationActionBindingName, "(xs)", idValue, payloadValue);

    const auto app = getApplication();

    if (platformSpecifics) {
      const auto icon = fl_value_lookup_string(platformSpecifics, "icon");
      g_autoptr(GIcon) usingIcon = icon && fl_value_get_type(icon) == FL_VALUE_TYPE_MAP ? CreateIconFromFlValue(icon) : nullptr;
      if (!usingIcon) {
        g_object_ref(default_icon);
        usingIcon = default_icon;
      }
      if (usingIcon) {
        g_notification_set_icon(notification, usingIcon);
      }

      const auto buttons = fl_value_lookup_string(platformSpecifics, "buttons");
      if (buttons && fl_value_get_type(buttons) == FL_VALUE_TYPE_LIST) {
        const auto buttonSize = fl_value_get_length(buttons);
        for (std::size_t i = 0; i < buttonSize; ++i) {
          const auto button = fl_value_get_list_value(buttons, i);
          assert(button && fl_value_get_type(button) == FL_VALUE_TYPE_MAP);

          const auto label = fl_value_get_string(fl_value_lookup_string(button, "buttonLabel"));
          const auto buttonId = fl_value_get_string(fl_value_lookup_string(button, "buttonId"));

          g_notification_add_button_with_target(notification, label, NotificationButtonActionBindingName, "(xs)", idValue, buttonId);
        }
      }
    } else {
      if (default_icon) {
        g_notification_set_icon(notification, default_icon);
      }
    }

    auto notificationIdString = "flutter_local_notifications#" + std::to_string(idValue);
    if (repeatInterval) {
      const auto repeatIntervalIndex = fl_value_get_int(repeatInterval);
      if (repeatIntervalIndex < 0 || repeatIntervalIndex >= std::size(RepeatIntervalMap)) {
        return FL_METHOD_RESPONSE(fl_method_error_response_new("show_error", "repeatInterval is not in valid range", nullptr));
      }
      const auto repeatIntervalValue = RepeatIntervalMap[repeatIntervalIndex];
      const auto data = new std::tuple{ G_APPLICATION(app), std::move(notification), std::move(notificationIdString) };
      const auto taskId = g_timeout_add_seconds_full(G_PRIORITY_DEFAULT, static_cast<guint>(repeatIntervalValue), [](gpointer p) -> gboolean {
        const auto& [app, notification, notificationIdString] = *static_cast<decltype(data)>(p);
        g_application_send_notification(app, notificationIdString.data(), notification);
        return TRUE;
      }, static_cast<gpointer>(data), [](gpointer p) {
        delete static_cast<decltype(data)>(p);
      });
      periodic_notification_map->emplace(idValue, taskId);
    } else if (timeZoneName) {
      const auto scheduledDateTime = fl_value_lookup_string(args, "scheduledDateTime");
      RequireArg(scheduledDateTime, FL_VALUE_TYPE_STRING);
      auto matchDateTimeComponents = fl_value_lookup_string(args, "matchDateTimeComponents");
      OptionalArg(matchDateTimeComponents, FL_VALUE_TYPE_INT);

      const auto timeZoneNameValue = fl_value_get_string(timeZoneName);
      const auto scheduledDateTimeValue = fl_value_get_string(scheduledDateTime);
      g_autoptr(GTimeZone) timeZone = g_time_zone_new(timeZoneNameValue);
      g_autoptr(GDateTime) realScheduledDateTime = g_date_time_new_from_iso8601(scheduledDateTimeValue, timeZone);
      assert(realScheduledDateTime);

      const auto now = g_date_time_new_now(timeZone);

      if (matchDateTimeComponents) {
        const auto matchDateTimeComponentsValue = static_cast<DateTimeComponents>(fl_value_get_int(matchDateTimeComponents));
        const auto nextNotifyTime = GetNextNotifyTime(now, realScheduledDateTime, matchDateTimeComponentsValue);
        const auto initialDiff = g_date_time_to_unix(nextNotifyTime) - g_date_time_to_unix(now);
        const auto data = new std::tuple{ G_APPLICATION(app), std::move(notification), std::move(notificationIdString),
          static_cast<guint>(matchDateTimeComponentsValue == DateTimeComponents::Time ? RepeatInterval::Daily : RepeatInterval::Weekly),
          idValue, this };
        const auto taskId = g_timeout_add_seconds(initialDiff, [](gpointer p) -> gboolean {
          const auto& [app, notification, notificationIdString, repeatInterval, id, plugin] = *static_cast<decltype(data)>(p);
          g_application_send_notification(app, notificationIdString.data(), notification);
          // delays may accumulate here
          const auto taskId = g_timeout_add_seconds_full(G_PRIORITY_DEFAULT, repeatInterval, [](gpointer p) -> gboolean {
            [[maybe_unused]] const auto& [app, notification, notificationIdString, unused, unused2, unused3] = *static_cast<decltype(data)>(p);
            g_application_send_notification(app, notificationIdString.data(), notification);
            return TRUE;
          }, p, [](gpointer p) {
            delete static_cast<decltype(data)>(p);
          });
          // possible race condition?
          plugin->periodic_notification_map->insert_or_assign(id, taskId);
          return FALSE;
        }, static_cast<gpointer>(data));
        periodic_notification_map->emplace(idValue, taskId);
      } else {
        const auto diff = g_date_time_to_unix(realScheduledDateTime) - g_date_time_to_unix(now);
        // this should be guaranteed by flutter side
        assert(diff > 0);
        const auto data = new std::tuple{ G_APPLICATION(app), std::move(notification), std::move(notificationIdString) };
        g_timeout_add_seconds_full(G_PRIORITY_DEFAULT, diff, [](gpointer p) -> gboolean {
          const auto& [app, notification, notificationIdString] = *static_cast<decltype(data)>(p);
          g_application_send_notification(app, notificationIdString.data(), notification);
          return FALSE;
        }, static_cast<gpointer>(data), [](gpointer p) {
          delete static_cast<decltype(data)>(p);
        });
      }
    } else {
      g_application_send_notification(G_APPLICATION(app), notificationIdString.data(), notification);
    }
    return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  }

  FlMethodResponse* cancel(FlMethodCall* call) {
    const auto args = fl_method_call_get_args(call);
    RequireArg(args, FL_VALUE_TYPE_INT);
    const auto id = fl_value_get_int(args);

    const auto app = getApplication();
    g_application_withdraw_notification(G_APPLICATION(app), ("flutter_local_notifications#" + std::to_string(id)).data());
    return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  }

  FlMethodResponse* cancelPeriodicNotification(FlMethodCall* call) {
    const auto args = fl_method_call_get_args(call);
    RequireArg(args, FL_VALUE_TYPE_INT);
    const auto id = fl_value_get_int(args);

    const auto app = getApplication();
    const auto iter = periodic_notification_map->find(id);
    if (iter == periodic_notification_map->end()) {
      return FL_METHOD_RESPONSE(fl_method_error_response_new("cancelPeriodicNotification_error", "id does not refer to a valid periodic notification", nullptr));
    }
    g_source_remove(iter->second);
    g_application_withdraw_notification(G_APPLICATION(app), ("flutter_local_notifications#" + std::to_string(id)).data());
    periodic_notification_map->erase(iter);
    return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  }
};

G_DEFINE_TYPE(FlutterLocalNotificationsPlugin, flutter_local_notifications_plugin, g_object_get_type())

static void flutter_local_notifications_plugin_dispose(GObject* object) {
  const auto plugin = FLUTTER_LOCAL_NOTIFICATIONS_PLUGIN(object);
  if (plugin->default_icon) {
    g_object_unref(plugin->default_icon);
  }
  g_object_unref(plugin->channel);
  g_object_unref(plugin->registrar);
  delete plugin->periodic_notification_map;

  G_OBJECT_CLASS(flutter_local_notifications_plugin_parent_class)->dispose(object);
}

static void flutter_local_notifications_plugin_class_init(FlutterLocalNotificationsPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = flutter_local_notifications_plugin_dispose;
}

static void flutter_local_notifications_plugin_init(FlutterLocalNotificationsPlugin* self) {
  self->registrar = nullptr;
  self->channel = nullptr;
  self->default_icon = nullptr;
  self->periodic_notification_map = new std::unordered_map<int64_t, int>();
}

namespace {
  void flutter_local_notifications_plugin_handle_method_call(
    FlutterLocalNotificationsPlugin* self,
    FlMethodCall* call) {
    g_autoptr(FlMethodResponse) response = nullptr;

    const std::string_view method = fl_method_call_get_name(call);
    if (method == "initialize") {
      response = self->initialize(call);
    } else if (method == "show") {
      response = self->show(call);
    } else if (method == "cancel") {
      response = self->cancel(call);
    } else if (method == "cancelPeriodicNotification") {
      response = self->cancelPeriodicNotification(call);
    } else {
      response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    }

    fl_method_call_respond(call, response, nullptr);
  }

  void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                            gpointer user_data) {
    FlutterLocalNotificationsPlugin* plugin = FLUTTER_LOCAL_NOTIFICATIONS_PLUGIN(user_data);
    flutter_local_notifications_plugin_handle_method_call(plugin, method_call);
  }
}

void flutter_local_notifications_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlutterLocalNotificationsPlugin* plugin = FLUTTER_LOCAL_NOTIFICATIONS_PLUGIN(
      g_object_new(flutter_local_notifications_plugin_get_type(), nullptr));

  const auto codec = fl_standard_method_codec_new();
  const auto channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "dexterous.com/flutter/local_notifications",
                            FL_METHOD_CODEC(codec));
  g_object_ref(registrar);
  plugin->registrar = registrar;
  plugin->channel = channel;
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
