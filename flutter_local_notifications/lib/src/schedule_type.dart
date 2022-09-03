/// Represents the schedule type.
enum ScheduleType {
  /// This type is used to schedule a regular alarm.
  /// This alarm may not be executed when the system is in low-power idle modes.
  regular,

  /// This type of alarm must only be used for situations where it is actually
  /// required that the alarm go off while in idle -- a reasonable example would
  /// be for a calendar notification that should make a sound so the user is aware
  /// of it.
  allowIdle,
}
