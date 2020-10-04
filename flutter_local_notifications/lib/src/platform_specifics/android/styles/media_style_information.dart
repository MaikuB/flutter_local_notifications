import 'default_style_information.dart';

/// Used to pass the content for an Android notification displayed using the
/// media style.
///
/// When used, the bitmap given to [AndroidNotificationDetails.largeIcon] will
/// be treated as album artwork.
class MediaStyleInformation extends DefaultStyleInformation {
  const MediaStyleInformation({
    bool htmlFormatContent = false,
    bool htmlFormatTitle = false,
  }) : super(htmlFormatContent, htmlFormatTitle);
}
