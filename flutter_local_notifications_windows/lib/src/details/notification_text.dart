import 'notification_part.dart';

/// Where text can be placed in a Windows notification.
enum WindowsTextPlacement {
  /// Shown at the bottom of the notification body in smaller text.
  attribution,
}

/// Text in a Windows notification.
///
/// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-text
class WindowsNotificationText extends WindowsNotificationPart {
  /// Creates text for a Windows notification.
  const WindowsNotificationText({
    required this.text,
    this.centerIfCall = false,
    this.isCaption = false,
    this.placement,
    this.languageCode,
  });

  /// The text being displayed.
  final String text;

  /// Whether to center this text. Only relevant if in an incoming call.
  final bool centerIfCall;

  /// Whether the text should be smaller like a caption.
  final bool isCaption;

  /// The placement of this text.
  ///
  /// The default placement (null) is in the main body of the notification.
  final WindowsTextPlacement? placement;

  /// The language of this text.
  final String? languageCode;
}
