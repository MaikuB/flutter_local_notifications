#include <windows.h>  // <-- This must be the first Windows header
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Data.Xml.Dom.h>

#include <charconv>
#include <vector>

#include "ffi_api.h"
#include "plugin.hpp"
#include "utils.hpp"

using winrt::Windows::Data::Xml::Dom::XmlDocument;

bool hasPackageIdentity() {
  if (!IsWindows8OrGreater()) return false;
  uint32_t length = 0;
  int error = GetCurrentPackageFullName(&length, nullptr);
  return error != APPMODEL_ERROR_NO_PACKAGE;
}

NativePlugin* createPlugin() { return new NativePlugin(); }

void disposePlugin(NativePlugin* plugin) { delete plugin; }

bool init(
  NativePlugin* plugin, char* appName, char* aumId, char* guid, char* iconPath,
  NativeNotificationCallback callback
) {
  string icon;
  if (iconPath != nullptr) icon = string(iconPath);
  const auto didRegister = plugin->registerApp(aumId, appName, guid, icon, callback);
  if (!didRegister) return false;
  plugin->hasIdentity = hasPackageIdentity();
  plugin->aumid = winrt::to_hstring(aumId);
  plugin->notifier = plugin->hasIdentity
    ? ToastNotificationManager::CreateToastNotifier()
    : ToastNotificationManager::CreateToastNotifier(plugin->aumid);
  plugin->history = ToastNotificationManager::History();
  plugin->isReady = true;
  return true;
}

bool isValidXml(char* xml) {
  XmlDocument doc = XmlDocument();
  try {
    doc.LoadXml(winrt::to_hstring(xml));
    return true;
  } catch (winrt::hresult_error error) {
    return false;
  }
}

bool showNotification(NativePlugin* plugin, int id, char* xml, NativeStringMap bindings) {
  if (!plugin->isReady) return false;
  XmlDocument doc;
  try {
    doc.LoadXml(winrt::to_hstring(xml));
  } catch (winrt::hresult_error error) {
    return false;
  }
  ToastNotification notification(doc);
  const auto data = dataFromMap(bindings);
  notification.Tag(winrt::to_hstring(id));
  notification.Data(data);
  plugin->notifier.value().Show(notification);
  return true;
}

bool scheduleNotification(NativePlugin* plugin, int id, char* xml, int time) {
  if (!plugin->isReady) return false;
  XmlDocument doc;
  try {
    doc.LoadXml(winrt::to_hstring(xml));
  } catch (winrt::hresult_error error) {
    return false;
  }
  ScheduledToastNotification notification(doc, winrt::clock::from_time_t(time));
  notification.Tag(winrt::to_hstring(id));
  plugin->notifier.value().AddToSchedule(notification);
  return true;
}

NativeUpdateResult updateNotification(NativePlugin* plugin, int id, NativeStringMap bindings) {
  if (!plugin->isReady) return NativeUpdateResult::failed;
  const auto tag = winrt::to_hstring(id);
  const auto data = dataFromMap(bindings);
  const auto result = plugin->notifier.value().Update(data, tag);
  return (NativeUpdateResult) result;
}

void cancelAll(NativePlugin* plugin) {
  if (!plugin->isReady) return;
  if (plugin->hasIdentity) {
    plugin->history.value().Clear();
  } else {
    plugin->history.value().Clear(plugin->aumid);
  }
  for (const auto notification : plugin->notifier.value().GetScheduledToastNotifications()) {
    plugin->notifier.value().RemoveFromSchedule(notification);
  }
}

void cancelNotification(NativePlugin* plugin, int id) {
  if (!plugin->isReady) return;
  const auto tag = winrt::to_hstring(id);
  if (plugin->hasIdentity) plugin->history.value().Remove(tag);
  for (const auto notification : plugin->notifier.value().GetScheduledToastNotifications()) {
    if (notification.Tag() == tag) {
      plugin->notifier.value().RemoveFromSchedule(notification);
      return;
    }
  }
}

// Toasts shown by other code under the same app id can carry any tag; skip those
// instead of letting std::stoi throw across the FFI boundary.
template <typename Notifications>
static NativeNotificationDetails* copyNotificationIds(
  const Notifications& notifications, int* size
) {
  std::vector<int> ids;
  for (const auto notification : notifications) {
    const auto tag = winrt::to_string(notification.Tag());
    int id = 0;
    const auto end = tag.data() + tag.size();
    const auto parsed = std::from_chars(tag.data(), end, id);
    if (parsed.ec == std::errc() && parsed.ptr == end) ids.push_back(id);
  }
  *size = static_cast<int>(ids.size());
  if (ids.empty()) return nullptr;
  const auto result = new NativeNotificationDetails[ids.size()];
  for (size_t index = 0; index < ids.size(); index++) result[index].id = ids[index];
  return result;
}

NativeNotificationDetails* getActiveNotifications(NativePlugin* plugin, int* size) {
  // TODO: Get more details here
  if (!plugin->isReady || !plugin->hasIdentity) {
    *size = 0;
    return nullptr;
  }
  return copyNotificationIds(plugin->history.value().GetHistory(), size);
}

NativeNotificationDetails* getPendingNotifications(NativePlugin* plugin, int* size) {
  // TODO: Get more details here
  if (!plugin->isReady) {
    *size = 0;
    return nullptr;
  }
  return copyNotificationIds(plugin->notifier.value().GetScheduledToastNotifications(), size);
}

void freeDetailsArray(NativeNotificationDetails* ptr) { delete[] ptr; }

void freeLaunchDetails(NativeLaunchDetails details) {
  if (details.payload != nullptr) delete[] details.payload;
  for (int index = 0; index < details.data.size; index++) {
    const auto pair = details.data.entries[index];
    delete pair.key;
    delete pair.value;
  }
  if (details.data.entries != nullptr) delete[] details.data.entries;
}
