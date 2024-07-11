#include <windows.h>  // <-- This must be the first Windows header
#include <appmodel.h>
#include <VersionHelpers.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Data.Xml.Dom.h>

#include "plugin.hpp"
#include "registration.hpp"

using namespace notifications;
using winrt::Windows::Data::Xml::Dom::XmlDocument;

notifications::NativePlugin* pluginPtr = nullptr;

void globalHandleLaunchData(LaunchData data) {
  if (pluginPtr == nullptr) return;
  pluginPtr->handleLaunchData(data);
}

optional<bool> notifications::NativePlugin::checkIdentity() {
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

notifications::NativePlugin::NativePlugin() { }
notifications::NativePlugin::~NativePlugin() { }

void notifications::NativePlugin::handleLaunchData(LaunchData data) {
  auto details = parseLaunchDetails(data);
  this->launchData = data;
  this->callback(details);
}

bool notifications::NativePlugin::init(string appName, string aumid, string guid, optional<string> iconPath, NativeNotificationCallback callback) {
  if (pluginPtr != nullptr) delete pluginPtr;
  pluginPtr = this;
  this->callback = callback;
  this->aumid = winrt::to_hstring(aumid);
  const auto didRegister = RegisterApp(aumid, appName, guid, iconPath, globalHandleLaunchData);
  if (!didRegister) return false;
  const auto identityResult = checkIdentity();
  if (!identityResult.has_value()) return false;
  hasIdentity = identityResult.value();
  notifier = hasIdentity
    ? ToastNotificationManager::CreateToastNotifier()
    : ToastNotificationManager::CreateToastNotifier(this->aumid);
  history = ToastNotificationManager::History();
  return true;
}

bool notifications::NativePlugin::showNotification(int id, string xml, Bindings bindings) {
  if (!notifier.has_value()) return false;
  XmlDocument doc;
  try { doc.LoadXml(winrt::to_hstring(xml)); }
  catch (winrt::hresult_error error) { return false; }
  ToastNotification notification(doc);
  const auto data = dataFromBindings(bindings);
  notification.Tag(winrt::to_hstring(id));
  notification.Data(data);
  notifier.value().Show(notification);
  return true;
}

bool notifications::NativePlugin::scheduleNotification(const int id, const std::string xml, const time_t time) {
  if (!notifier.has_value()) return false;
  XmlDocument doc;
  try { doc.LoadXml(winrt::to_hstring(xml)); }
  catch (winrt::hresult_error error) { return false; }
  ScheduledToastNotification notification(doc, winrt::clock::from_time_t(time));
  notification.Tag(winrt::to_hstring(id));
  notifier.value().AddToSchedule(notification);
  return true;
}

void notifications::NativePlugin::cancelAll() {
  if (!history.has_value() || !notifier.has_value()) return;
  if (hasIdentity) {
    history.value().Clear();
  } else {
    history.value().Clear(aumid);
  }
  const auto allScheduled = notifier.value().GetScheduledToastNotifications();
  for (const auto notification : allScheduled) {
    notifier.value().RemoveFromSchedule(notification);
  }
}

void notifications::NativePlugin::cancelNotification(int id) {
  if (!history.has_value() || !notifier.has_value()) return;
  const auto tag = winrt::to_hstring(id);
  if (hasIdentity) history.value().Remove(tag);
  for (const auto notification : notifier.value().GetScheduledToastNotifications()) {
    if (notification.Tag() == tag) {
      notifier.value().RemoveFromSchedule(notification);
      return;
    }
  }
}

NativeUpdateResult notifications::NativePlugin::updateNotification(int id, Bindings bindings) {
  if (!notifier.has_value()) return NativeUpdateResult::failed;
  const auto tag = winrt::to_hstring(id);
  const auto data = dataFromBindings(bindings);
  return (NativeUpdateResult) notifier.value().Update(data, tag);
}

vector<NativeDetails> notifications::NativePlugin::getActiveNotifications() {
  vector<NativeDetails> result;
  if (!history.has_value() || !hasIdentity) return result;
  for (const auto notification : history.value().GetHistory()) {
    NativeDetails details;
    const auto tag = notification.Tag();
    const auto tagStr = winrt::to_string(tag);
    const auto tagInt = std::stoi(tagStr);
    details.id = tagInt;
    result.emplace_back(details);
  }
  return result;
}

vector<NativeDetails> notifications::NativePlugin::getPendingNotifications() {
  vector<NativeDetails> result;
  if (!notifier.has_value()) return result;
  for (const auto notification : notifier.value().GetScheduledToastNotifications()) {
    NativeDetails details;
    const auto tag = notification.Tag();
    const auto tagStr = winrt::to_string(tag);
    const auto tagInt = std::stoi(tagStr);
    details.id = tagInt;
    result.emplace_back(details);
  }
  return result;
}

