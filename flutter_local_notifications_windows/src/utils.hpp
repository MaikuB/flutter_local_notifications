#pragma once

#include <map>
#include <string>
#include <utility>
#include <vector>

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

/// Copies a [NativeStringMap], whose memory belongs to the caller, into owned strings.
vector<std::pair<string, string>> copyMap(NativeStringMap map);

/// Parses the pairs from [copyMap] into a WinRT [NotificationData].
NotificationData dataFromPairs(const vector<std::pair<string, string>>& pairs);

std::wstring utf8_to_wstring(const std::string& utf8);
winrt::guid parseGuid(const std::string& guidString);
