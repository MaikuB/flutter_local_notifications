import 'types.dart';

abstract class ScheduledNotificationRepeatTrigger {}

/// Used to schedule a notification that appears on a regular time interval expressed in seconds.
class TimeIntervalScheduledNotificationRepeatTrigger
    extends ScheduledNotificationRepeatTrigger {
  TimeIntervalScheduledNotificationRepeatTrigger(this.seconds)
      : assert(seconds != null);

  /// The time interval measured in seconds.
  final int seconds;
}

class CalendarUnitScheduledNotificationRepeatTrigger
    extends ScheduledNotificationRepeatTrigger {
  CalendarUnitScheduledNotificationRepeatTrigger(
    this.calendarUnit, {
    this.interval = 1,
  }) : assert(calendarUnit != null && interval > 0);

  final CalendarUnit calendarUnit;

  final int interval;
}
