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

#ifdef __cplusplus
extern "C" {
#endif

typedef struct NativePlugin NativePlugin;

typedef struct StringMapEntry {
  const char* key;
  const char* value;
} StringMapEntry;

typedef struct NativeStringMap {
  const StringMapEntry* entries;
  int size;
} NativeStringMap;

typedef struct NativeNotificationDetails {
  int id;
} NativeNotificationDetails;

typedef enum NativeLaunchType {
  notification,
  action,
} NativeLaunchType;

typedef struct NativeLaunchDetails {
  int didLaunch;
  NativeLaunchType launchType;
  const char* payload;
  NativeStringMap data;
} NativeLaunchDetails;

typedef void (*NativeNotificationCallback)(NativeLaunchDetails details);

// See: https://learn.microsoft.com/en-us/uwp/api/windows.ui.notifications.notificationupdateresult
typedef enum NativeUpdateResult {
  success = 0,
  failed = 1,
  notFound = 2,
} NativeUpdateResult;

FFI_PLUGIN_EXPORT NativePlugin* createPlugin();

FFI_PLUGIN_EXPORT void disposePlugin(NativePlugin* ptr);

FFI_PLUGIN_EXPORT int init(NativePlugin* plugin, char* appName, char* aumId, char* guid, char* iconPath, NativeNotificationCallback callback);

FFI_PLUGIN_EXPORT int showNotification(NativePlugin* plugin, int id, char* xml, NativeStringMap bindings);

FFI_PLUGIN_EXPORT int scheduleNotification(NativePlugin* plugin, int id, char* xml, int time);

FFI_PLUGIN_EXPORT NativeUpdateResult updateNotification(NativePlugin* plugin, int id, NativeStringMap bindings);

FFI_PLUGIN_EXPORT void cancelAll(NativePlugin* plugin);

FFI_PLUGIN_EXPORT void cancelNotification(NativePlugin* plugin, int id);

FFI_PLUGIN_EXPORT NativeNotificationDetails* getActiveNotifications(NativePlugin* plugin, int* size);

FFI_PLUGIN_EXPORT NativeNotificationDetails* getPendingNotifications(NativePlugin* plugin, int* size);

FFI_PLUGIN_EXPORT void freeDetailsArray(NativeNotificationDetails* ptr);

FFI_PLUGIN_EXPORT void freeLaunchDetails(NativeLaunchDetails details);

#ifdef __cplusplus
}
#endif

#endif
