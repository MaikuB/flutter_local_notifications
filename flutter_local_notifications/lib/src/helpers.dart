import 'package:clock/clock.dart';
import 'package:timezone/timezone.dart';

import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

/// Helper method for validating a date/time value represents a future point in
/// time where `matchDateTimeComponents` is null.
void validateDateIsInTheFuture(
  TZDateTime scheduledDate,
  DateTimeComponents? matchDateTimeComponents,
) {
  if (matchDateTimeComponents != null) {
    return;
  }
  if (scheduledDate.isBefore(clock.now())) {
    throw ArgumentError.value(
      scheduledDate,
      'scheduledDate',
      'Must be a date in the future',
    );
  }
}
