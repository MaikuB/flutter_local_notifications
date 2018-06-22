part of flutter_local_notifications;

/// Used to pass the content for an Android notification displayed using the big picture style
class BigPictureStyleInformation extends DefaultStyleInformation {
  /// Overrides ContentTitle in the big form of the template.
  final String contentTitle;

  /// Set the first line of text after the detail section in the big form of the template.
  final String summaryText;

  /// Specifies if the overridden ContentTitle should have formatting applies through HTML markup
  final bool htmlFormatContentTitle;

  /// Specifies if formatting should be applied to the first line of text after the detail section in the big form of the template.
  final bool htmlFormatSummaryText;

  /// Path the bitmap that will override the large icon when the big notification is shown. This will be either the name of the drawable of an actual file path based on the value of [largeIconBitmapSource].
  final String largeIcon;

  /// Specifics the source for bitmap that will override the large icon specified in this style
  final BitmapSource largeIconBitmapSource;

  /// Path to the bitmap to be used as the payload for the BigPicture notification. This will be either the name of the drawable of an actual file path based on the value of [bigPictureBitmapSource].
  final String bigPicture;

  /// Specifies the source for the bitmap to be used as the payload for the BigPicture notification
  final BitmapSource bigPictureBitmapSource;

  BigPictureStyleInformation(this.bigPicture, this.bigPictureBitmapSource,
      {this.contentTitle,
      this.summaryText,
      this.htmlFormatContentTitle = false,
      this.htmlFormatSummaryText = false,
      this.largeIcon,
      this.largeIconBitmapSource,
      bool htmlFormatContent = false,
      bool htmlFormatTitle = false})
      : super(htmlFormatContent, htmlFormatTitle);

  @override
  Map<String, dynamic> toMap() {
    var styleJson = super.toMap();
    var bigPictureStyleJson = <String, dynamic>{
      'contentTitle': contentTitle,
      'summaryText': summaryText,
      'htmlFormatContentTitle': htmlFormatContentTitle,
      'htmlFormatSummaryText': htmlFormatSummaryText,
      'largeIcon': largeIcon,
      'largeIconBitmapSource': largeIconBitmapSource?.index,
      'bigPicture': bigPicture,
      'bigPictureBitmapSource': bigPictureBitmapSource?.index
    };
    styleJson.addAll(bigPictureStyleJson);
    return styleJson;
  }
}
