/// Specify the accuracy of the alarm.
enum ScheduleAccuracy {
  /// Setup an alarm with regular accuracy.
  /// When in low-power idle modes this duration may be significantly longer,
  /// such as 15 minutes.
  regular,

  /// Schedule an alarm to be delivered precisely at the stated time.
  /// Only alarms for which there is a strong demand for exact-time delivery
  /// (such as an alarm clock ringing at the requested time) should be scheduled
  /// as exact.
  /// Note that this accuracy require to declare more permissions on Android.
  exact,
}
