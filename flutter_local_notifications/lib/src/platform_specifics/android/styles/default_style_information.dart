import 'style_information.dart';

/// The default Android notification style.
class DefaultStyleInformation extends StyleInformation {
  /// Specifies if formatting should be applied to the content through HTML markup.
  final bool htmlFormatContent;

  /// Specifies if formatting should be applied to the title through HTML markup.
  final bool htmlFormatTitle;

  DefaultStyleInformation(this.htmlFormatContent, this.htmlFormatTitle);

  /// Create a [Map] object that describes the [DefaultStyleInformation] object.
  ///
  /// Mainly for internal use to send the data over a platform channel.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'htmlFormatContent': htmlFormatContent,
      'htmlFormatTitle': htmlFormatTitle
    };
  }
}
