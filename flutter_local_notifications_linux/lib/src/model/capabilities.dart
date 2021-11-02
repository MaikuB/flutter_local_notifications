import 'package:flutter/foundation.dart';

import 'initialization_settings.dart';
import 'notification_details.dart';
import 'sound.dart';

// TODO(proninyaroslav): add actions

/// Represents capabilities, implemented by the Linux notification server.
@immutable
class LinuxServerCapabilities {
  /// Constructs an instance of [LinuxServerCapabilities]
  const LinuxServerCapabilities({
    required this.otherCapabilities,
    required this.body,
    required this.bodyHyperlinks,
    required this.bodyImages,
    required this.bodyMarkup,
    required this.iconMulti,
    required this.iconStatic,
    required this.persistence,
    required this.sound,
  });

  /// Set of unknown capabilities.
  /// Vendor-specific capabilities may be specified as long as they start with
  /// `x-vendor`. For example, `x-gnome-foo-cap`. Capability names must not
  /// contain spaces. They are limited to alpha-numeric characters and
  /// dashes ("-")
  final Set<String> otherCapabilities;

  /// Supports body text. Some implementations may only show the title
  /// (for instance, onscreen displays, marquee/scrollers).
  final bool body;

  /// The server supports hyperlinks in the notifications.
  final bool bodyHyperlinks;

  /// The server supports images in the notifications.
  final bool bodyImages;

  /// Supports markup in the body text. The markup is XML-based, and consists
  /// of a small subset of HTML along with a few additional tags.
  /// For more information, see Desktop Notifications Specification https://specifications.freedesktop.org/notification-spec/latest/ar01s04.html
  /// If marked up text is sent to a server
  /// that does not give this cap, the markup will show through as regular text
  /// so must be stripped clientside.
  final bool bodyMarkup;

  /// The server will render an animation of all the frames in a given
  /// image array. The client may still specify multiple frames even if this
  /// cap and/or [iconStatic] is missing, however the server is free to ignore
  /// them and use only the primary frame.
  final bool iconMulti;

  /// Supports display of exactly 1 frame of any given image array.
  /// This value is mutually exclusive with [iconMulti], it is a protocol
  /// error for the server to specify both.
  final bool iconStatic;

  /// The server supports persistence of notifications. Notifications will be
  /// retained until they are acknowledged or removed by the user or
  /// recalled by the sender. The presence of this capability allows clients to
  /// depend on the server to ensure a notification is seen and eliminate
  /// the need for the client to display a reminding function
  /// (such as a status icon) of its own.
  final bool persistence;

  /// The server supports sounds on notifications. If returned, the server must
  /// support the [AssetsLinuxSound], [LinuxNotificationDetails.suppressSound]
  /// and [LinuxInitializationSettings.defaultSuppressSound].
  final bool sound;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LinuxServerCapabilities &&
        setEquals(other.otherCapabilities, otherCapabilities) &&
        other.body == body &&
        other.bodyHyperlinks == bodyHyperlinks &&
        other.bodyImages == bodyImages &&
        other.bodyMarkup == bodyMarkup &&
        other.iconMulti == iconMulti &&
        other.iconStatic == iconStatic &&
        other.persistence == persistence &&
        other.sound == sound;
  }

  @override
  int get hashCode =>
      otherCapabilities.hashCode ^
      body.hashCode ^
      bodyHyperlinks.hashCode ^
      bodyImages.hashCode ^
      bodyMarkup.hashCode ^
      iconMulti.hashCode ^
      iconStatic.hashCode ^
      persistence.hashCode ^
      sound.hashCode;

  /// Creates a copy of this object,
  /// but with the given fields replaced with the new values.
  LinuxServerCapabilities copyWith({
    Set<String>? otherCapabilities,
    bool? body,
    bool? bodyHyperlinks,
    bool? bodyImages,
    bool? bodyMarkup,
    bool? iconMulti,
    bool? iconStatic,
    bool? persistence,
    bool? sound,
  }) =>
      LinuxServerCapabilities(
        otherCapabilities: otherCapabilities ?? this.otherCapabilities,
        body: body ?? this.body,
        bodyHyperlinks: bodyHyperlinks ?? this.bodyHyperlinks,
        bodyImages: bodyImages ?? this.bodyImages,
        bodyMarkup: bodyMarkup ?? this.bodyMarkup,
        iconMulti: iconMulti ?? this.iconMulti,
        iconStatic: iconStatic ?? this.iconStatic,
        persistence: persistence ?? this.persistence,
        sound: sound ?? this.sound,
      );

  @override
  String toString() => 'LinuxServerCapabilities(otherCapabilities: '
      '$otherCapabilities, body: $body, bodyHyperlinks: $bodyHyperlinks, '
      'bodyImages: $bodyImages, bodyMarkup: $bodyMarkup, '
      'iconMulti: $iconMulti, iconStatic: $iconStatic, '
      'persistence: $persistence, sound: $sound)';
}
