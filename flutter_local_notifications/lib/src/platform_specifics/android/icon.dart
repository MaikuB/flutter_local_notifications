/// Represents an icon on Android.
abstract class AndroidIcon {
  /// The location to the icon;
  String get icon;
}

/// Represents an icon on Android that is a drawable resource belonging to an Android application.
class AndroidDrawableResourceIcon extends AndroidIcon {
  AndroidDrawableResourceIcon(this._icon);

  final String _icon;

  /// The name of the drawable resource.
  ///
  /// For example if the drawable resource is located at `res/drawable/app_icon.png`, the icon should be `app_icon`
  @override
  String get icon => _icon;
}

/// Represents a bitmap icon on Android that can be referenced to using a file path.
class AndroidBitmapFilePathIcon extends AndroidIcon {
  AndroidBitmapFilePathIcon(this._icon);

  final String _icon;

  /// A file path on the Android device that refers to the location of the icon.
  @override
  String get icon => _icon;
}

/// Represents an icon on Android that can be referenced to using a content URI.
class AndroidContentUriIcon extends AndroidIcon {
  AndroidContentUriIcon(this._icon);

  final String _icon;

  /// A content URI that refers to the location of the icon.
  @override
  String get icon => _icon;
}

/// Represents an bitmap icon on Android that can be referenced to using a path to a Flutter asset.
class AndroidBitmapAssetIcon extends AndroidIcon {
  AndroidBitmapAssetIcon(this._icon);

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
