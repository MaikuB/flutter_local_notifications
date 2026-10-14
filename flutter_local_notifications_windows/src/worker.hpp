#pragma once

#include <condition_variable>
#include <deque>
#include <functional>
#include <mutex>
#include <thread>

/// Runs every WinRT/COM call on one dedicated thread that owns its own apartment.
///
/// The toast APIs talk to the Windows notification service over COM, and that call
/// can block for minutes on a machine whose service is unhealthy. Calling them from
/// the thread that runs the Flutter engine freezes the whole UI, so the plugin owns
/// a worker instead: `post` returns immediately, `invoke` waits for a result.
class NotificationWorker {
 public:
  NotificationWorker();
  ~NotificationWorker();

  /// Queues [job] and returns immediately.
  void post(std::function<void()> job);

  /// Queues [job] and blocks until it has run.
  void invoke(std::function<void()> job);

 private:
  void run();

  std::thread thread;
  std::mutex mutex;
  std::condition_variable signal;
  std::deque<std::function<void()>> jobs;
  bool stopping = false;
};
