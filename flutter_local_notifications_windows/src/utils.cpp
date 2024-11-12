#include <winrt/Windows.Foundation.Collections.h>

#include "utils.hpp"
#include <iostream>

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
  return {array, size};
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

constexpr uint8_t hex_to_uint(const char c) {
  if (c >= '0' && c <= '9') {
    return static_cast<uint8_t>(c - '0');
  } else if (c >= 'A' && c <= 'F') {
    return static_cast<uint8_t>(10 + c - 'A');
  } else if (c >= 'a' && c <= 'f') {
    return static_cast<uint8_t>(10 + c - 'a');
  } else {
    throw std::invalid_argument("Character is not a hexadecimal digit");
  }
}

constexpr uint8_t hex_to_uint8(const char a, const char b) {
  return (hex_to_uint(a) << 4) | hex_to_uint(b);
}

constexpr uint16_t uint8_to_uint16(uint8_t a, uint8_t b) {
  return (static_cast<uint16_t>(a) << 8) | static_cast<uint16_t>(b);
}

constexpr uint32_t uint8_to_uint32(uint8_t a, uint8_t b, uint8_t c, uint8_t d) {
  return (static_cast<uint32_t>(uint8_to_uint16(a, b)) << 16)
    | static_cast<uint32_t>(uint8_to_uint16(c, d));
}

winrt::guid parseGuid(const std::string& guidString) {
  // clang-format off
  if (
    guidString.size() != 36
      || guidString[8] != '-'
      || guidString[13] != '-'
      || guidString[18] != '-'
      || guidString[23] != '-'
  ) {
    throw std::invalid_argument("guidString is not a valid GUID string");
  }
  // clang-format on
  return {
    uint8_to_uint32(
      hex_to_uint8(guidString[0], guidString[1]), hex_to_uint8(guidString[2], guidString[3]),
      hex_to_uint8(guidString[4], guidString[5]), hex_to_uint8(guidString[6], guidString[7])
    ),
    uint8_to_uint16(
      hex_to_uint8(guidString[9], guidString[10]), hex_to_uint8(guidString[11], guidString[12])
    ),
    uint8_to_uint16(
      hex_to_uint8(guidString[14], guidString[15]), hex_to_uint8(guidString[16], guidString[17])
    ),
    {
      hex_to_uint8(guidString[19], guidString[20]),
      hex_to_uint8(guidString[21], guidString[22]),
      hex_to_uint8(guidString[24], guidString[25]),
      hex_to_uint8(guidString[26], guidString[27]),
      hex_to_uint8(guidString[28], guidString[29]),
      hex_to_uint8(guidString[30], guidString[31]),
      hex_to_uint8(guidString[32], guidString[33]),
      hex_to_uint8(guidString[34], guidString[35]),
    }
  };
}
