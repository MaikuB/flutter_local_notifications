import '../bitmap.dart';
import 'default_style_information.dart';

/// Used to pass the content for an Android notification displayed using the
/// big picture style.
class BigPictureStyleInformation extends DefaultStyleInformation {
  /// Constructs an instance of [BigPictureStyleInformation].
  const BigPictureStyleInformation(
    this.bigPicture, {
    this.contentTitle,
    this.summaryText,
    this.htmlFormatContentTitle = false,
    this.htmlFormatSummaryText = false,
    this.largeIcon,
    bool htmlFormatContent = false,
    bool htmlFormatTitle = false,
    this.hideExpandedLargeIcon = false,
  }) : super(htmlFormatContent, htmlFormatTitle);

  /// Overrides ContentTitle in the big form of the template.
  final String? contentTitle;

  /// Set the first line of text after the detail section in the big form of
  /// the template.
  final String? summaryText;

  /// Specifies if the overridden ContentTitle should have formatting applied
  /// through HTML markup.
  final bool htmlFormatContentTitle;

  /// Specifies if formatting should be applied to the first line of text after
  ///  the detail section in the big form of the template.
  final bool htmlFormatSummaryText;

  /// The bitmap that will override the large icon when the big notification is
  ///  shown.
  final AndroidBitmap<Object>? largeIcon;

  /// The bitmap to be used as the payload for the BigPicture notification.
  final AndroidBitmap<Object> bigPicture;

  /// Hides the large icon when showing the expanded notification.
  final bool hideExpandedLargeIcon;
}
