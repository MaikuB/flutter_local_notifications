#pragma once

#include <map>
#include <string>

#include <windows.h>  // <-- This must be the first Windows header
#include <winrt/Windows.UI.Notifications.h>

#include "ffi_api.h"

using std::string;
using std::vector;
using namespace winrt::Windows::UI::Notifications;

char* toNativeString(string str);

NativeStringMap toNativeMap(vector<StringMapEntry> entries);

NotificationData dataFromMap(NativeStringMap map);
