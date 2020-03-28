/// Represents an Android notification sound.
abstract class AndroidNotificationSound {
  /// The location of the sound
  String get sound;
}

/// Used when a notification sound is a raw resource belonging to the Android application.
///
/// These resources would be found in the `res/raw` directory of the Android application
class RawResourceAndroidNotificationSound implements AndroidNotificationSound {
  RawResourceAndroidNotificationSound(this._sound);

  final String _sound;

  /// The name of the raw resource for the notification sound.
  @override
  String get sound => _sound;
}

/// Used when a notification sound that is on the Android device that is represented by a URI.
///
/// One way of obtaining such URIs is to use the native Android RingtoneManager APIs,
/// which may require developers to write their own to access the API.
class UriAndroidNotificationSound implements AndroidNotificationSound {
  UriAndroidNotificationSound(this._sound);

  final String _sound;

  /// The URI for the notification sound.
  @override
  String get sound => _sound;
}
