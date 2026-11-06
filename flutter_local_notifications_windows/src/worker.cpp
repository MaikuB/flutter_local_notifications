#include <windows.h>  // <-- This must be the first Windows header

#include <memory>

#include <winrt/base.h>

#include "worker.hpp"

NotificationWorker::NotificationWorker() : thread(&NotificationWorker::run, this) {}

NotificationWorker::~NotificationWorker() {
  {
    std::lock_guard<std::mutex> lock(mutex);
    stopping = true;
  }
  signal.notify_all();
  if (thread.joinable()) thread.join();
}

bool NotificationWorker::post(std::function<void()> job) {
  {
    std::lock_guard<std::mutex> lock(mutex);
    if (stopping) return false;
    jobs.push_back(std::move(job));
  }
  signal.notify_one();
  return true;
}

bool NotificationWorker::invoke(std::function<void()> job) {
  struct InvocationState {
    std::mutex mutex;
    std::condition_variable signal;
    bool done = false;
  };
  const auto state = std::make_shared<InvocationState>();
  if (!post([job = std::move(job), state] {
    try {
      job();
    } catch (...) {
      // The caller receives its default result, but must never wait forever.
    }
    {
      std::lock_guard<std::mutex> lock(state->mutex);
      state->done = true;
    }
    state->signal.notify_one();
  })) {
    return false;
  }
  std::unique_lock<std::mutex> lock(state->mutex);
  state->signal.wait(lock, [&] { return state->done; });
  return true;
}

void NotificationWorker::run() {
  // Multi-threaded: the apartment belongs to the process, so the WinRT handles and
  // the CoRegisterClassObject registration stay valid for as long as this thread runs.
  winrt::init_apartment(winrt::apartment_type::multi_threaded);
  while (true) {
    std::function<void()> job;
    {
      std::unique_lock<std::mutex> lock(mutex);
      signal.wait(lock, [&] { return stopping || !jobs.empty(); });
      if (jobs.empty()) {
        if (stopping) break;
        continue;
      }
      job = std::move(jobs.front());
      jobs.pop_front();
    }
    try {
      job();
    } catch (...) {
      // A failed notification must never take the worker - and with it every later
      // job - down with it.
    }
  }
  winrt::uninit_apartment();
}
