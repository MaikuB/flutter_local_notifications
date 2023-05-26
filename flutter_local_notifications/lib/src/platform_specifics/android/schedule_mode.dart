/// Used to specify how notifications should be scheduled on Android.
///
/// This leverages the use of alarms to schedule notifications as described
/// at https://developer.android.com/training/scheduling/alarms
enum AndroidScheduleMode {
  /// Used to specify that the notification should be scheduled to be shown at
  /// the exact time specified AND will execute whilst device is in
  /// low-power idle mode. Requires SCHEDULE_EXACT_ALARM permission.
  alarmClock,

  /// Used to specify that the notification should be scheduled to be shown at
  /// the exact time specified but may not execute whilst device is in
  /// low-power idle mode.
  exact,

  /// Used to specify that the notification should be scheduled to be shown at
  /// the exact time specified and will execute whilst device is in
  /// low-power idle mode.
  exactAllowWhileIdle,

  /// Used to specify that the notification should be scheduled to be shown at
  /// at roughly specified time but may not execute whilst device is in
  /// low-power idle mode.
  inexact,

  /// Used to specify that the notification should be scheduled to be shown at
  /// at roughly specified time and will execute whilst device is in
  /// low-power idle mode.
  inexactAllowWhileIdle,
}
