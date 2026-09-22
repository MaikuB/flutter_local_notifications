#include <windows.h>  // <-- This must be the first Windows header

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

void NotificationWorker::post(std::function<void()> job) {
  {
    std::lock_guard<std::mutex> lock(mutex);
    if (stopping) return;
    jobs.push_back(std::move(job));
  }
  signal.notify_one();
}

void NotificationWorker::invoke(std::function<void()> job) {
  std::mutex done_mutex;
  std::condition_variable done_signal;
  bool done = false;
  post([&] {
    job();
    {
      std::lock_guard<std::mutex> lock(done_mutex);
      done = true;
    }
    done_signal.notify_one();
  });
  std::unique_lock<std::mutex> lock(done_mutex);
  done_signal.wait(lock, [&] { return done; });
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
