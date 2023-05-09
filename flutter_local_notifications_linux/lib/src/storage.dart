import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'file_system.dart';
import 'notification_info.dart';
import 'platform_info.dart';

const String _kFileName = 'notification_plugin_cache.json';

/// Represents a persisten storage for the notifications info,
/// see [LinuxNotificationInfo].
/// The storage data exists within the user session.
class NotificationStorage {
  /// Constructs an instance of of [NotificationStorageImpl].
  NotificationStorage({
    LinuxPlatformInfo? platformInfo,
    FileSystem? fs,
  })  : _platformInfo = platformInfo ?? LinuxPlatformInfo(),
        _fs = fs ?? LocalFileSystem();

  final LinuxPlatformInfo _platformInfo;
  final FileSystem _fs;

  _Cache? _cachedInfo;

  /// Get all notifications.
  Future<List<LinuxNotificationInfo>> getAll() async {
    final _Cache cache = await _readInfoMap();
    return cache.toImmutableMap().values.toList();
  }

  /// Get notification by [LinuxNotificationInfo.systemId].
  Future<LinuxNotificationInfo?> getById(int id) async {
    final _Cache cache = await _readInfoMap();
    return cache.getById(id);
  }

  /// Insert notification to the storage.
  /// Returns `true` if the operation succeeded.
  Future<bool> insert(LinuxNotificationInfo notification) async {
    final _Cache cache = await _readInfoMap();
    cache.insert(notification);
    return _writeInfoList(cache.values.toList());
  }

  /// Remove notification from the storage by [LinuxNotificationInfo.id].
  /// Returns `true` if the operation succeeded.
  Future<bool> removeById(int id) async {
    final _Cache cache = await _readInfoMap();
    cache.removeById(id);
    return _writeInfoList(cache.values.toList());
  }

  /// Remove notification from the storage by [idList].
  /// Returns `true` if the operation succeeded.
  Future<bool> removeByIdList(List<int> idList) async {
    final _Cache cache = await _readInfoMap();
    // ignore: prefer_foreach
    for (final int id in idList) {
      cache.removeById(id);
    }
    return _writeInfoList(cache.values.toList());
  }

  /// Force read info from the disk to the cache.
  Future<void> forceReloadCache() async {
    _cachedInfo = await _readFromCache();
  }

  Future<File?> _getStorageFile() async {
    final LinuxPlatformInfoData data = await _platformInfo.getAll();
    final String? dir = data.runtimePath;
    if (dir == null) {
      return null;
    }
    return _fs.open(path.join(dir, _kFileName));
  }

  /// Gets a [LinuxNotificationInfo] from the stored file.
  /// Once read, the data are maintained in memory.
  Future<_Cache> _readInfoMap() async {
    if (_cachedInfo != null) {
      return _cachedInfo!;
    }
    return _cachedInfo = await _readFromCache();
  }

  Future<_Cache> _readFromCache() async {
    final _Cache cache = _Cache();
    final File? storageFile = await _getStorageFile();
    if (storageFile != null && storageFile.existsSync()) {
      final String jsonStr = storageFile.readAsStringSync();
      if (jsonStr.isNotEmpty) {
        final dynamic json = jsonDecode(jsonStr);
        if (json is List) {
          for (final dynamic j in json) {
            final LinuxNotificationInfo info =
                LinuxNotificationInfo.fromJson(j);
            cache.insert(info);
          }
        } else {
          cache.insert(LinuxNotificationInfo.fromJson(json));
        }
      }
    }
    return cache;
  }

  /// Writes info list to disk. Returns [true] if the operation succeeded.
  Future<bool> _writeInfoList(List<LinuxNotificationInfo> infoList) async {
    try {
      final File? storageFile = await _getStorageFile();
      if (storageFile == null) {
        return false;
      }
      if (!storageFile.existsSync()) {
        storageFile.createSync(recursive: true);
      }
      final String jsonStr = jsonEncode(infoList);
      storageFile.writeAsStringSync(jsonStr);
    } on IOException catch (e) {
      // ignore: avoid_print
      print('Error saving preferences to disk: $e');
      return false;
    }
    return true;
  }
}

class _Cache {
  _Cache() : _infoMap = <int, LinuxNotificationInfo>{};

  final Map<int, LinuxNotificationInfo> _infoMap;

  LinuxNotificationInfo? getById(int? id) => _infoMap[id];

  void insert(LinuxNotificationInfo info) => _infoMap[info.id] = info;

  void removeById(int id) => _infoMap.remove(id);

  Iterable<LinuxNotificationInfo> get values => _infoMap.values;

  Map<int, LinuxNotificationInfo> toImmutableMap() =>
      UnmodifiableMapView<int, LinuxNotificationInfo>(_infoMap);
}
