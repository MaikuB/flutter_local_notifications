#include <windows.h>  // <-- This must be the first Windows header
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Data.Xml.Dom.h>

#include <charconv>
#include <thread>
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

// Teardown waits for the worker, which may be stuck in a COM call, so it never runs
// on the caller's thread. The reaper thread owns [plugin] from here on.
void disposePlugin(NativePlugin* plugin) {
  std::thread([plugin] { delete plugin; }).detach();
}

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

// Collects matches first: removing while iterating the scheduled view is unsafe.
static void removeScheduled(NativePlugin* plugin, const winrt::hstring& tag) {
  auto& notifier = plugin->notifier.value();
  std::vector<ScheduledToastNotification> matches;
  for (const auto notification : notifier.GetScheduledToastNotifications()) {
    if (notification.Tag() == tag) matches.push_back(notification);
  }
  for (const auto& notification : matches) notifier.RemoveFromSchedule(notification);
}

bool showNotification(NativePlugin* plugin, int id, char* xml, NativeStringMap bindings) {
  // Parsing is local, so a malformed document is still reported to the caller.
  if (!isValidXml(xml)) return false;
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
  if (!isValidXml(xml)) return false;
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
    const auto tag = winrt::to_hstring(id);
    notification.Tag(tag);
    removeScheduled(plugin, tag);
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
    removeScheduled(plugin, tag);
  });
}

// Toast history can hold tags this plugin did not set; those are skipped. The array
// is published only once complete, so the caller never sees a count without data.
template <typename Notifications>
static NativeNotificationDetails* copyIds(const Notifications& notifications, int& count) {
  std::vector<int> ids;
  for (const auto notification : notifications) {
    const auto tag = winrt::to_string(notification.Tag());
    int id = 0;
    const auto parsed = std::from_chars(tag.data(), tag.data() + tag.size(), id);
    if (!tag.empty() && parsed.ec == std::errc() && parsed.ptr == tag.data() + tag.size()) {
      ids.push_back(id);
    }
  }
  if (ids.empty()) return nullptr;
  const auto result = new NativeNotificationDetails[ids.size()];
  for (size_t index = 0; index < ids.size(); index++) result[index].id = ids[index];
  count = static_cast<int>(ids.size());
  return result;
}

NativeNotificationDetails* getActiveNotifications(NativePlugin* plugin, int* size) {
  NativeNotificationDetails* out = nullptr;
  int count = 0;
  plugin->worker.invoke([plugin, &out, &count] {
    // TODO: Get more details here
    if (!plugin->isReady || !plugin->hasIdentity) return;
    out = copyIds(plugin->history.value().GetHistory(), count);
  });
  *size = count;
  return out;
}

NativeNotificationDetails* getPendingNotifications(NativePlugin* plugin, int* size) {
  NativeNotificationDetails* out = nullptr;
  int count = 0;
  plugin->worker.invoke([plugin, &out, &count] {
    // TODO: Get more details here
    if (!plugin->isReady) return;
    out = copyIds(plugin->notifier.value().GetScheduledToastNotifications(), count);
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
