#include <windows.h>  // <-- This must be the first Windows header
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Data.Xml.Dom.h>

#include "ffi_api.h"
#include "plugin.hpp"
#include "utils.hpp"

using winrt::Windows::Data::Xml::Dom::XmlDocument;

NativePlugin* createPlugin() {
  return reinterpret_cast<NativePlugin*>(new WinRTPlugin());
}

void disposePlugin(NativePlugin* plugin) {
  delete reinterpret_cast<WinRTPlugin*>(plugin);
}

int init(NativePlugin* plugin, char* appName, char* aumId, char* guid, char* iconPath, NativeNotificationCallback callback) {
  const auto ptr = reinterpret_cast<WinRTPlugin*>(plugin);
  // TODO: Register the callback here
  string icon;
  if (iconPath != nullptr) icon = string(iconPath);
  const auto didRegister = ptr->registerApp(aumId, appName, guid, icon, callback);
  if (!didRegister) return false;
  const auto identity = ptr->checkIdentity();
  if (!identity.has_value()) return false;
  ptr->hasIdentity = identity.value();
  ptr->aumid = winrt::to_hstring(aumId);
  ptr->notifier = ptr->hasIdentity
    ? ToastNotificationManager::CreateToastNotifier()
    : ToastNotificationManager::CreateToastNotifier(ptr->aumid);
  ptr->history = ToastNotificationManager::History();
  ptr->isReady = true;
  return true;
}

int showNotification(NativePlugin* plugin, int id, char* xml, NativeStringMap bindings) {
  const auto ptr = reinterpret_cast<WinRTPlugin*>(plugin);
  if (!ptr->isReady) return false;
  XmlDocument doc;
  try { doc.LoadXml(winrt::to_hstring(xml)); }
  catch (winrt::hresult_error error) { return false; }
  ToastNotification notification(doc);
  const auto data = dataFromMap(bindings);
  notification.Tag(winrt::to_hstring(id));
  notification.Data(data);
  ptr->notifier.value().Show(notification);
  return true;
}

int scheduleNotification(NativePlugin* plugin, int id, char* xml, int time) {
  const auto ptr = reinterpret_cast<WinRTPlugin*>(plugin);
  if (!ptr->isReady) return false;
  XmlDocument doc;
  try { doc.LoadXml(winrt::to_hstring(xml)); }
  catch (winrt::hresult_error error) { return false; }
  ScheduledToastNotification notification(doc, winrt::clock::from_time_t(time));
  notification.Tag(winrt::to_hstring(id));
  ptr->notifier.value().AddToSchedule(notification);
  return true;
}

NativeUpdateResult updateNotification(NativePlugin* plugin, int id, NativeStringMap bindings) {
  const auto ptr = reinterpret_cast<WinRTPlugin*>(plugin);
  if (!ptr->isReady) return NativeUpdateResult::failed;
  const auto tag = winrt::to_hstring(id);
  const auto data = dataFromMap(bindings);
  const auto result = ptr->notifier.value().Update(data, tag);
  return (NativeUpdateResult) result;
}

void cancelAll(NativePlugin* plugin) {
  const auto ptr = reinterpret_cast<WinRTPlugin*>(plugin);
  if (!ptr->isReady) return;
  if (ptr->hasIdentity) {
    ptr->history.value().Clear();
  } else {
    ptr->history.value().Clear(ptr->aumid);
  }
  for (const auto notification : ptr->notifier.value().GetScheduledToastNotifications()) {
    ptr->notifier.value().RemoveFromSchedule(notification);
  }
}

void cancelNotification(NativePlugin* plugin, int id) {
  const auto ptr = reinterpret_cast<WinRTPlugin*>(plugin);
  if (!ptr->isReady) return;
  const auto tag = winrt::to_hstring(id);
  if (ptr->hasIdentity) ptr->history.value().Remove(tag);
  for (const auto notification : ptr->notifier.value().GetScheduledToastNotifications()) {
    if (notification.Tag() == tag) {
      ptr->notifier.value().RemoveFromSchedule(notification);
      return;
    }
  }
}

NativeNotificationDetails* getActiveNotifications(NativePlugin* plugin, int* size) {
  // TODO: Get more details here
  const auto ptr = reinterpret_cast<WinRTPlugin*>(plugin);
  if (!ptr->isReady || !ptr->hasIdentity) { *size = 0; return nullptr; }
  const auto active = ptr->history.value().GetHistory();
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
  const auto ptr = reinterpret_cast<WinRTPlugin*>(plugin);
  if (!ptr->isReady) { *size = 0; return nullptr; }
  const auto pending = ptr->notifier.value().GetScheduledToastNotifications();
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

void freeDetailsArray(NativeNotificationDetails* ptr) {
  delete[] ptr;
}

void freeLaunchDetails(NativeLaunchDetails details) {
  if (details.payload != nullptr) delete[] details.payload;
  for (int index = 0; index < details.data.size; index++) {
    const auto pair = details.data.entries[index];
    delete pair.key;
    delete pair.value;
  }
  if (details.data.entries != nullptr) delete[] details.data.entries;
}
