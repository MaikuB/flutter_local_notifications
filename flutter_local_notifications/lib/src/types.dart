/// The days of the week.
class Day {
  const Day(this.value);

  static const Day sunday = Day(1);
  static const Day monday = Day(2);
  static const Day tuesday = Day(3);
  static const Day wednesday = Day(4);
  static const Day thursday = Day(5);
  static const Day friday = Day(6);
  static const Day saturday = Day(7);

  /// All the possible values for the [Day] enumeration.
  static List<Day> get values =>
      <Day>[sunday, monday, tuesday, wednesday, thursday, friday, saturday];

  final int value;
}

/// Used for specifying a time in 24 hour format.
class Time {
  const Time([
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
  ])  : assert(hour >= 0 && hour < 24),
        assert(minute >= 0 && minute < 60),
        assert(second >= 0 && second < 60);

  /// The hour component of the time.
  ///
  /// Accepted range is 0 to 23 inclusive.
  final int hour;

  /// The minutes component of the time.
  ///
  /// Accepted range is 0 to 59 inclusive.
  final int minute;

  /// The seconds component of the time.
  ///
  /// Accepted range is 0 to 59 inclusive.
  final int second;
}

enum ScheduledNotificationRepeatFrequency {
  daily,
  weekly,
}
