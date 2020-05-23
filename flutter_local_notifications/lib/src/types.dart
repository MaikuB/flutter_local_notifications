/// The days of the week.
class Day {
  const Day(this.value);

  static const Day Sunday = Day(1);
  static const Day Monday = Day(2);
  static const Day Tuesday = Day(3);
  static const Day Wednesday = Day(4);
  static const Day Thursday = Day(5);
  static const Day Friday = Day(6);
  static const Day Saturday = Day(7);

  /// All the possible values for the [Day] enumeration.
  static List<Day> get values =>
      <Day>[Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday];

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
  Daily,
  Weekly,
}
