#include <vector>

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

/// (Re)creates the WinRT handles used to show and manage notifications.
static void createHandles(NativePlugin* plugin) {
  plugin->notifier = plugin->hasIdentity
    ? ToastNotificationManager::CreateToastNotifier()
    : ToastNotificationManager::CreateToastNotifier(plugin->aumid);
  plugin->history = ToastNotificationManager::History();
}

/// Whether the error means the handles point to an object that no longer exists.
///
/// The notifier and the history are COM proxies created once in [init]. If the notification
/// platform behind them goes away while the app is running, every call on them fails with one of
/// these errors until they are created again.
///
/// Only codes that guarantee the call did not execute are listed, so the retry cannot run it twice.
static bool isDisconnected(const winrt::hresult_error& error) {
  const HRESULT code = error.code();
  return code == CO_E_OBJNOTCONNECTED || code == RPC_E_DISCONNECTED
    || code == RPC_E_SERVER_DIED_DNE || code == HRESULT_FROM_WIN32(RPC_S_SERVER_UNAVAILABLE)
    || code == HRESULT_FROM_WIN32(RPC_S_CALL_FAILED_DNE);
}

/// Runs [action], which uses the plugin's WinRT handles, without letting an exception escape.
///
/// An exception that crosses the FFI boundary cannot be caught on the Dart side: it terminates the
/// process. If the handles are disconnected, they are created again and [action] is retried once.
/// Returns false if [action] could not complete.
template <typename Action>
static bool withHandles(NativePlugin* plugin, Action action) {
  try {
    action();
    return true;
  } catch (const winrt::hresult_error& error) {
    if (!isDisconnected(error)) return false;
  } catch (...) {
    return false;
  }
  try {
    createHandles(plugin);
    action();
    return true;
  } catch (...) {
    return false;
  }
}

bool init(
  NativePlugin* plugin, char* appName, char* aumId, char* guid, char* iconPath,
  NativeNotificationCallback callback
) {
  string icon;
  if (iconPath != nullptr) icon = string(iconPath);
  try {
    const auto didRegister = plugin->registerApp(aumId, appName, guid, icon, callback);
    if (!didRegister) return false;
    plugin->hasIdentity = hasPackageIdentity();
    plugin->aumid = winrt::to_hstring(aumId);
    createHandles(plugin);
  } catch (...) {
    // The notification platform can be unavailable at launch. Report it instead of terminating.
    return false;
  }
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
  return withHandles(plugin, [&] {
    ToastNotification notification(doc);
    const auto data = dataFromMap(bindings);
    notification.Tag(winrt::to_hstring(id));
    notification.Data(data);
    plugin->notifier.value().Show(notification);
  });
}

bool scheduleNotification(NativePlugin* plugin, int id, char* xml, int time) {
  if (!plugin->isReady) return false;
  XmlDocument doc;
  try {
    doc.LoadXml(winrt::to_hstring(xml));
  } catch (winrt::hresult_error error) {
    return false;
  }
  return withHandles(plugin, [&] {
    ScheduledToastNotification notification(doc, winrt::clock::from_time_t(time));
    notification.Tag(winrt::to_hstring(id));
    plugin->notifier.value().AddToSchedule(notification);
  });
}

NativeUpdateResult updateNotification(NativePlugin* plugin, int id, NativeStringMap bindings) {
  if (!plugin->isReady) return NativeUpdateResult::failed;
  const auto tag = winrt::to_hstring(id);
  NativeUpdateResult result = NativeUpdateResult::failed;
  const auto didUpdate = withHandles(plugin, [&] {
    const auto data = dataFromMap(bindings);
    result = (NativeUpdateResult) plugin->notifier.value().Update(data, tag);
  });
  return didUpdate ? result : NativeUpdateResult::failed;
}

void cancelAll(NativePlugin* plugin) {
  if (!plugin->isReady) return;
  withHandles(plugin, [&] {
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
  if (!plugin->isReady) return;
  const auto tag = winrt::to_hstring(id);
  withHandles(plugin, [&] {
    if (plugin->hasIdentity) plugin->history.value().Remove(tag);
    for (const auto notification : plugin->notifier.value().GetScheduledToastNotifications()) {
      if (notification.Tag() == tag) {
        plugin->notifier.value().RemoveFromSchedule(notification);
        return;
      }
    }
  });
}

/// Adds the notification ID held in [tag], skipping a tag that is not a number.
///
/// The history holds every notification shown under the app's ID, including ones this plugin did
/// not create, so one unexpected tag must not hide the others.
static void addId(vector<int>& ids, const winrt::hstring& tag) {
  try {
    ids.push_back(std::stoi(winrt::to_string(tag)));
  } catch (const std::exception&) {
  }
}

/// Copies the notification IDs into an array that must be released with [freeDetailsArray].
static NativeNotificationDetails* toDetailsArray(const vector<int>& ids, int* size) {
  *size = static_cast<int>(ids.size());
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
  vector<int> ids;
  const auto didRead = withHandles(plugin, [&] {
    ids.clear();
    for (const auto notification : plugin->history.value().GetHistory()) {
      addId(ids, notification.Tag());
    }
  });
  if (!didRead) ids.clear();
  return toDetailsArray(ids, size);
}

NativeNotificationDetails* getPendingNotifications(NativePlugin* plugin, int* size) {
  // TODO: Get more details here
  if (!plugin->isReady) {
    *size = 0;
    return nullptr;
  }
  vector<int> ids;
  const auto didRead = withHandles(plugin, [&] {
    ids.clear();
    for (const auto notification : plugin->notifier.value().GetScheduledToastNotifications()) {
      addId(ids, notification.Tag());
    }
  });
  if (!didRead) ids.clear();
  return toDetailsArray(ids, size);
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
