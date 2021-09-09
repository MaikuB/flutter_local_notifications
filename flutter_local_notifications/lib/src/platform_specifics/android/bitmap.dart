import 'dart:convert';
import 'dart:typed_data';

import 'enums.dart';

/// Represents a bitmap on Android.
abstract class AndroidBitmap<T> {
  /// The location of the bitmap.
  T get data;

  /// The subclass source type
  AndroidBitmapSource get source;
}

/// Represents a drawable resource belonging to the Android application that
/// should be used as a bitmap on Android.
class DrawableResourceAndroidBitmap implements AndroidBitmap<String> {
  /// Constructs an instance of [DrawableResourceAndroidBitmap].
  const DrawableResourceAndroidBitmap(this._bitmap);

  final String _bitmap;

  /// The name of the drawable resource.
  ///
  /// For example if the drawable resource is located at `res/drawable/app_icon.png`, the bitmap should be `app_icon`
  @override
  String get data => _bitmap;

  @override
  AndroidBitmapSource get source => AndroidBitmapSource.drawable;
}

/// Represents a file path that should be used for a bitmap on Android.
class FilePathAndroidBitmap implements AndroidBitmap<String> {
  /// Constructs an instance of [FilePathAndroidBitmap].
  const FilePathAndroidBitmap(this._bitmap);

  final String _bitmap;

  /// A file path on the Android device that refers to the location of the
  /// bitmap.
  @override
  String get data => _bitmap;

  @override
  AndroidBitmapSource get source => AndroidBitmapSource.filePath;
}

/// Represents a base64 encoded AndroidBitmap.
class ByteArrayAndroidBitmap implements AndroidBitmap<Uint8List> {
  /// Constructs an instance of [ByteArrayAndroidBitmap].
  const ByteArrayAndroidBitmap(this._bitmap);

  /// Constructs an instance of [ByteArrayAndroidBitmap] from a base64 string.
  factory ByteArrayAndroidBitmap.fromBase64String(String base64Image) =>
      ByteArrayAndroidBitmap(base64Decode(base64Image));

  final Uint8List _bitmap;

  /// A base64 encoded Bitmap string.
  @override
  Uint8List get data => _bitmap;

  @override
  AndroidBitmapSource get source => AndroidBitmapSource.byteArray;
}
