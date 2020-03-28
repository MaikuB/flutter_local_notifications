/// Represents an icon on Android.
abstract class AndroidIcon {
  /// The location to the icon;
  String get icon;
}

/// Represents a drawable resource belonging to the Android application that should be used as an icon on Android.
class DrawableResourceAndroidIcon extends AndroidIcon {
  DrawableResourceAndroidIcon(this._icon);

  final String _icon;

  /// The name of the drawable resource.
  ///
  /// For example if the drawable resource is located at `res/drawable/app_icon.png`, the icon should be `app_icon`
  @override
  String get icon => _icon;
}

/// Represents a file path to a bitmap that should be used for as an icon on Android.
class BitmapFilePathAndroidIcon extends AndroidIcon {
  BitmapFilePathAndroidIcon(this._icon);

  final String _icon;

  /// A file path on the Android device that refers to the location of the icon.
  @override
  String get icon => _icon;
}

/// Represents a content URI that should be used for as an icon on Android.
class ContentUriAndroidIcon extends AndroidIcon {
  ContentUriAndroidIcon(this._icon);

  final String _icon;

  /// A content URI that refers to the location of the icon.
  @override
  String get icon => _icon;
}

/// Represents a bitmap asset belonging to the Flutter application that should be used for as an icon on Android.
class BitmapAssetAndroidIcon extends AndroidIcon {
  BitmapAssetAndroidIcon(this._icon);

  final String _icon;

  /// Path to the Flutter asset that refers to the location of the icon.
  ///
  /// For example, if the following asset is declared in the Flutter application's `pubspec.yaml` file
  ///
  /// ```
  /// assets:
  ///   - icons/coworker.png
  /// ```
  ///
  /// then the path to the asset would be `icons/coworker.png`.
  @override
  String get icon => _icon;
}
