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

typedef struct Pair {
  const char* key;
  const char* value;
} Pair;

typedef struct {
  int id;
} NativeDetails;

typedef enum {
  notification,
  action,
} NativeLaunchType;

typedef struct {
  int didLaunch;
  NativeLaunchType launchType;
  char* payload;
  int payloadSize;
  Pair* data;
  int dataSize;
} NativeLaunchDetails;

typedef void (*NativeNotificationCallback)(NativeLaunchDetails* details);

// See: https://learn.microsoft.com/en-us/uwp/api/windows.ui.notifications.notificationupdateresult
typedef enum {
  success = 0,
  failed = 1,
  notFound = 2,
} NativeUpdateResult;

FFI_PLUGIN_EXPORT NativePlugin* createPlugin();
FFI_PLUGIN_EXPORT void disposePlugin(NativePlugin* ptr);

FFI_PLUGIN_EXPORT int init(
  NativePlugin* plugin,
  char* appName,
  char* aumId,
  char* guid,
  char* iconPath,
  NativeNotificationCallback callback
);

FFI_PLUGIN_EXPORT int showNotification(NativePlugin* plugin, int id, char* xml, Pair* bindings, int bindingsSize);

FFI_PLUGIN_EXPORT int scheduleNotification(NativePlugin* plugin, int id, char* xml, int time);

FFI_PLUGIN_EXPORT NativeUpdateResult updateNotification(NativePlugin* plugin, int id, Pair* bindings, int bindingsSize);

FFI_PLUGIN_EXPORT void cancelAll(NativePlugin* plugin);

FFI_PLUGIN_EXPORT void cancelNotification(NativePlugin* plugin, int id);

FFI_PLUGIN_EXPORT NativeDetails* getActiveNotifications(NativePlugin* plugin, int* size);

FFI_PLUGIN_EXPORT NativeDetails* getPendingNotifications(NativePlugin* plugin, int* size);

FFI_PLUGIN_EXPORT NativeLaunchDetails* getLaunchDetails(NativePlugin* plugin);

FFI_PLUGIN_EXPORT void freeDetailsArray(NativeDetails* ptr);

FFI_PLUGIN_EXPORT void freePairArray(Pair* ptr);

#ifdef __cplusplus
}
#endif

#endif
