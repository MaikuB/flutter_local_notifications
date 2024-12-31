import 'dart:io';

import 'package:flutter/foundation.dart';

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
///
  /// Windows supports a few different URI types, and supports them differently
/// depending on if your app is packaged as an MSIX. Refer to the following:
///
/// | URI | Debug | Release (EXE) | Release (MSIX) |
/// |--------|--------|--------|--------|
/// | `file:///` | ✅ | ✅| ✅ |
/// | `http(s)://` | ❌ | ❌ | ✅ |
/// | `ms-appx://` | ❌ | ❌ | ✅ |
/// | `assetUri()` | ✅ | ❌ | ✅ |
///
/// Each URI type has different uses:
/// - For images that are known ahead of time and can be used as Flutter
/// assets, use [assetUri], which will return a file URI in debug
/// mode and an `ms-appx` URI in release mode, for the best of both worlds.
/// - For images from the web, use an `https` or `http` URI, but note that
/// these only work in MSIX apps. If you need a network image without using
/// MSIX, consider downloading it directly and using a file URI after.
/// - For images that come from the user's device, or have to be retrieved at
/// runtime, use a file URI, but as always, be aware of how paths might change
/// from your device to your users. Note that file URIs must be absolute
/// paths, not relative, which can be complicated if referring to MSIX assets.
/// - For images that are bundled with your app but not through Flutter, use
/// an `ms-appx` URI.
class WindowsImage extends WindowsNotificationPart {
  /// Creates a Windows notification image from an image URI.
  const WindowsImage(
    this.uri, {
    required this.altText,
    this.addQueryParams = false,
    this.placement,
    this.crop,
  });

  /// Creates a URI for a [Flutter asset](https://docs.flutter.dev/ui/assets/assets-and-images#loading-images).
  ///
  /// This URI resolves to a file URI in debug mode, and an `ms-appx` URI in
  /// release mode. Note that this function just assumes your release build will
  /// be packaged as an MSIX. It is highly recommended that you use an MSIX for
  /// your release, but if you can't, don't use this function.
  static Uri assetUri(String assetName) => kDebugMode
    ? Uri.file(File(assetName).absolute.path, windows: true)
    : Uri.parse('ms-appx:///data/flutter_assets/$assetName');

  /// Whether Windows should add URL query parameters when fetching the image.
  final bool addQueryParams;

  /// A description of the image to be used by assistive technology.
  final String altText;

  /// The source of the image.
  final Uri uri;

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
