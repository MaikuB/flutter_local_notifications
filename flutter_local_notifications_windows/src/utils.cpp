#include "utils.hpp"

Bindings pairsToBindings(Pair* pairs, int size) {
  Bindings result;
  for (int index = 0; index < size; index++) {
    const auto pair = pairs[index];
    result.try_emplace(pair.key, pair.value);
  }
  return result;
}

Pair* bindingsToPairs(Bindings bindings, int* size) {
  *size = (int) bindings.size();
  auto array = new Pair[*size];
  int index = 0;
  for (const auto pair : bindings) {
    array[index].key = pair.first.c_str();
    array[index].value = pair.second.c_str();
    index++;
  }
  return array;
}

NativeDetails* getDetailsArray(vector<NativeDetails> vec, int* size) {
  *size = (int) vec.size();
  auto result = new NativeDetails[vec.size()];
  for (int index = 0; index < vec.size(); index++) {
    result[index] = vec.at(index);
  }
  return result;
}

NotificationData dataFromBindings(Bindings bindings) {
  NotificationData data;
  for (const auto pair : bindings) {
    const auto key = winrt::to_hstring(pair.first);
    const auto value = winrt::to_hstring(pair.second);
    data.Values().Insert(key, value);
  }
  return data;
}

NativeLaunchDetails* parseLaunchDetails(LaunchData data) {
  NativeLaunchDetails* result = new NativeLaunchDetails;
  result->didLaunch = data.didLaunch;
  result->data = bindingsToPairs(data.data, &result->dataSize);
  result->launchType = data.launchType;
  result->payload = new char[data.payload.size()];
  result->payloadSize = (int) data.payload.size();
  memcpy(result->payload, data.payload.c_str(), data.payload.size());
  return result;
}