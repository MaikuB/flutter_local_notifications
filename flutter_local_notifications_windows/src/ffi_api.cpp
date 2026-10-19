#include <windows.h>  // <-- This must be the first Windows header
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Data.Xml.Dom.h>

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
  NativePlugin* plugin, char* appName, char* aumId, char* guid, char* iconPath, char* groupName,
  NativeNotificationCallback callback
) {
  string icon;
  if (iconPath != nullptr) icon = string(iconPath);
  const auto didRegister = plugin->registerApp(aumId, appName, guid, icon, callback);
  if (!didRegister) return false;
  plugin->hasIdentity = hasPackageIdentity();
  plugin->aumid = winrt::to_hstring(aumId);
  plugin->group = winrt::to_hstring(groupName);
  plugin->notifier = plugin->hasIdentity
    ? ToastNotificationManager::CreateToastNotifier()
    : ToastNotificationManager::CreateToastNotifier(plugin->aumid);
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
  if (!plugin->hasIdentity) notification.Group(plugin->group);
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
  if (!plugin->hasIdentity) notification.Group(plugin->group);
  plugin->notifier.value().AddToSchedule(notification);
  return true;
}

NativeUpdateResult updateNotification(NativePlugin* plugin, int id, NativeStringMap bindings) {
  if (!plugin->isReady) return failed;
  const auto tag = winrt::to_hstring(id);
  const auto data = dataFromMap(bindings);
  const auto result = plugin->hasIdentity
    ? plugin->notifier.value().Update(data, tag)
    : plugin->notifier.value().Update(data, tag, plugin->group);
  return (NativeUpdateResult) result;
}

void cancelAll(NativePlugin* plugin) {
  if (!plugin->isReady) return;
  if (plugin->hasIdentity) {
    ToastNotificationManager::History().Clear();
  } else {
    ToastNotificationManager::History().Clear(plugin->aumid);
  }
  for (const auto notification : plugin->notifier.value().GetScheduledToastNotifications()) {
    plugin->notifier.value().RemoveFromSchedule(notification);
  }
}

void cancelNotification(NativePlugin* plugin, int id) {
  if (!plugin->isReady) return;
  const auto tag = winrt::to_hstring(id);
  try {
    const auto history = ToastNotificationManager::History();
    if (plugin->hasIdentity)
      history.Remove(tag);
    else
      history.Remove(tag, plugin->group, plugin->aumid);
  } catch (winrt::hresult_error&) {
    // Toast not found
  }
  for (const auto notification : plugin->notifier.value().GetScheduledToastNotifications()) {
    if (notification.Tag() == tag) {
      plugin->notifier.value().RemoveFromSchedule(notification);
      return;
    }
  }
}

NativeNotificationDetails* getActiveNotifications(NativePlugin* plugin, int* size) {
  // TODO: Get more details here
  *size = 0;
  if (!plugin->isReady) return nullptr;
  try {
    const auto history = ToastNotificationManager::History();
    const auto active =
      plugin->hasIdentity ? history.GetHistory() : history.GetHistory(plugin->aumid);
    const auto result = new NativeNotificationDetails[active.Size()];
    for (const auto notification : active) {
      try {
        const auto tag = winrt::to_string(notification.Tag());
        size_t parsed = 0;
        const auto id = std::stoi(tag, &parsed);
        if (parsed != tag.size()) continue;
        result[*size].id = id;
        (*size)++;
      } catch (const std::exception&) {
        // A different plugin wrote this notification, ignore it
      }
    }
    return result;
  } catch (const winrt::hresult_error&) {
    *size = 0;
    return nullptr;
  }
}

NativeNotificationDetails* getPendingNotifications(NativePlugin* plugin, int* size) {
  // TODO: Get more details here
  if (!plugin->isReady) {
    *size = 0;
    return nullptr;
  }
  const auto pending = plugin->notifier.value().GetScheduledToastNotifications();
  *size = pending.Size();
  const auto result = new NativeNotificationDetails[*size];
  int index = 0;
  for (const auto notification : pending) {
    const auto tag = notification.Tag();
    const auto tagStr = winrt::to_string(tag);
    const auto tagInt = std::stoi(tagStr);
    result[index++].id = tagInt;
  }
  return result;
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
