/// Plugin initialization settings for Android.
class AndroidInitializationSettings {
  /// Constructs an instance of [AndroidInitializationSettings].
  const AndroidInitializationSettings(
    this.defaultIcon, {
    this.verifyNotificationIntents = true,
  });

  /// Specifies the default icon for notifications.
  final String defaultIcon;

  /// Whether to ignore intents that look like they come from a notification
  /// but weren't sent by a notification shown by the plugin.
  ///
  /// When the user taps a notification, or one of its actions that has
  /// `showsUserInterface` set to `true`, the plugin receives an intent in the
  /// app's launch activity. The launch activity is exported, so other apps
  /// installed on the device can send it an intent that looks the same, with
  /// a payload of their choosing. The plugin signs the intents of the
  /// notifications it shows. When this is `true`, an intent without a valid
  /// signature is treated as a normal launch of the app: it isn't reported
  /// as a notification response, and
  /// `getNotificationAppLaunchDetails()` reports that the app wasn't
  /// launched by a notification. This also applies to notifications shown by
  /// earlier versions of the plugin, as they weren't signed.
  ///
  /// Set this to `false` only if the app itself starts the launch activity
  /// with intents meant to be handled as notification responses. The value
  /// is saved when the plugin is initialized.
  final bool verifyNotificationIntents;
}
