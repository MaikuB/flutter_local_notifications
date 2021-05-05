import 'package:timezone/timezone.dart';

import 'types.dart';

/// Helper method for validating notification IDs.
/// Ensures IDs are valid 32-bit integers.
void validateId(int id) {
  ArgumentError.checkNotNull(id, 'id');
  if (id > 0x7FFFFFFF || id < -0x80000000) {
    throw ArgumentError.value(id, 'id',
        'must fit within the size of a 32-bit integer i.e. in the range [-2^31, 2^31 - 1]'); // ignore: lines_longer_than_80_chars
  }
}

/// Helper method for validating a date/time value represents a future point in
/// time where `matchDateTimeComponents` is null.
void validateDateIsInTheFuture(
  TZDateTime scheduledDate,
  DateTimeComponents? matchDateTimeComponents,
) {
  if (matchDateTimeComponents != null) {
    return;
  }
  if (scheduledDate.isBefore(DateTime.now())) {
    throw ArgumentError.value(
        scheduledDate, 'scheduledDate', 'Must be a date in the future');
  }
}
