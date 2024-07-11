#pragma once

#include <winrt/Windows.UI.Notifications.h>
#include <winrt/Windows.Foundation.Collections.h>

#include <map>
#include <string>

#include "ffi_api.h"
#include "registration.hpp"

using std::map;
using std::string;
using std::vector;
using winrt::Windows::UI::Notifications::NotificationData;
using Bindings = map<string, string>;

Bindings pairsToBindings(Pair* pairs, int size);

Pair* bindingsToPairs(Bindings bindings, int* size);

NativeDetails* getDetailsArray(vector<NativeDetails> vec, int* size);

NotificationData dataFromBindings(Bindings bindings);

NativeLaunchDetails* parseLaunchDetails(LaunchData details);
