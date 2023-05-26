/// The days of the week.
enum Day {
  /// Sunday.
  sunday(1),

  /// Monday.
  monday(2),

  /// Tuesday.
  tuesday(3),

  /// Wednesday.
  wednesday(4),

  /// Thursday.
  thursday(5),

  /// Friday.
  friday(6),

  /// Saturday.
  saturday(7);

  /// Constructs an instance of [Day].
  const Day(this.value);

  /// The integer representation of [Day].
  final int value;
}

/// Used for specifying a time in 24 hour format.
class Time {
  /// Constructs an instance of [Time].
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

/// The components of a date and time representations.
enum DateTimeComponents {
  /// The time.
  time,

  /// The day of the week and time.
  dayOfWeekAndTime,

  /// The day of the month and time.
  dayOfMonthAndTime,

  /// The date and time.
  dateAndTime,
}
