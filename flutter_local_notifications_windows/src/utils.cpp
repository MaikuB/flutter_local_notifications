#include <winrt/Windows.Foundation.Collections.h>

#include "utils.hpp"

char* toNativeString(string str) {
  const auto size = (int) str.size() + 1;  // + 1 for null terminator
  const auto result = new char[size];
  strcpy_s(result, size, str.c_str());
  return result;
}

NativeStringMap toNativeMap(vector<StringMapEntry> entries) {
  const auto size = (int) entries.size();
  const auto array = new StringMapEntry[size];
  std::copy(entries.begin(), entries.end(), array);
  return { array, size };
}

NotificationData dataFromMap(NativeStringMap map) {
  NotificationData data;
  for (int index = 0; index < map.size; index++) {
    const auto key = winrt::to_hstring(map.entries[index].key);
    const auto value = winrt::to_hstring(map.entries[index].value);
    data.Values().Insert(key, value);
  }
  return data;
}