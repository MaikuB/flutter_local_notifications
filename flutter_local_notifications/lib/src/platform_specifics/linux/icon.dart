import 'dart:core';
import 'dart:typed_data';

import 'enums.dart';

/// Represents an icon on Linux.
abstract class LinuxIcon {
  Object get content;
  LinuxIconSource get source;
}

/// Represents an icon from image file path or uri
class FileLinuxIcon implements LinuxIcon {
  const FileLinuxIcon(this.path);

  final String path;

  @override
  Object get content => path;

  @override
  LinuxIconSource get source => LinuxIconSource.file;
}

/// Represents an icon from binary data
/// The binary data should be in an image file format which supported by glib, 
/// such as common formats like jpg and png
class ByteDataLinuxIcon implements LinuxIcon {
  const ByteDataLinuxIcon(this.data);

  final Uint8List data;

  @override
  Object get content => data;

  @override
  LinuxIconSource get source => LinuxIconSource.bytes;
}

/// Represents an icon by name, which indicated an icon from a theme
/// See https://developer.gnome.org/gio/stable/GThemedIcon.html for more help
class ThemeLinuxIcon implements LinuxIcon {
  const ThemeLinuxIcon(this.name);

  final String name;

  @override
  Object get content => name;

  @override
  LinuxIconSource get source => LinuxIconSource.theme;
}
