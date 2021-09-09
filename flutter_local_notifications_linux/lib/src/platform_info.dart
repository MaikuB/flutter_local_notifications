import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:xdg_directories/xdg_directories.dart' as xdg;

import 'posix.dart';

/// Provides Linux platform-specific info
class LinuxPlatformInfo {
  final Posix _posix = Posix();

  /// Returns all platform-specific info
  Future<LinuxPlatformInfoData> getAll() async {
    try {
      final String exePath =
          await File('/proc/self/exe').resolveSymbolicLinks();
      final String processName = path.basenameWithoutExtension(exePath);
      final String appPath = path.dirname(exePath);
      final String assetPath = path.join(appPath, 'data', 'flutter_assets');
      final String versionPath = path.join(assetPath, 'version.json');
      final Map<String, dynamic> json = jsonDecode(
        await File(versionPath).readAsString(),
      );
      late final Directory runtimeDir;
      if (xdg.runtimeDir == null) {
        final int pid = _posix.getpid();
        final int userId = _posix.getuid();
        final int sessionId = _posix.getsid(pid);
        final Map<String, String> env = Platform.environment;
        final String? tmpdir = env['TMPDIR'];
        runtimeDir = Directory(
          path.join(
            tmpdir == null || tmpdir.isEmpty ? '/tmp' : tmpdir,
            processName,
            '$userId',
            '$sessionId',
          ),
        );
      } else {
        runtimeDir = Directory(path.join(xdg.runtimeDir!.path, processName));
      }
      if (!runtimeDir.existsSync()) {
        await runtimeDir.create(recursive: true);
      }

      return LinuxPlatformInfoData(
        appName: json['app_name'] ?? '',
        assetsPath: assetPath,
        runtimePath: runtimeDir.path,
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return const LinuxPlatformInfoData();
    }
  }
}

/// Represents Linux platform-specific info
class LinuxPlatformInfoData {
  /// Constructs an instance of [LinuxPlatformInfoData].
  const LinuxPlatformInfoData({
    this.appName,
    this.assetsPath,
    this.runtimePath,
  });

  /// Application name
  final String? appName;

  /// Path to the Flutter Assets directory
  final String? assetsPath;

  /// The base directory relative to which user-specific runtime files and
  /// other file objects should be placed
  /// (Corresponds to `$XDG_RUNTIME_DIR` environment variable).
  /// Please see XDG Base Directory Specification https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
  /// If `$XDG_RUNTIME_DIR` is not set, the following directory structure is used: `/[$TMPDIR|tmp]/APP_NAME/USER_ID/SESSION_ID`
  final String? runtimePath;
}
