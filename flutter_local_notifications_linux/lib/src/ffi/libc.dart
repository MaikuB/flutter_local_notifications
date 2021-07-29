import 'dart:ffi' as ffi;

import 'dart:io' show Platform;

/// FFI binding for C library
class Libc {
  /// Constructs an instance of [Libc].
  factory Libc() => _libc;

  Libc._() {
    String path = 'libc.so.6';
    if (Platform.isMacOS) {
      path = '/usr/lib/libSystem.dylib';
    }
    if (Platform.isWindows) {
      path = r'primitives_library\Debug\primitives.dll';
    }
    dylib = ffi.DynamicLibrary.open(path);
  }

  static final Libc _libc = Libc._();

  /// A dynamically loaded C library.
  late ffi.DynamicLibrary dylib;
}
