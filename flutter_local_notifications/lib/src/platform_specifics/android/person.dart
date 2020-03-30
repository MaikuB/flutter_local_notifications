import 'package:flutter_local_notifications/src/platform_specifics/android/icon.dart';

import 'enums.dart';

/// Details of a person e.g. someone who sent a message.
class Person {
  /// Whether or not this person represents a machine rather than a human.
  final bool bot;

  /// Icon for this person.
  final AndroidIcon icon;

  /// Whether or not this is an important person.
  final bool important;

  /// Unique identifier for this person.
  final String key;

  /// Name of this person.
  final String name;

  /// Uri for this person.
  final String uri;

  Person({
    this.bot,
    this.icon,
    this.important,
    this.key,
    this.name,
    this.uri,
  });

  /// Creates a [Map] object that describes the [Person] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bot': bot,
      'important': important,
      'key': key,
      'name': name,
      'uri': uri
    }..addAll(_convertIconToMap());
  }

  Map<String, dynamic> _convertIconToMap() {
    if (icon is DrawableResourceAndroidIcon) {
      return <String, dynamic>{
        'icon': icon.icon,
        'iconSource': AndroidIconSource.DrawableResource.index,
      };
    } else if (icon is BitmapFilePathAndroidIcon) {
      return <String, dynamic>{
        'icon': icon.icon,
        'iconSource': AndroidIconSource.BitmapFilePath.index,
      };
    } else if (icon is ContentUriAndroidIcon) {
      return <String, dynamic>{
        'icon': icon.icon,
        'iconSource': AndroidIconSource.ContentUri.index,
      };
    } else if (icon is BitmapAssetAndroidIcon) {
      return <String, dynamic>{
        'icon': icon.icon,
        'iconSource': AndroidIconSource.BitmapAsset.index,
      };
    } else {
      return <String, dynamic>{};
    }
  }
}
