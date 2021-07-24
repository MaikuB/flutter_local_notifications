import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_local_notifications/src/platform_specifics/android/enums.dart';

/// Represents a bitmap on Android.
abstract class AndroidBitmap {
  /// The location of the bitmap.
  Object get data;

  /// The subclass source type
  AndroidBitmapSource get source;
}

/// Represents a drawable resource belonging to the Android application that
/// should be used as a bitmap on Android.
class DrawableResourceAndroidBitmap implements AndroidBitmap {
  /// Constructs an instance of [DrawableResourceAndroidBitmap].
  const DrawableResourceAndroidBitmap(this._bitmap);

  final String _bitmap;

  /// The name of the drawable resource.
  ///
  /// For example if the drawable resource is located at `res/drawable/app_icon.png`, the bitmap should be `app_icon`
  @override
  Object get data => _bitmap;

  @override
  AndroidBitmapSource get source => AndroidBitmapSource.drawable;
}

/// Represents a file path that should be used for a bitmap on Android.
class FilePathAndroidBitmap implements AndroidBitmap {
  /// Constructs an instance of [FilePathAndroidBitmap].
  const FilePathAndroidBitmap(this._bitmap);

  final String _bitmap;

  /// A file path on the Android device that refers to the location of the
  /// bitmap.
  @override
  Object get data => _bitmap;

  @override
  AndroidBitmapSource get source => AndroidBitmapSource.filePath;
}

/// Represents a base64 encoded AndroidBitmap.
class ByteArrayAndroidBitmap implements AndroidBitmap {
  /// Constructs an instance of [ByteArrayAndroidBitmap].
  const ByteArrayAndroidBitmap(this._bitmap);

  factory ByteArrayAndroidBitmap.fromBase64String(String base64Image) => ByteArrayAndroidBitmap(base64Decode(base64Image));

  final Uint8List _bitmap;

  /// A base64 encoded Bitmap string.
  @override
  Object get data => _bitmap;

  @override
  AndroidBitmapSource get source => AndroidBitmapSource.byteArray;
}
