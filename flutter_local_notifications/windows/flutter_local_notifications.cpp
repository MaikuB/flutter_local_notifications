#include <windows.h>
#include <VersionHelpers.h>
#include <appmodel.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Data.Xml.Dom.h>

#include "flutter_local_notifications.h"
#include "methods.h"
#include "utils.h"
#include "registration.h"

using std::string;
using namespace winrt::Windows::Data::Xml::Dom;
using namespace winrt::Windows::UI::Notifications;
using namespace flutter;
using namespace local_notifications;

void FlutterLocalNotifications::RegisterWithRegistrar(PluginRegistrarWindows* registrar) {
  const auto channel = std::make_shared<PluginMethodChannel>(
    registrar->messenger(),
    "dexterous.com/flutter/local_notifications",
    &flutter::StandardMethodCodec::GetInstance()
  );
  auto plugin = std::make_unique<FlutterLocalNotifications>(channel);
  channel->SetMethodCallHandler(
    [pluginPointer = plugin.get()](const auto& call, auto result) {
      pluginPointer->HandleMethodCall(call, std::move(result));
    }
  );
  registrar->AddPlugin(std::move(plugin));
}

FlutterLocalNotifications::FlutterLocalNotifications(std::shared_ptr<PluginMethodChannel> channel) :
  channel(channel) { }

FlutterLocalNotifications::~FlutterLocalNotifications() { }

std::optional<bool> FlutterLocalNotifications::HasIdentity() {
  if (!IsWindows8OrGreater()) return false;
  uint32_t length = 0;
  auto error = GetCurrentPackageFullName(&length, nullptr);
  if (error == APPMODEL_ERROR_NO_PACKAGE) return false;
  else if (error != ERROR_INSUFFICIENT_BUFFER) return std::nullopt;
  PWSTR fullName = (PWSTR) malloc(length * sizeof(*fullName));
  if (fullName == nullptr) return std::nullopt;
  error = GetCurrentPackageFullName(&length, fullName);
  if (error != ERROR_SUCCESS) return std::nullopt;
  free(fullName);
  return true;
}

void FlutterLocalNotifications::HandleMethodCall(
  const FlutterMethodCall& methodCall,
  std::unique_ptr<FlutterMethodResult> result
) {
  const auto& methodName = methodCall.method_name();
  const auto args = std::get_if<FlutterMap>(methodCall.arguments());
  try {
    if (methodName == Method::INITIALIZE) {
      const auto appName = Utils::GetMapValue<string>("appName", args).value();
      const auto aumid = Utils::GetMapValue<string>("aumid", args).value();
      const auto guid = Utils::GetMapValue<string>("guid", args).value();
      const auto iconPath = Utils::GetMapValue<string>("iconPath", args);
      const auto iconColor = Utils::GetMapValue<string>("iconBgColor", args);
      const auto value = Initialize(appName, aumid, guid, iconPath, iconColor);
      result->Success(value);
    } else if (methodName == Method::GET_NOTIFICATION_APP_LAUNCH_DETAILS) {
			auto map = utils->launchData;
			*utils->didLaunchWithNotification = true;

      const auto didLaunch = *(utils->didLaunchWithNotification);
      FlutterMap outerData;
      outerData[std::string("notificationLaunchedApp")] = didLaunch;
      if (didLaunch) {
        auto data = *(utils->launchData);
        outerData[std::string("notificationResponse")] = flutter::EncodableValue(data);
      }
      result->Success(flutter::EncodableValue(outerData));
    } else if (methodName == Method::CANCEL_ALL) {
      CancelAll();
      result->Success();
    } else if (methodName == Method::CANCEL) {
      const auto id = Utils::GetMapValue<int>("id", args).value();
      CancelNotification(id);
      result->Success();
    } else if (methodName == Method::SHOW) {
      const auto id = Utils::GetMapValue<int>("id", args).value();
      const auto xml = Utils::GetMapValue<string>("rawXml", args).value();
      const auto data = Utils::GetMapValue<FlutterMap>("data", args).value();
      const auto success = ShowNotification(id, xml, data);
      if (success) result->Success();
      else result->Error("invalid-xml", "Invalid XML. If you are passing raw XML yourself, try validating it first in the Notifications Visualizer app. If not, please report this as a bug to flutter_local_notifications.");
    } else if (methodName == Method::SCHEDULE_NOTIFICATION) {
      const auto id = Utils::GetMapValue<int>("id", args).value();
      const auto xml = Utils::GetMapValue<string>("rawXml", args).value();
      const auto time = Utils::GetMapValue<int>("time", args).value();
      const auto success = ScheduleNotification(id, xml, time);
      if (success) result->Success();
      else result->Error("invalid-xml", "Invalid XML. If you are passing raw XML yourself, try validating it first in the Notifications Visualizer app. If not, please report this as a bug to flutter_local_notifications.");
    } else if (methodName == Method::GET_ACTIVE_NOTIFICATIONS) {
      FlutterList list;
      GetActiveNotifications(list);
      result->Success(list);
    } else if (methodName == Method::GET_PENDING_NOTIFICATIONS) {
      FlutterList list;
      GetPendingNotifications(list);
      result->Success(list);
    } else if (methodName == Method::UPDATE) {
      const auto id = Utils::GetMapValue<int>("id", args).value();
      const auto data = Utils::GetMapValue<FlutterMap>("data", args).value();
      result->Success(Update(id, data));
    } else {
      result->NotImplemented();
    }
  } catch (std::exception error) {
    result->Error("internal", error.what());
  } catch (winrt::hresult_error error) {
    result->Error(std::to_string(error.code().value), winrt::to_string(error.message()));
  } catch (...) {
    result->Error("internal", "An internal error occurred");
  }
}

bool FlutterLocalNotifications::Initialize(
  const std::string& appName,
  const std::string& aumid,
  const std::string& guid,
  const std::optional<std::string>& iconPath,
  const std::optional<std::string>& iconColor
) {
  _aumid = winrt::to_hstring(aumid);

  FlutterMap launchDetails;
  bool didLaunchWithNotifications = false;
  RegistrationUtils rawUtils;
  rawUtils.channel = channel;
  rawUtils.didLaunchWithNotification = std::make_shared<bool>(didLaunchWithNotifications);
  rawUtils.launchData = std::make_shared<FlutterMap>(launchDetails);
  utils = std::make_shared<RegistrationUtils>(rawUtils);

  const auto didRegister = RegisterApp(aumid, appName, guid, iconPath, iconColor, utils);
  if (!didRegister) return false;
  const auto identityResult = HasIdentity();
  if (!identityResult.has_value()) return false;
  hasIdentity = identityResult.value();
  toastNotifier = hasIdentity
    ? ToastNotificationManager::CreateToastNotifier()
    : ToastNotificationManager::CreateToastNotifier(_aumid);
  toastHistory = ToastNotificationManager::History();
  return true;
}

NotificationData dataFromMap(const FlutterMap& map) {
  NotificationData data;
  for (const auto pair : map) {
    const auto key = winrt::to_hstring(std::get<string>(pair.first));
    const auto value = winrt::to_hstring(std::get<string>(pair.second));
    data.Values().Insert(key, value);
  }
  return data;
}

bool FlutterLocalNotifications::ShowNotification(const int id, const string& xml, const FlutterMap& args) {
  if (!toastNotifier.has_value()) return false;
  XmlDocument doc;
  try { doc.LoadXml(winrt::to_hstring(xml)); }
  catch (winrt::hresult_error error) { return false; }
  ToastNotification notification(doc);
  const auto data = dataFromMap(args);
  notification.Tag(winrt::to_hstring(id));
  notification.Data(data);
  toastNotifier.value().Show(notification);
  return true;
}

bool FlutterLocalNotifications::ScheduleNotification(const int id, const std::string xml, const int time) {
  if (!toastNotifier.has_value()) return false;
  XmlDocument doc;
  try { doc.LoadXml(winrt::to_hstring(xml)); }
  catch (winrt::hresult_error error) { return false; }
  const time_t time2(time);
  const auto time3 = winrt::clock::from_time_t(time2);
  ScheduledToastNotification notification(doc, time3);
  notification.Tag(winrt::to_hstring(id));
  toastNotifier.value().AddToSchedule(notification);
  return true;
}

void FlutterLocalNotifications::CancelAll() {
  if (!toastHistory.has_value() || !toastNotifier.has_value()) return;
  if (hasIdentity) toastHistory.value().Clear();
  else toastHistory.value().Clear(_aumid);
  for (const auto notification : toastNotifier.value().GetScheduledToastNotifications()) {
    toastNotifier.value().RemoveFromSchedule(notification);
  }
}

void FlutterLocalNotifications::CancelNotification(int id) {
  if (!toastHistory.has_value() || !toastNotifier.has_value()) return;
  const auto tag = winrt::to_hstring(id);
  if (hasIdentity) toastHistory.value().Remove(tag);
  for (const auto notification : toastNotifier.value().GetScheduledToastNotifications()) {
    if (notification.Tag() == tag) {
      toastNotifier.value().RemoveFromSchedule(notification);
      return;
    }
  }
}

void FlutterLocalNotifications::GetActiveNotifications(FlutterList& result) {
  if (!toastHistory.has_value() || !hasIdentity) return;
  for (const auto notification : toastHistory.value().GetHistory()) {
    FlutterMap data;
    const auto tag = notification.Tag();
    const auto tagString = winrt::to_string(tag);
    const auto tagInt = std::stoi(tagString);
    data[std::string("id")] = flutter::EncodableValue(tagInt);
    result.emplace_back(flutter::EncodableValue(data));
  }
}

void FlutterLocalNotifications::GetPendingNotifications(FlutterList& result) {
  if (!toastNotifier.has_value()) return;
  for (const auto notif : toastNotifier.value().GetScheduledToastNotifications()) {
    FlutterMap data;
    const auto tag = notif.Tag();
    const auto tagString = winrt::to_string(tag);
    const auto tagInt = std::stoi(tagString);
    data[std::string("id")] = flutter::EncodableValue(tagInt);
    result.emplace_back(flutter::EncodableValue(data));
  }
}

int FlutterLocalNotifications::Update(const int id, const FlutterMap& map) {
  if (!toastNotifier.has_value()) return 1;
  const auto tag = winrt::to_hstring(id);
  const auto data = dataFromMap(map);
  return (int) toastNotifier.value().Update(data, tag);
}
