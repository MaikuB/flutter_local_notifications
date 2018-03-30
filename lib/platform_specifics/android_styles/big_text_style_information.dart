import 'package:flutter_local_notifications/platform_specifics/android_styles/style_information.dart';

class BigTextStyleInformation extends StyleInformation {
  final String bigText;
  final String contentTitle;
  final String summaryText;
  final bool htmlFormatBigText;
  final bool htmlFormatContentTitle;
  final bool htmlFormatSummaryText;

  BigTextStyleInformation(this.bigText,
      {this.htmlFormatBigText = false,
      this.contentTitle,
      this.htmlFormatContentTitle = false,
      this.summaryText,
      this.htmlFormatSummaryText = false})
      : super();

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'bigText': bigText,
      'htmlFormatBigText': htmlFormatBigText,
      'contentTitle': contentTitle,
      'htmlFormatContentTitle': htmlFormatContentTitle,
      'summaryText': summaryText,
      'htmlFormatSummaryText': htmlFormatSummaryText
    };
  }
}
