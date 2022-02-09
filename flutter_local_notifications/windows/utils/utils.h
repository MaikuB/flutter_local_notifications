#ifndef UTILS_H_
#define UTILS_H_

#include <flutter/encodable_value.h>
#include <optional>

namespace Utils {
	std::optional<std::string> GetString(const std::string& key, const flutter::EncodableMap* m);
}

#endif // !UTILS_H
