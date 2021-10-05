import 'dart:convert';
import 'dart:typed_data';

import 'enums.dart';

/// Represents an icon on Android.
abstract class AndroidIcon<T> {
  /// The location to the icon;
  T get data;

  /// The subclass source type
  AndroidIconSource get source;
}

/// Represents a drawable resource belonging to the Android application that
/// should be used as an icon on Android.
class DrawableResourceAndroidIcon implements AndroidIcon<String> {
  /// Constructs an instance of [DrawableResourceAndroidIcon].
  const DrawableResourceAndroidIcon(this._icon);

  final String _icon;

  /// The name of the drawable resource.
  ///
  /// For example if the drawable resource is located at `res/drawable/app_icon.png`, the icon should be `app_icon`
  @override
  String get data => _icon;

  @override
  AndroidIconSource get source => AndroidIconSource.drawableResource;
}

/// Represents a file path to a bitmap that should be used for as an icon on
/// Android.
class BitmapFilePathAndroidIcon implements AndroidIcon<String> {
  /// Constructs an instance of [BitmapFilePathAndroidIcon].
  const BitmapFilePathAndroidIcon(this._icon);

  final String _icon;

  /// A file path on the Android device that refers to the location of the icon.
  @override
  String get data => _icon;

  @override
  AndroidIconSource get source => AndroidIconSource.bitmapFilePath;
}

/// Represents a content URI that should be used for as an icon on Android.
class ContentUriAndroidIcon implements AndroidIcon<String> {
  /// Constructs an instance of [ContentUriAndroidIcon].
  const ContentUriAndroidIcon(this._icon);

  final String _icon;

  /// A content URI that refers to the location of the icon.
  @override
  String get data => _icon;

  @override
  AndroidIconSource get source => AndroidIconSource.contentUri;
}

/// Represents a bitmap asset belonging to the Flutter application that should
/// be used for as an icon on Android.
class FlutterBitmapAssetAndroidIcon implements AndroidIcon<String> {
  /// Constructs an instance of [FlutterBitmapAssetAndroidIcon].
  const FlutterBitmapAssetAndroidIcon(this._icon);

  final String _icon;

  /// Path to the Flutter asset that refers to the location of the icon.
  ///
  /// For example, if the following asset is declared in the Flutter
  /// application's `pubspec.yaml` file
  ///
  /// ```
  /// assets:
  ///   - icons/coworker.png
  /// ```
  ///
  /// then the path to the asset would be `icons/coworker.png`.
  @override
  String get data => _icon;

  @override
  AndroidIconSource get source => AndroidIconSource.flutterBitmapAsset;
}

/// Represents a bitmap asset belonging to the Flutter application that should
/// be used for as an icon on Android.
class ByteArrayAndroidIcon implements AndroidIcon<Uint8List> {
  /// Constructs an instance of [FlutterBitmapAssetAndroidIcon].
  const ByteArrayAndroidIcon(this._icon);

  /// Constructs an instance of [ByteArrayAndroidIcon] from a base64 string.
  factory ByteArrayAndroidIcon.fromBase64String(String base64Image) =>
      ByteArrayAndroidIcon(base64Decode(base64Image));

  final Uint8List _icon;

  /// Byte array data of the icon.
  @override
  Uint8List get data => _icon;

  @override
  AndroidIconSource get source => AndroidIconSource.byteArray;
}
