/// Represents a bitmap on Android.
abstract class AndroidBitmap {
  /// The location of the bitmap.
  String get bitmap;
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
  String get bitmap => _bitmap;
}

/// Represents a file path that should be used for a bitmap on Android.
class FilePathAndroidBitmap implements AndroidBitmap {
  /// Constructs an instance of [FilePathAndroidBitmap].
  const FilePathAndroidBitmap(this._bitmap);

  final String _bitmap;

  /// A file path on the Android device that refers to the location of the
  /// bitmap.
  @override
  String get bitmap => _bitmap;
}
