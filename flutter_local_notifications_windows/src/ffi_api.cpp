#include <windows.h>  // <-- This must be the first Windows header
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Data.Xml.Dom.h>

#include "ffi_api.h"
#include "plugin.hpp"
#include "utils.hpp"

using winrt::Windows::Data::Xml::Dom::XmlDocument;

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
  const auto identity = plugin->checkIdentity();
  if (!identity.has_value()) return false;
  plugin->hasIdentity = identity.value();
  plugin->aumid = winrt::to_hstring(aumId);
  plugin->notifier = plugin->hasIdentity
    ? ToastNotificationManager::CreateToastNotifier()
    : ToastNotificationManager::CreateToastNotifier(plugin->aumid);
  plugin->history = ToastNotificationManager::History();
  plugin->isReady = true;
  return true;
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

NativeNotificationDetails* getActiveNotifications(NativePlugin* plugin, int* size) {
  // TODO: Get more details here
  if (!plugin->isReady || !plugin->hasIdentity) {
    *size = 0;
    return nullptr;
  }
  const auto active = plugin->history.value().GetHistory();
  *size = active.Size();
  const auto result = new NativeNotificationDetails[*size];
  int index = 0;
  for (const auto notification : active) {
    const auto tag = notification.Tag();
    const auto tagStr = winrt::to_string(tag);
    const auto tagInt = std::stoi(tagStr);
    result[index++].id = tagInt;
  }
  return result;
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

void enableMultithreading() { CoInitializeEx(nullptr, COINIT_MULTITHREADED); }
