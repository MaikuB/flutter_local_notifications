import 'dart:io';

import 'package:flutter/foundation.dart';
import '../../flutter_local_notifications_windows.dart';

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
/// | `http(s)://` | ❌ | ❌ | ✅ |
/// | `ms-appx://` | ❌ | ❌ | ✅ |
/// | `file:///`   | ✅ | ✅ | 🟨 |
/// | `getAssetUri()` | ✅ | ✅ | ✅ |
///
/// Each URI type has different uses:
/// - For Flutter assets, use [getAssetUri], which return the correct file URI
/// for debug and release (exe) builds, and an `ms-appx` URI in MSIX builds.
/// - For images from the web, use an `https` or `http` URI, but note that
/// these only work in MSIX apps. If you need a network image without using
/// MSIX, consider downloading it directly and using a file URI after. Also
/// note that showing the notification will cause the image to be downloaded,
/// which could cause a small delay. Try to use small images.
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

  /// Returns a URI for a [Flutter asset](https://docs.flutter.dev/ui/assets/assets-and-images#loading-images).
  ///
  /// - In debug mode, resolves to a file URI to the asset itself
  /// - In non-MSIX release builds, resolves to a file URI to the bundled asset
  /// - In MSIX releases, resolves to an `ms-appx` URI from [Msix.getAssetUri].
  static Uri getAssetUri(String assetName) {
    if (kDebugMode) {
      return Uri.file(File(assetName).absolute.path, windows: true);
    } else if (MsixUtils.hasPackageIdentity()) {
      return MsixUtils.getAssetUri(assetName);
    } else {
      return Uri.file(
        File('data/flutter_assets/$assetName').absolute.path,
        windows: true,
      );
    }
  }

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
