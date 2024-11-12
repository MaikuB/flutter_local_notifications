extension on Uri {
  String get filename => pathSegments.last;
  String get extension => pathSegments.last.split('.').last;
}

/// A preset sound for a Windows notification.
enum WindowsNotificationSound {
  /// The default sound.
  defaultSound('ms-winsoundevent:Notification.Default'),

  /// The IM sound.
  im('ms-winsoundevent:Notification.IM'),

  /// The Mail sound.
  mail('ms-winsoundevent:Notification.Mail'),

  /// The Reminder sound.
  reminder('ms-winsoundevent:Notification.Reminder'),

  /// The SMS sound.
  sms('ms-winsoundevent:Notification.SMS'),

  /// Alarm sound 1.
  alarm1('ms-winsoundevent:Notification.Looping.Alarm1'),

  /// Alarm sound 2.
  alarm2('ms-winsoundevent:Notification.Looping.Alarm2'),

  /// Alarm sound 3.
  alarm3('ms-winsoundevent:Notification.Looping.Alarm3'),

  /// Alarm sound 4.
  alarm4('ms-winsoundevent:Notification.Looping.Alarm4'),

  /// Alarm sound 5.
  alarm5('ms-winsoundevent:Notification.Looping.Alarm5'),

  /// Alarm sound 6.
  alarm6('ms-winsoundevent:Notification.Looping.Alarm6'),

  /// Alarm sound 7.
  alarm7('ms-winsoundevent:Notification.Looping.Alarm7'),

  /// Alarm sound 8.
  alarm8('ms-winsoundevent:Notification.Looping.Alarm8'),

  /// Alarm sound 9.
  alarm9('ms-winsoundevent:Notification.Looping.Alarm9'),

  /// Alarm sound 10.
  alarm10('ms-winsoundevent:Notification.Looping.Alarm10'),

  /// Call sound 1.
  call1('ms-winsoundevent:Notification.Looping.Call1'),

  /// Call sound 2.
  call2('ms-winsoundevent:Notification.Looping.Call2'),

  /// Call sound 3.
  call3('ms-winsoundevent:Notification.Looping.Call3'),

  /// Call sound 4.
  call4('ms-winsoundevent:Notification.Looping.Call4'),

  /// Call sound 5.
  call5('ms-winsoundevent:Notification.Looping.Call5'),

  /// Call sound 6.
  call6('ms-winsoundevent:Notification.Looping.Call6'),

  /// Call sound 7.
  call7('ms-winsoundevent:Notification.Looping.Call7'),

  /// Call sound 8.
  call8('ms-winsoundevent:Notification.Looping.Call8'),

  /// Call sound 9.
  call9('ms-winsoundevent:Notification.Looping.Call9'),

  /// Call sound 10.
  call10('ms-winsoundevent:Notification.Looping.Call10');

  const WindowsNotificationSound(this.name);

  /// The Windows API name for this sound.
  final String name;
}

/// Specifies custom audio to play during a notification.
class WindowsNotificationAudio {
  /// No sound will play during this notification.
  WindowsNotificationAudio.silent()
      : source = WindowsNotificationSound.defaultSound.name,
        shouldLoop = false,
        isSilent = true;

  /// Audio from a Windows preset. See [WindowsNotificationSound] for options.
  WindowsNotificationAudio.preset({
    required WindowsNotificationSound sound,
    this.shouldLoop = false,
  })  : isSilent = false,
        source = sound.name;

  /// Audio from a file. See [allowedSchemes] and [allowedExtensions].
  WindowsNotificationAudio.fromFile({
    required Uri file,
    this.shouldLoop = false,
  })  : isSilent = false,
        source = file.toFilePath() {
    if (!allowedSchemes.contains(file.scheme)) {
      throw ArgumentError.value(
        file.toString(),
        'WindowsNotificationAudio.file',
        'URI scheme must be one of the following schemes: $allowedSchemes',
      );
    }
    if (!file.filename.contains('.') ||
        !allowedExtensions.contains(file.extension)) {
      throw ArgumentError.value(
        file.toString(),
        'WindowsNotificationAudio.file',
        'File extension must be one of the following: $allowedExtensions',
      );
    }
  }

  /// Allowed Uri schemes for [WindowsNotificationAudio.fromFile].
  static const Set<String> allowedSchemes = <String>{'ms-appx', 'ms-resource'};

  /// Allowed file extensions for [WindowsNotificationAudio.fromFile].
  static const Set<String> allowedExtensions = <String>{
    'aac',
    'flac',
    'm4a',
    'mp3',
    'wav',
    'wma'
  };

  /// Whether this audio should loop.
  final bool shouldLoop;

  /// Whether this notification should be silent.
  final bool isSilent;

  /// The source of the audio.
  final String source;
}
