import 'dart:typed_data';

import 'enums.dart';

/// Represents Linux notification icon.
abstract class LinuxNotificationIcon {
  /// Implementation-defined icon content.
  Object get content;

  /// Defines the type of icon.
  LinuxIconType get type;
}

/// Represents an icon from the Flutter Assets directory.
class AssetsLinuxIcon extends LinuxNotificationIcon {
  /// Constructs an instance of [AssetsLinuxIcon].
  AssetsLinuxIcon(this.relativePath);

  @override
  Object get content => relativePath;

  @override
  LinuxIconType get type => LinuxIconType.assets;

  /// Icon relative path inside the Flutter Assets directory
  final String relativePath;
}

/// Represents an icon from a raw image data bytes, see [LinuxRawIconData].
class ByteDataLinuxIcon extends LinuxNotificationIcon {
  /// Constructs an instance of [ByteDataLinuxIcon].
  ByteDataLinuxIcon(this.iconData);

  @override
  Object get content => iconData;

  @override
  LinuxIconType get type => LinuxIconType.byteData;

  /// Icon data
  final LinuxRawIconData iconData;
}

/// Represents a system theme icon.
/// See https://www.freedesktop.org/wiki/Specifications/icon-naming-spec/ for more help.
class ThemeLinuxIcon extends LinuxNotificationIcon {
  /// Constructs an instance of [ThemeLinuxIcon].
  ThemeLinuxIcon(this.name);

  @override
  Object get content => name;

  @override
  LinuxIconType get type => LinuxIconType.theme;

  /// Name in a freedesktop.org-compliant icon theme (not a GTK+ stock ID).
  final String name;
}

/// Represents an icon in the raw image data.
class LinuxRawIconData {
  /// Constructs an instance of [LinuxRawIconData].
  LinuxRawIconData({
    required this.data,
    required this.width,
    required this.height,
    int? rowStride,
    this.bitsPerSample = 8,
    this.channels = 3,
    this.hasAlpha = false,
  }) : rowStride = rowStride ?? ((width * channels * bitsPerSample) / 8).ceil();

  /// Raw data (decoded from the image format) for the image in bytes.
  final Uint8List data;

  /// Width of the image in pixels
  final int width;

  /// Height of the image in pixels
  final int height;

  /// The number of bytes per row in [data]
  final int rowStride;

  /// The number of bits in each color sample
  final int bitsPerSample;

  /// The number of channels in the image (e.g. 3 for RGB, 4 for RGBA).
  /// If [hasAlpha] is `true`, must be 4.
  final int channels;

  /// Determines if the image has an alpha channel
  final bool hasAlpha;
}
