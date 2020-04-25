import 'types.dart';

abstract class ScheduledNotificationTrigger {}

/// Used to schedule a notification that appears on a regular time interval expressed in seconds.
class TimeIntervalScheduledNotificationTrigger
    extends ScheduledNotificationTrigger {
  TimeIntervalScheduledNotificationTrigger(this.seconds)
      : assert(seconds != null);

  /// The time interval measured in seconds.
  final int seconds;
}

class CalendarScheduledNotificationTrigger
    extends ScheduledNotificationTrigger {
  CalendarScheduledNotificationTrigger(
    this.calendarUnit, {
    this.interval = 1,
  }) : assert(calendarUnit != null && interval > 0);

  final CalendarUnit calendarUnit;

  final int interval;
}
