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
