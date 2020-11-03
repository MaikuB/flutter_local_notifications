import 'dart:core';
import 'dart:typed_data';

import 'enums.dart';

abstract class LinuxIcon {
  Object get content;
  LinuxIconSource get source;
}

class LinuxFileIcon implements LinuxIcon {
  const LinuxFileIcon(this.path);

  final String path;

  @override
  Object get content => path;

  @override
  LinuxIconSource get source => LinuxIconSource.file;
}

class BytesLinuxIcon implements LinuxIcon {
  const BytesLinuxIcon(this.data);

  final Uint8List data;

  @override
  Object get content => data;

  @override
  LinuxIconSource get source => LinuxIconSource.bytes;
}

class ThemeLinuxIcon implements LinuxIcon {
  const ThemeLinuxIcon(this.name);

  final String name;

  @override
  Object get content => name;

  @override
  LinuxIconSource get source => LinuxIconSource.theme;
}
