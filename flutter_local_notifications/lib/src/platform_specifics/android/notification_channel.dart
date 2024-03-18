import 'dart:typed_data';
import 'dart:ui';

import 'enums.dart';
import 'notification_sound.dart';

/// Settings for Android notification channels.
class AndroidNotificationChannel {
  /// Constructs an instance of [AndroidNotificationChannel].
  const AndroidNotificationChannel(
    this.id,
    this.name, {
    this.description,
    this.groupId,
    this.importance = Importance.defaultImportance,
    this.playSound = true,
    this.sound,
    this.enableVibration = true,
    this.vibrationPattern,
    this.showBadge = true,
    this.enableLights = false,
    this.ledColor,
    this.audioAttributesUsage = AudioAttributesUsage.notification,
  });

  /// The channel's id.
  final String id;

  /// The channel's name.
  final String name;

  /// The channel's description.
  final String? description;

  /// The id of the group that the channel belongs to.
  final String? groupId;

  /// The importance of the notification.
  final Importance importance;

  /// Indicates if a sound should be played when the notification is displayed.
  ///
  /// Tied to the specified channel and cannot be changed after the channel has
  /// been created for the first time.
  final bool playSound;

  /// The sound to play for the notification.
  ///
  /// Requires setting [playSound] to true for it to work.
  /// If [playSound] is set to true but this is not specified then the default
  /// sound is played. Tied to the specified channel and cannot be changed
  /// after the channel has been created for the first time.
  final AndroidNotificationSound? sound;

  /// Indicates if vibration should be enabled when the notification is
  /// displayed.
  //
  /// Tied to the specified channel and cannot be changed after the channel has
  /// been created for the first time.
  final bool enableVibration;

  /// Indicates if lights should be enabled when the notification is displayed.
  ///
  /// Tied to the specified channel and cannot be changed after the channel has
  /// been created for the first time.
  final bool enableLights;

  /// Configures the vibration pattern.
  ///
  /// Requires setting [enableVibration] to true for it to work.
  /// Tied to the specified channel and cannot be changed after the channel has
  /// been created for the first time.
  final Int64List? vibrationPattern;

  /// Specifies the light color of the notification.
  ///
  /// Tied to the specified channel and cannot be changed after the channel has
  /// been created for the first time.
  final Color? ledColor;

  /// Whether notifications posted to this channel can appear as application
  /// icon badges in a Launcher
  final bool showBadge;

  /// The attribute describing what is the intended use of the audio signal,
  /// such as alarm or ringtone set in [`AudioAttributes.Builder`](https://developer.android.com/reference/android/media/AudioAttributes.Builder#setUsage(int))
  /// https://developer.android.com/reference/android/media/AudioAttributes
  final AudioAttributesUsage audioAttributesUsage;
}
