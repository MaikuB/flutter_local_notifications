import 'dart:io';

import 'package:xml/xml.dart';

import 'notification_part.dart';

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
  WindowsImage.file(
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

  @override
  void toXml(XmlBuilder builder) => builder.element(
    'image',
    attributes: <String, String>{
      'src': Uri.file(file.absolute.path, windows: true).toString(),
      'alt': altText,
      'addImageQuery': addQueryParams.toString(),
      if (placement != null) 'placement': placement!.name,
      if (crop != null) 'hint-crop': crop!.name,
    },
  );
}
