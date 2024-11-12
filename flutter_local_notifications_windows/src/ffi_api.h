#ifndef FFI_API_H_
#define FFI_API_H_

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

// FFI needs to use a C-compatible API, even if the code is implemented in C++ or another language.
#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>

/// A fake type to represent the C++ class that will own the Windows API handles.
typedef struct NativePlugin NativePlugin;

/// A key-value pair in a map where both the keys and values are strings.
typedef struct StringMapEntry {
  const char* key;
  const char* value;
} StringMapEntry;

/// A map where the keys and values are all strings.
typedef struct NativeStringMap {
  const StringMapEntry* entries;
  int size;
} NativeStringMap;

/// Details about a notification.
typedef struct NativeNotificationDetails {
  int id;
} NativeNotificationDetails;

/// How the app was launched, either by pressing on the notification or an action within it.
typedef enum NativeLaunchType {
  notification,
  action,
} NativeLaunchType;

/// Details about how the app was launched.
typedef struct NativeLaunchDetails {
  /// Whether the app was launched by a notification
  bool didLaunch;
  /// What part of the notification launched the app.
  NativeLaunchType launchType;
  /// The payload sent to the app by the notification. Usually the action that was pressed.
  const char* payload;
  /// The IDs and values of any text inputs in the notification.
  NativeStringMap data;
} NativeLaunchDetails;

/// A callback that is run with [NativeLaunchDetails] when a notification is pressed.
///
/// This may be called at app launch or even while the app is running.
typedef void (*NativeNotificationCallback)(NativeLaunchDetails details);

// See: https://learn.microsoft.com/en-us/uwp/api/windows.ui.notifications.notificationupdateresult
typedef enum NativeUpdateResult {
  success = 0,
  failed = 1,
  notFound = 2,
} NativeUpdateResult;

/// Allocates a new plugin that must be released with [disposePlugin].
FFI_PLUGIN_EXPORT NativePlugin* createPlugin();

/// Releases the plugin and any resources it was holding onto.
FFI_PLUGIN_EXPORT void disposePlugin(NativePlugin* ptr);

/// Initializes the plugin and registers the callback to be run when a notification is pressed.
FFI_PLUGIN_EXPORT bool init(
  NativePlugin* plugin, char* appName, char* aumId, char* guid, char* iconPath,
  NativeNotificationCallback callback
);

/// Shows the XML as a notification with the given ID. See [updateNotification] for details on
/// bindings.
FFI_PLUGIN_EXPORT bool showNotification(
  NativePlugin* plugin, int id, char* xml, NativeStringMap bindings
);

/// Schedules the notification to be shown at the given time (as a [time_t]).
FFI_PLUGIN_EXPORT bool scheduleNotification(NativePlugin* plugin, int id, char* xml, int time);

/// Updates a notification with the provided bindings after it's been shown.
///
/// String values in the `<binding>` element of the XML can be placeholders instead of values,
/// for example, `<text>{name}</text>` and then call this function with a map with a `name` key,
/// and any string value, and the notification will be updated with that value where `name` was.
FFI_PLUGIN_EXPORT NativeUpdateResult
updateNotification(NativePlugin* plugin, int id, NativeStringMap bindings);

/// Cancels all notifications.
FFI_PLUGIN_EXPORT void cancelAll(NativePlugin* plugin);

/// Cancels a notification with the given ID.
///
/// Only applications with "package identity" (ie, installed with an MSIX installer), can use this.
FFI_PLUGIN_EXPORT void cancelNotification(NativePlugin* plugin, int id);

/// Gets all notifications that have already been shown but are still in the Action center.
///
/// Only applications with "package identity" (ie, installed with an MSIX installer), can use this.
/// When your app does not have identity, such as in debug mode, this will return an empty array.
FFI_PLUGIN_EXPORT NativeNotificationDetails* getActiveNotifications(
  NativePlugin* plugin, int* size
);

/// Gets all notifications that have been scheduled but not yet shown.
FFI_PLUGIN_EXPORT NativeNotificationDetails* getPendingNotifications(
  NativePlugin* plugin, int* size
);

/// Releases the memory associated with a [NativeNotificationDetails] array.
FFI_PLUGIN_EXPORT void freeDetailsArray(NativeNotificationDetails* ptr);

/// Releases the memory associated with a [NativeLaunchDetails].
FFI_PLUGIN_EXPORT void freeLaunchDetails(NativeLaunchDetails details);

/// EXPERIMENTAL: Enables multithreading for this application.
///
/// NOTE: This is only to make tests more stable and is not intended to be used in applications.
FFI_PLUGIN_EXPORT void enableMultithreading();

#ifdef __cplusplus
}
#endif

#endif
