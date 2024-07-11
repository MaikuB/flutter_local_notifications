#pragma once

#include <map>
#include <string>
#include <optional>
#include <memory>
#include <functional>

#include "ffi_api.h"

using std::map;
using std::optional;
using std::shared_ptr;
using std::string;

typedef struct LaunchData {
  NativeLaunchType launchType = NativeLaunchType::notification;
  map<string, string> data;
  bool didLaunch;
  string payload;
} LaunchData;

using LaunchCallback = std::function<void(LaunchData)>;

bool RegisterApp(
	const string& aumid,
	const string& appName,
	const string& guid,
	const optional<string>& iconPath,
  LaunchCallback callback
);
