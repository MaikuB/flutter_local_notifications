import 'default_style_information.dart';

/// Used to pass the content for an Android notification displayed using the media style.
///
/// When used, the bitmap specified [largeIcon](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidNotificationDetails/largeIcon.html)
/// as part of the [AndroidNotificationDetails](https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidNotificationDetails-class.html)
/// class will be treated as album artwork.
class MediaStyleInformation extends DefaultStyleInformation {
  MediaStyleInformation({
    bool htmlFormatContent = false,
    bool htmlFormatTitle = false,
  }) : super(htmlFormatContent, htmlFormatTitle);
}
