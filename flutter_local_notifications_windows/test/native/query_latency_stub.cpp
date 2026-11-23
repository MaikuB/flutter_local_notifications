// Test-only ABI fixture: deliberately slow C calls, without WinRT.
#include "../../src/ffi_api.h"
#include <atomic>
#include <chrono>
#include <thread>

struct NativePlugin {
  NativeNotificationCallback callback = nullptr;
};
static std::atomic<int> failureMode {0};
static std::atomic<int> createCount {0};
static std::atomic<int> destroyCount {0};
static std::atomic<int> initFailures {0};
static std::atomic<int> initCount {0};
static std::atomic<int64_t> scheduledTime {0};
static std::atomic<uintptr_t> callbackAddress {0};
static void delay() { std::this_thread::sleep_for(std::chrono::milliseconds(650)); }

extern "C" FFI_PLUGIN_EXPORT void setQueryFailureMode(int mode) { failureMode = mode; }
extern "C" FFI_PLUGIN_EXPORT int stubCreateCount() { return createCount.load(); }
extern "C" FFI_PLUGIN_EXPORT int stubDestroyCount() { return destroyCount.load(); }
extern "C" FFI_PLUGIN_EXPORT int stubInitCount() { return initCount.load(); }
extern "C" FFI_PLUGIN_EXPORT void setInitFailures(int count) { initFailures = count; }
extern "C" FFI_PLUGIN_EXPORT int64_t stubScheduledTime() { return scheduledTime.load(); }
extern "C" FFI_PLUGIN_EXPORT uintptr_t stubCallbackAddress() { return callbackAddress.load(); }

NativePlugin* createPlugin() {
  ++createCount;
  return new NativePlugin();
}
bool init(
  NativePlugin* plugin, char*, char*, char*, char*, NativeNotificationCallback callback,
  NativeInitCallback onReady
) {
  plugin->callback = callback;
  callbackAddress = reinterpret_cast<uintptr_t>(callback);
  ++initCount;
  const bool success = initFailures.load() == 0;
  if (!success) --initFailures;
  onReady(success);
  return true;
}
void disposePlugin(NativePlugin* plugin) {
  delay();
  ++destroyCount;
  delete plugin;
}
bool scheduleNotification(NativePlugin*, int, char*, int64_t time) {
  scheduledTime = time;
  return true;
}
NativeNotificationDetails* getActiveNotifications(NativePlugin*, int* size) {
  delay();
  const int mode = failureMode.exchange(0);
  if (mode == 1) {
    *size = 2;
    return nullptr;
  }
  if (mode == 2) {
    *size = -1;
    return nullptr;
  }
  *size = 2;
  return new NativeNotificationDetails[2] {{11}, {12}};
}
NativeNotificationDetails* getPendingNotifications(NativePlugin*, int* size) {
  delay();
  *size = 1;
  return new NativeNotificationDetails[1] {{31}};
}
NativeUpdateResult updateNotification(NativePlugin*, int, NativeStringMap) {
  delay();
  return NativeUpdateResult::success;
}
void freeDetailsArray(NativeNotificationDetails* ptr) { delete[] ptr; }
void freeLaunchDetails(NativeLaunchDetails details) {
  delete[] details.payload;
  if (details.data.entries != nullptr) {
    for (int i = 0; i < details.data.size; ++i) {
      delete[] details.data.entries[i].key;
      delete[] details.data.entries[i].value;
    }
  }
  delete[] details.data.entries;
}
