import 'package:flutter/foundation.dart';

import 'enums.dart';

/// Represents a custom Linux notification hint.
/// Hints are a way to provide extra data to a notification server that
/// the server may be able to make use of.
/// For more information, please see Desktop Notifications Specification https://specifications.freedesktop.org/notification-spec/latest/ar01s08.html
@optionalTypeArgs
class LinuxNotificationCustomHint<T> {
  /// Constructs an instance of [LinuxNotificationCustomHint].
  const LinuxNotificationCustomHint(this.name, this.value);

  /// Name of this hint.
  /// The vendor hint name should be in the form of `x-vendor-name`.
  final String name;

  /// Value corresponding to the hint.
  final LinuxHintValue<T> value;
}

/// Represents abstract Linux notification hint value.
@optionalTypeArgs
abstract class LinuxHintValue<T> {
  /// Specifies the notification hint value type.
  LinuxHintValueType get type;

  /// Value, corresponding to the Dart type system.
  T get value;
}

/// Ordered list of values of the same type.
class LinuxHintArrayValue<T extends LinuxHintValue>
    implements LinuxHintValue<List<T>> {
  /// Constructs an instance of [LinuxHintArrayValue].
  const LinuxHintArrayValue(this.value);

  @override
  LinuxHintValueType get type => LinuxHintValueType.array;

  @override
  final List<T> value;
}

/// Boolean value.
class LinuxHintBoolValue extends LinuxHintValue<bool> {
  /// Constructs an instance of [LinuxHintBoolValue].
  LinuxHintBoolValue(this.value);

  @override
  LinuxHintValueType get type => LinuxHintValueType.boolean;

  @override
  final bool value;
}

/// Unsigned 8 bit value.
class LinuxHintByteValue extends LinuxHintValue<int> {
  /// Constructs an instance of [LinuxHintByteValue].
  LinuxHintByteValue(this.value);

  @override
  LinuxHintValueType get type => LinuxHintValueType.byte;

  @override
  final int value;
}

/// Associative array of values.
class LinuxHintDictValue<K extends LinuxHintValue, V extends LinuxHintValue>
    extends LinuxHintValue<Map<K, V>> {
  /// Constructs an instance of [LinuxHintDictValue].
  LinuxHintDictValue(this.value);

  /// Constructs an instance of [LinuxHintDictValue].
  LinuxHintDictValue.stringVariant(Map<String, V> value)
      : value = value.map(
          (String key, V value) => MapEntry<K, V>(
            LinuxHintStringValue(key) as K,
            value,
          ),
        );

  @override
  LinuxHintValueType get type => LinuxHintValueType.dict;

  @override
  final Map<K, V> value;
}

/// 64-bit floating point value.
class LinuxHintDoubleValue extends LinuxHintValue<double> {
  /// Constructs an instance of [LinuxHintDoubleValue].
  LinuxHintDoubleValue(this.value);

  @override
  LinuxHintValueType get type => LinuxHintValueType.double;

  @override
  final double value;
}

/// Signed 16-bit integer.
class LinuxHintInt16Value extends LinuxHintValue<int> {
  /// Constructs an instance of [LinuxHintInt16Value].
  LinuxHintInt16Value(this.value);

  @override
  LinuxHintValueType get type => LinuxHintValueType.int16;

  @override
  final int value;
}

/// Signed 32-bit integer.
class LinuxHintInt32Value extends LinuxHintValue<int> {
  /// Constructs an instance of [LinuxHintInt32Value].
  LinuxHintInt32Value(this.value);

  @override
  LinuxHintValueType get type => LinuxHintValueType.int32;

  @override
  final int value;
}

/// Signed 64-bit integer.
class LinuxHintInt64Value extends LinuxHintValue<int> {
  /// Constructs an instance of [LinuxHintInt64Value].
  LinuxHintInt64Value(this.value);

  @override
  LinuxHintValueType get type => LinuxHintValueType.int64;

  @override
  final int value;
}

/// Unicode text string.
class LinuxHintStringValue extends LinuxHintValue<String> {
  /// Constructs an instance of [LinuxHintStringValue].
  LinuxHintStringValue(this.value);

  @override
  LinuxHintValueType get type => LinuxHintValueType.string;

  @override
  final String value;
}

/// Value that contains a fixed set of other values.
class LinuxHintStructValue extends LinuxHintValue<List<LinuxHintValue>> {
  /// Constructs an instance of [LinuxHintStructValue].
  LinuxHintStructValue(Iterable<LinuxHintValue> value) : value = value.toList();

  @override
  LinuxHintValueType get type => LinuxHintValueType.struct;

  @override
  final List<LinuxHintValue> value;
}

/// Unsigned 16-bit integer.
class LinuxHintUint16Value extends LinuxHintValue<int> {
  /// Constructs an instance of [LinuxHintUint16Value].
  LinuxHintUint16Value(this.value);

  @override
  LinuxHintValueType get type => LinuxHintValueType.uint16;

  @override
  final int value;
}

/// Unsigned 32-bit integer.
class LinuxHintUint32Value extends LinuxHintValue<int> {
  /// Constructs an instance of [LinuxHintUint32Value].
  LinuxHintUint32Value(this.value);

  @override
  LinuxHintValueType get type => LinuxHintValueType.uint32;

  @override
  final int value;
}

/// Unsigned 64-bit integer.
class LinuxHintUint64Value extends LinuxHintValue<int> {
  /// Constructs an instance of [LinuxHintUint64Value].
  LinuxHintUint64Value(this.value);

  @override
  LinuxHintValueType get type => LinuxHintValueType.uint64;

  @override
  final int value;
}

/// Value that contains any type.
class LinuxHintVariantValue extends LinuxHintValue<LinuxHintValue> {
  /// Constructs an instance of [LinuxHintVariantValue].
  LinuxHintVariantValue(this.value);

  @override
  LinuxHintValueType get type => LinuxHintValueType.variant;

  @override
  final LinuxHintValue value;
}
