#pragma once

#include <map>
#include <string>

#include <windows.h>  // <-- This must be the first Windows header
#include <appmodel.h>
#include <VersionHelpers.h>
#include <winrt/Windows.UI.Notifications.h>

#include "ffi_api.h"

using std::string;
using std::vector;
using namespace winrt::Windows::UI::Notifications;

/// Allocates and returns a char array representing the original C++ string.
char* toNativeString(string str);

/// Allocates and returns a [NativeStringMap] with the given key-value pairs.
NativeStringMap toNativeMap(vector<StringMapEntry> entries);

/// Parses a [NativeStringMap] into a WinRT [NotificationData].
NotificationData dataFromMap(NativeStringMap map);

winrt::guid parseGuid(const std::string& guidString);
