#include "include/flutter_local_notifications/flutter_local_notifications_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>
#include <string_view>
#include <string>
#include <cassert>

#define FLUTTER_LOCAL_NOTIFICATIONS_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_local_notifications_plugin_get_type(), \
                              FlutterLocalNotificationsPlugin))

namespace {
  enum class IconSource {
    File,
    Bytes,
    Theme,
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
      g_autoptr(GFile) iconFile = g_file_new_for_commandline_arg(iconFilePath);
      return g_file_icon_new(iconFile);
    }
    case IconSource::Bytes:
    {
      if (fl_value_get_type(icon) != FL_VALUE_TYPE_UINT8_LIST) {
        return nullptr;
      }
      const auto size = fl_value_get_length(icon);
      const auto data = fl_value_get_uint8_list(icon);
      g_autoptr(GBytes) bytes = g_bytes_new_static(data, size);
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

  bool CheckArgument(FlValue* arg, FlValueType requiredType) {
    return arg && fl_value_get_type(arg) == requiredType;
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

struct _FlutterLocalNotificationsPlugin {
  GObject parent_instance;

  FlPluginRegistrar* registrar;
  FlMethodChannel* channel;

  GIcon* default_icon;

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
          g_autoptr(GVariant) id = g_variant_get_child_value(param, 0);
          const auto idValue = g_variant_get_int64(id);
          g_autoptr(GVariant) payload = g_variant_get_child_value(param, 1);
          const auto payloadValue = g_variant_get_string(payload, nullptr);

          const auto plugin = static_cast<FlutterLocalNotificationsPlugin*>(opaque);

          g_autoptr(FlValue) arg = fl_value_new_map();
          fl_value_set_string_take(arg, "id", fl_value_new_int(idValue));
          fl_value_set_string_take(arg, "payload", fl_value_new_string(payloadValue));
          fl_method_channel_invoke_method(plugin->channel, "selectNotification", arg, nullptr, nullptr, nullptr);
        },
        "(xs)"
      },
      {
        NotificationButtonActionName,
        [](GSimpleAction* action, GVariant* param, gpointer opaque) {
          g_autoptr(GVariant) id = g_variant_get_child_value(param, 0);
          const auto idValue = g_variant_get_int64(id);
          g_autoptr(GVariant) buttonId = g_variant_get_child_value(param, 1);
          const auto buttonIdValue = g_variant_get_string(buttonId, nullptr);

          const auto plugin = static_cast<FlutterLocalNotificationsPlugin*>(opaque);

          g_autoptr(FlValue) arg = fl_value_new_map();
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
    const auto title = fl_value_lookup_string(args, "title");
    const auto body = fl_value_lookup_string(args, "body");
    const auto payload = fl_value_lookup_string(args, "payload");
    RequireArg(payload, FL_VALUE_TYPE_STRING);
    const auto platformSpecifics = fl_value_lookup_string(args, "platformSpecifics");

    const auto idValue = fl_value_get_int(id);
    const auto titleValue = CheckArgument(title, FL_VALUE_TYPE_STRING) ? fl_value_get_string(title) : "";
    const auto bodyValue = CheckArgument(body, FL_VALUE_TYPE_STRING) ? fl_value_get_string(body) : nullptr;
    const auto payloadValue = fl_value_get_string(payload);

    g_autoptr(GNotification) notification = g_notification_new(titleValue);
    if (bodyValue) {
      g_notification_set_body(notification, bodyValue);
    }
    g_notification_set_default_action_and_target(notification, NotificationActionBindingName, "(xs)", idValue, payloadValue);

    const auto app = getApplication();

    if (platformSpecifics && fl_value_get_type(platformSpecifics) == FL_VALUE_TYPE_MAP) {
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

    g_application_send_notification(G_APPLICATION(app), ("flutter_local_notifications#" + std::to_string(idValue)).data(), notification);
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

  G_OBJECT_CLASS(flutter_local_notifications_plugin_parent_class)->dispose(object);
}

static void flutter_local_notifications_plugin_class_init(FlutterLocalNotificationsPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = flutter_local_notifications_plugin_dispose;
}

static void flutter_local_notifications_plugin_init(FlutterLocalNotificationsPlugin* self) {
  self->registrar = nullptr;
  self->channel = nullptr;
  self->default_icon = nullptr;
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
