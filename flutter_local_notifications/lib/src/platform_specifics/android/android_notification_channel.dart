import 'dart:typed_data';
import 'dart:ui';

import 'enums.dart';
import 'notification_sound.dart';

class AndroidNotificationChannel {
  const AndroidNotificationChannel(
    this.channelId,
    this.channelName,
    this.channelDescription, {
    this.importance = Importance.Default,
    this.playSound = true,
    this.sound,
    this.enableVibration = true,
    this.vibrationPattern,
    this.channelShowBadge = true,
    this.channelAction = AndroidNotificationChannelAction.CreateIfNotExists,
    this.enableLights = false,
    this.ledColor,
  });

  /// The channel's id.
  ///
  /// Required for Android 8.0+.
  final String channelId;

  /// The channel's name.
  ///
  /// Required for Android 8.0+.
  final String channelName;

  /// The channel's description.
  ///
  /// Required for Android 8.0+.
  final String channelDescription;

  /// The importance of the notification.
  final Importance importance;

  /// Indicates if a sound should be played when the notification is displayed.
  ///
  /// For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final bool playSound;

  /// The sound to play for the notification.
  ///
  /// Requires setting [playSound] to true for it to work.
  /// If [playSound] is set to true but this is not specified then the default sound is played.
  /// For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final AndroidNotificationSound sound;

  /// Indicates if vibration should be enabled when the notification is displayed.
  ///
  /// For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final bool enableVibration;

  /// Indicates if lights should be enabled when the notification is displayed.
  ///
  /// For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final bool enableLights;

  /// Configures the vibration pattern.
  ///
  /// Requires setting [enableVibration] to true for it to work.
  /// For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final Int64List vibrationPattern;

  /// Sets the light color of the notification.
  ///
  /// For Android 8.0+, this is tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final Color ledColor;

  /// The action to take for managing notification channels.
  ///
  /// Defaults to creating the notification channel using the provided details if it doesn't exist
  final AndroidNotificationChannelAction channelAction;

  /// Whether notifications posted to this channel can appear as application icon badges in a Launcher
  final bool channelShowBadge;

  /// Creates a [Map] object that describes the [AndroidNotificationChannel] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'channelShowBadge': channelShowBadge,
      'channelAction': channelAction?.index,
      'importance': importance.value,
      'playSound': playSound,
      'enableVibration': enableVibration,
      'vibrationPattern': vibrationPattern,
      'enableLights': enableLights,
      'ledColorAlpha': ledColor?.alpha,
      'ledColorRed': ledColor?.red,
      'ledColorGreen': ledColor?.green,
      'ledColorBlue': ledColor?.blue,
    }..addAll(_convertSoundToMap());
  }

  Map<String, dynamic> _convertSoundToMap() {
    if (sound is RawResourceAndroidNotificationSound) {
      return <String, dynamic>{
        'sound': sound.sound,
        'soundSource': AndroidNotificationSoundSource.RawResource.index,
      };
    } else if (sound is UriAndroidNotificationSound) {
      return <String, dynamic>{
        'sound': sound.sound,
        'soundSource': AndroidNotificationSoundSource.Uri.index,
      };
    } else {
      return <String, dynamic>{};
    }
  }
}
