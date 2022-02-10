#ifndef UTILS_H_
#define UTILS_H_

#include <flutter/encodable_value.h>
#include <optional>

namespace Utils {
	/// <summary>
	/// Retrieves the string value stored with the given key in the given EncodableMap.
	/// </summary>
	/// <param name="key">The key that maps to the desired string value.</param>
	/// <param name="m">The EncodabeMap that stores the key-value pair.</param>
	/// <returns>The string value that the key maps to, or nullopt if none is found.</returns>
	template <typename T>
	std::optional<T> GetMapValue(const std::string& key, const flutter::EncodableMap* m);
}

#endif // !UTILS_H
