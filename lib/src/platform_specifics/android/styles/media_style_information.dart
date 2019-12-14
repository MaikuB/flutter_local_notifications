import 'default_style_information.dart';

class MediaStyleInformation extends DefaultStyleInformation {

  MediaStyleInformation({
    bool htmlFormatContent = false,
    bool htmlFormatTitle = false,
  }) : super(htmlFormatContent, htmlFormatTitle);

  Map<String, dynamic> toMap() {
    var styleJson = super.toMap();
    return styleJson;
  }
}
