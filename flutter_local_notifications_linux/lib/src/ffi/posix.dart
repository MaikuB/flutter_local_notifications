import 'dart:ffi' as ffi;

import 'libc.dart';

// ignore_for_file: avoid_private_typedef_functions

/// Get the process ID of the calling process.
int getpid() {
  _getpid ??= Libc().dylib.lookupFunction<_CGetpid, _DartGetpid>('getpid');
  return _getpid!();
}

_DartGetpid? _getpid;

/// Return the session ID of the given process.
int getsid(int pid) {
  _getsid ??= Libc().dylib.lookupFunction<_CGetsid, _DartGetsid>('getsid');
  return _getsid!(pid);
}

_DartGetsid? _getsid;

/// Get the real user ID of the calling process.
int getuid() {
  _getuid ??= Libc().dylib.lookupFunction<_CGetuid, _DartGetuid>('getuid');
  return _getuid!();
}

_DartGetuid? _getuid;

typedef _DartGetpid = int Function();

typedef _CGetpid = ffi.Int32 Function();

typedef _DartGetsid = int Function(int pid);

typedef _CGetsid = ffi.Int32 Function(ffi.Int32 pid);

typedef _DartGetuid = int Function();

typedef _CGetuid = ffi.Uint32 Function();
