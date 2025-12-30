import 'dart:ffi' as ffi;

/// Represents Linux POSIX calls.
class Posix {
  /// Constructs an instance of [Posix].
  Posix() {
    final ffi.DynamicLibrary dylib = ffi.DynamicLibrary.open('libc.so.6');
    getpid = dylib
        .lookup<ffi.NativeFunction<ffi.Int32 Function()>>('getpid')
        .asFunction();
    getsid = dylib
        .lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32 pid)>>('getsid')
        .asFunction();
    getuid = dylib
        .lookup<ffi.NativeFunction<ffi.Uint32 Function()>>('getuid')
        .asFunction();
  }

  /// Get the process ID of the calling process.
  late final int Function() getpid;

  /// Return the session ID of the given process.
  late final int Function(int pid) getsid;

  /// Get the real user ID of the calling process.
  late final int Function() getuid;
}
