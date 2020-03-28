/// Represents a bitmap on Android.
abstract class AndroidBitmap {
  /// The location of the bitmap.
  String get bitmap;
}

/// Represents a bitmap on Android that is a drawable resource belonging to an Android application.
class AndroidDrawableResourceBitmap extends AndroidBitmap {
  AndroidDrawableResourceBitmap(this._bitmap);

  final String _bitmap;

  /// The name of the drawable resource.
  ///
  /// For example if the drawable resource is located at `res/drawable/app_icon.png`, the bitmap should be `app_icon`
  @override
  String get bitmap => _bitmap;
}

/// Represents a bitmap on Android that can be referenced to using a file path.
class AndroidFilePathBitmap extends AndroidBitmap {
  AndroidFilePathBitmap(this._bitmap);

  final String _bitmap;

  /// A file path on the Android device that refers to the location of the bitmap.
  @override
  String get bitmap => _bitmap;
}
