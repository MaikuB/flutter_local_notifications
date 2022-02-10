#include "utils.h"

#include <optional>

template <typename T>
std::optional<T> Utils::GetMapValue(const std::string& key, const flutter::EncodableMap* m) {
	const auto pair = m->find(flutter::EncodableValue(key));
	if (pair == m->end()) {
		return std::nullopt;
	}
	const auto& str = std::get<T>(pair->second);
	return str;
}
