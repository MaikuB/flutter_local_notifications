import 'dart:typed_data';
import 'dart:ui';

import 'enums.dart';
import 'notification_sound.dart';

class AndroidNotificationChannel {
  const AndroidNotificationChannel(
    this.id,
    this.name,
    this.description, {
    this.importance = Importance.Default,
    this.playSound = true,
    this.sound,
    this.enableVibration = true,
    this.vibrationPattern,
    this.showBadge = true,
    this.enableLights = false,
    this.ledColor,
    this.channelAction = AndroidNotificationChannelAction.CreateIfNotExists,
  });

  /// The channel's id.
  final String id;

  /// The channel's name.
  final String name;

  /// The channel's description.
  final String description;

  /// The importance of the notification.
  final Importance importance;

  /// Indicates if a sound should be played when the notification is displayed.
  ///
  /// Tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final bool playSound;

  /// The sound to play for the notification.
  ///
  /// Requires setting [playSound] to true for it to work.
  /// If [playSound] is set to true but this is not specified then the default sound is played.
  /// Tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final AndroidNotificationSound sound;

  /// Indicates if vibration should be enabled when the notification is displayed.
  //
  /// Tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final bool enableVibration;

  /// Indicates if lights should be enabled when the notification is displayed.
  ///
  /// Tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final bool enableLights;

  /// Configures the vibration pattern.
  ///
  /// Requires setting [enableVibration] to true for it to work.
  /// Tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final Int64List vibrationPattern;

  /// Sets the light color of the notification.
  ///
  /// Tied to the specified channel cannot be changed afterward the channel has been created for the first time.
  final Color ledColor;

  /// Whether notifications posted to this channel can appear as application icon badges in a Launcher
  final bool showBadge;

  /// The action to take for managing notification channels.
  ///
  /// Defaults to creating the notification channel using the provided details if it doesn't exist
  final AndroidNotificationChannelAction channelAction;

  /// Creates a [Map] object that describes the [AndroidNotificationChannel] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'showBadge': showBadge,
      'importance': importance.value,
      'playSound': playSound,
      'enableVibration': enableVibration,
      'vibrationPattern': vibrationPattern,
      'enableLights': enableLights,
      'ledColorAlpha': ledColor?.alpha,
      'ledColorRed': ledColor?.red,
      'ledColorGreen': ledColor?.green,
      'ledColorBlue': ledColor?.blue,
      'channelAction': channelAction?.index,
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
