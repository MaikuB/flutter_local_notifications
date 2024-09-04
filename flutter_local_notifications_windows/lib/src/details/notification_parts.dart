import 'dart:io';

/// A text or image element in a Windows notification.
///
/// Note: This should not be used for anything else as notification
/// groups can only contain text and images.
// This class needs to be abstract so [WindowsNotificationText] and
// [WindowsImage] can extend it. Specifically, this class is a marker
// type for classes that are valid as part of a [WindowsColumn].
// ignore: one_member_abstracts
sealed class WindowsNotificationPart {
  /// A const constructor.
  const WindowsNotificationPart();
}

/// Where a Windows notification image can be placed.
enum WindowsImagePlacement {
  /// The image replaces the app logo.
  appLogoOverride,

  /// The image is shown on top of the notification body.
  hero,
}

/// How a Windows notification image can be cropped.
enum WindowsImageCrop {
  /// The image is cropped into a circle.
  circle,
}

/// An image in a Windows notification.
class WindowsImage extends WindowsNotificationPart {
  /// Creates a Windows notification image.
  const WindowsImage.file(
    this.file, {
    required this.altText,
    this.addQueryParams = false,
    this.placement,
    this.crop,
  });

  /// Whether Windows should add URL query parameters when fetching the image.
  final bool addQueryParams;

  /// A description of the image to be used by assistive technology.
  final String altText;

  /// The source of the image.
  final File file;

  /// Where this image will be placed. Null indicates below the notification.
  final WindowsImagePlacement? placement;

  /// How the image will be cropped. Null indicates uncropped.
  final WindowsImageCrop? crop;
}

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
