#include "utils.h"

#include <optional>

std::optional<std::string> Utils::GetString(const std::string& key, const flutter::EncodableMap* m) {
	const auto pair = m->find(key);
	if (pair == m->end()) {
		return std::nullopt;
	}
	const auto& str = std::get<std::string>(pair->second);
	return str;
}
