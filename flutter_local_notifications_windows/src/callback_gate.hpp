#pragma once

#include <mutex>

#include "ffi_api.h"

// Shared by NativePlugin and retained COM activators. Closing the callback
// pointer before an old activator is released is otherwise undefined in Dart.
class NotificationCallbackGate {
public:
  explicit NotificationCallbackGate(NativeNotificationCallback callback) : callback_(callback) {}

  NotificationCallbackGate(const NotificationCallbackGate&) = delete;
  NotificationCallbackGate& operator=(const NotificationCallbackGate&) = delete;

  void deliver(NativeLaunchDetails details) {
    std::lock_guard<std::mutex> lock(mutex_);
    if (closed_ || callback_ == nullptr) {
      freeLaunchDetails(details);
    } else {
      callback_(details);
    }
  }

  void close() {
    // Wait for a native callback already in progress before allowing Dart
    // to close NativeCallable after native disposal returns.
    std::lock_guard<std::mutex> lock(mutex_);
    closed_ = true;
  }

private:
  std::mutex mutex_;
  bool closed_ = false;
  NativeNotificationCallback callback_ = nullptr;
};
