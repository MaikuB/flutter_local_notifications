import 'dart:io';

/// Mockable file system representation
// ignore: one_member_abstracts
abstract class FileSystem {
  /// Returns a [File], that referred to the given [path]
  File open(String path);
}

/// A real implementation of [FileSystem]
class LocalFileSystem implements FileSystem {
  @override
  File open(String path) => File(path);
}
