import 'dart:core';
import 'dart:typed_data';

import 'enums.dart';

/// Represents an icon on Linux.
abstract class LinuxIcon {
  /// Implementation-defined icon content.
  Object get content;

  /// Defines the semantic of content.
  LinuxIconSource get source;
}

/// Represents an icon from image file path or uri.
class FileLinuxIcon implements LinuxIcon {
  /// Construct an instance of [FileLinuxIcon].
  const FileLinuxIcon(this.path);

  /// Image file path or uri.
  final String path;

  @override
  Object get content => path;

  @override
  LinuxIconSource get source => LinuxIconSource.file;
}

/// Represents an icon from binary data.
/// The binary data should be in an image file format which supported by glib,
/// such as common formats like jpg and png.
class ByteDataLinuxIcon implements LinuxIcon {
  /// Construct an instance of [ByteDataLinuxIcon].
  const ByteDataLinuxIcon(this.data);

  /// The binary data
  final Uint8List data;

  @override
  Object get content => data;

  @override
  LinuxIconSource get source => LinuxIconSource.byteData;
}

/// Represents an icon by name, which indicated an icon from a theme.
/// See https://developer.gnome.org/gio/stable/GThemedIcon.html for more help.
class ThemeLinuxIcon implements LinuxIcon {
  /// Construct an instance of [ThemeLinuxIcon].
  const ThemeLinuxIcon(this.name);

  /// The name of the icon
  final String name;

  @override
  Object get content => name;

  @override
  LinuxIconSource get source => LinuxIconSource.theme;
}
