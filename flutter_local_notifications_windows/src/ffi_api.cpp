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
  NativePlugin* plugin, char* appName, char* aumId, char* guid, char* iconPath,
  NativeNotificationCallback callback
) {
  // The caller's strings live in a Dart arena that is freed when this returns, so
  // everything the worker needs is copied before queueing.
  const string name(appName);
  const string aumid(aumId);
  const string clsid(guid);
  string icon;
  if (iconPath != nullptr) icon = string(iconPath);
  plugin->worker.post([plugin, name, aumid, clsid, icon, callback] {
    if (!plugin->registerApp(aumid, name, clsid, icon, callback)) return;
    plugin->hasIdentity = hasPackageIdentity();
    plugin->aumid = winrt::to_hstring(aumid);
    plugin->notifier = plugin->hasIdentity
      ? ToastNotificationManager::CreateToastNotifier()
      : ToastNotificationManager::CreateToastNotifier(plugin->aumid);
    plugin->history = ToastNotificationManager::History();
    plugin->isReady = true;
  });
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
  const string xmlCopy(xml);
  const auto bindingsCopy = copyMap(bindings);
  plugin->worker.post([plugin, id, xmlCopy, bindingsCopy] {
    if (!plugin->isReady) return;
    XmlDocument doc;
    try {
      doc.LoadXml(winrt::to_hstring(xmlCopy));
    } catch (winrt::hresult_error error) {
      return;
    }
    ToastNotification notification(doc);
    notification.Tag(winrt::to_hstring(id));
    notification.Data(dataFromPairs(bindingsCopy));
    plugin->notifier.value().Show(notification);
  });
  return true;
}

bool scheduleNotification(NativePlugin* plugin, int id, char* xml, int time) {
  const string xmlCopy(xml);
  plugin->worker.post([plugin, id, xmlCopy, time] {
    if (!plugin->isReady) return;
    XmlDocument doc;
    try {
      doc.LoadXml(winrt::to_hstring(xmlCopy));
    } catch (winrt::hresult_error error) {
      return;
    }
    ScheduledToastNotification notification(doc, winrt::clock::from_time_t(time));
    notification.Tag(winrt::to_hstring(id));
    plugin->notifier.value().AddToSchedule(notification);
  });
  return true;
}

NativeUpdateResult updateNotification(NativePlugin* plugin, int id, NativeStringMap bindings) {
  NativeUpdateResult result = NativeUpdateResult::failed;
  plugin->worker.invoke([plugin, id, bindings, &result] {
    if (!plugin->isReady) return;
    const auto tag = winrt::to_hstring(id);
    const auto data = dataFromMap(bindings);
    result = (NativeUpdateResult) plugin->notifier.value().Update(data, tag);
  });
  return result;
}

void cancelAll(NativePlugin* plugin) {
  plugin->worker.post([plugin] {
  if (!plugin->isReady) return;
  if (plugin->hasIdentity) {
    plugin->history.value().Clear();
  } else {
    plugin->history.value().Clear(plugin->aumid);
  }
  for (const auto notification : plugin->notifier.value().GetScheduledToastNotifications()) {
    plugin->notifier.value().RemoveFromSchedule(notification);
  }
  });
}

void cancelNotification(NativePlugin* plugin, int id) {
  plugin->worker.post([plugin, id] {
    if (!plugin->isReady) return;
    const auto tag = winrt::to_hstring(id);
    if (plugin->hasIdentity) plugin->history.value().Remove(tag);
    for (const auto notification : plugin->notifier.value().GetScheduledToastNotifications()) {
      if (notification.Tag() == tag) {
        plugin->notifier.value().RemoveFromSchedule(notification);
        return;
      }
    }
  });
}

NativeNotificationDetails* getActiveNotifications(NativePlugin* plugin, int* size) {
  NativeNotificationDetails* out = nullptr;
  int count = 0;
  plugin->worker.invoke([plugin, &out, &count] {
  // TODO: Get more details here
  if (!plugin->isReady || !plugin->hasIdentity) {
    return;
  }
  int* size = &count;
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
  out = result;
  });
  *size = count;
  return out;
}

NativeNotificationDetails* getPendingNotifications(NativePlugin* plugin, int* size) {
  NativeNotificationDetails* out = nullptr;
  int count = 0;
  plugin->worker.invoke([plugin, &out, &count] {
  // TODO: Get more details here
  if (!plugin->isReady) {
    return;
  }
  int* size = &count;
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
  out = result;
  });
  *size = count;
  return out;
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
