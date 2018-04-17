import 'package:flutter_local_notifications/platform_specifics/android_styles/default_style_information.dart';

class InboxStyleInformation extends DefaultStyleInformation {
  /// Overrides ContentTitle in the big form of the template.
  final String contentTitle;

  /// Set the first line of text after the detail section in the big form of the template.
  final String summaryText;

  /// The lines that form part of the digest section for inbox-style notifications
  List<String> lines;

  /// Specifies if the lines should have formatting applied through HTML markup
  final bool htmlFormatLines;

  /// Specifies if the overridden ContentTitle should have formatting applied through HTML markup
  final bool htmlFormatContentTitle;

  /// Specifies if formatting should be applied to the first line of text after the detail section in the big form of the template.
  final bool htmlFormatSummaryText;

  InboxStyleInformation(this.lines,
      {this.htmlFormatLines = false,
      this.contentTitle,
      this.htmlFormatContentTitle = false,
      this.summaryText,
      this.htmlFormatSummaryText = false,
      bool htmlFormatContent = false,
      bool htmlFormatTitle = false})
      : super(htmlFormatContent, htmlFormatTitle);

  Map<String, dynamic> toJson() {
    var styleJson = super.toJson();

    var bigTextStyleJson = <String, dynamic>{
      'contentTitle': contentTitle,
      'htmlFormatContentTitle': htmlFormatContentTitle,
      'summaryText': summaryText,
      'htmlFormatSummaryText': htmlFormatSummaryText,
      'lines': lines ?? new List<String>(),
      'htmlFormatLines': htmlFormatLines
    };
    styleJson.addAll(bigTextStyleJson);
    return styleJson;
  }
}
