/// Plugin initialization settings for Android.
class AndroidInitializationSettings {
  /// Constructs an instance of [AndroidInitializationSettings].
  const AndroidInitializationSettings(
      this.defaultIcon,
      this.scheduleReceiverReflectionClassName
      );

  /// Specifies the schedule class name that will be created by reflection
  final String scheduleReceiverReflectionClassName;
  /// Specifies the default icon for notifications.
  final String defaultIcon;
}
