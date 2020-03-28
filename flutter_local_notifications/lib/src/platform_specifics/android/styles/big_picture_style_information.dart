import 'package:flutter_local_notifications/src/platform_specifics/android/bitmap.dart';

import 'default_style_information.dart';
import '../enums.dart';

/// Used to pass the content for an Android notification displayed using the big picture style.
class BigPictureStyleInformation extends DefaultStyleInformation {
  /// Overrides ContentTitle in the big form of the template.
  final String contentTitle;

  /// Set the first line of text after the detail section in the big form of the template.
  final String summaryText;

  /// Specifies if the overridden ContentTitle should have formatting applies through HTML markup.
  final bool htmlFormatContentTitle;

  /// Specifies if formatting should be applied to the first line of text after the detail section in the big form of the template.
  final bool htmlFormatSummaryText;

  /// The bitmap that will override the large icon when the big notification is shown.
  final AndroidBitmap largeIcon;

  /// The bitmap to be used as the payload for the BigPicture notification.
  final AndroidBitmap bigPicture;

  /// Hides the large icon when showing the expanded notification.
  final bool hideExpandedLargeIcon;

  BigPictureStyleInformation(this.bigPicture,
      {this.contentTitle,
      this.summaryText,
      this.htmlFormatContentTitle = false,
      this.htmlFormatSummaryText = false,
      this.largeIcon,
      bool htmlFormatContent = false,
      bool htmlFormatTitle = false,
      this.hideExpandedLargeIcon = false})
      : super(htmlFormatContent, htmlFormatTitle);

  /// Creates a [Map] object that describes the [BigPictureStyleInformation] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
  @override
  Map<String, dynamic> toMap() {
    var styleMap = super.toMap();
    var bigPictureStyleJson = <String, dynamic>{
      'contentTitle': contentTitle,
      'summaryText': summaryText,
      'htmlFormatContentTitle': htmlFormatContentTitle,
      'htmlFormatSummaryText': htmlFormatSummaryText,
      'hideExpandedLargeIcon': hideExpandedLargeIcon
    }
      ..addAll(_convertBigPictureToMap())
      ..addAll(_convertLargeIconToMap());

    styleMap.addAll(bigPictureStyleJson);
    return styleMap;
  }

  Map<String, dynamic> _convertBigPictureToMap() {
    if (bigPicture is AndroidDrawableResourceBitmap) {
      return <String, dynamic>{
        'bigPicture': bigPicture.bitmap,
        'bigPictureBitmapSource': AndroidBitmapSource.Drawable.index,
      };
    } else if (bigPicture is AndroidFilePathBitmap) {
      return <String, dynamic>{
        'bigPicture': bigPicture.bitmap,
        'bigPictureBitmapSource': AndroidBitmapSource.FilePath.index,
      };
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _convertLargeIconToMap() {
    if (largeIcon is AndroidDrawableResourceBitmap) {
      return <String, dynamic>{
        'largeIcon': largeIcon.bitmap,
        'largeIconBitmapSource': AndroidBitmapSource.Drawable.index,
      };
    } else if (largeIcon is AndroidFilePathBitmap) {
      return <String, dynamic>{
        'largeIcon': largeIcon.bitmap,
        'largeIconBitmapSource': AndroidBitmapSource.FilePath.index,
      };
    }
    return <String, dynamic>{};
  }
}
