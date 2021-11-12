package com.dexterous.flutterlocalnotifications.models.styles;

import androidx.annotation.Keep;

@Keep
public class BigTextStyleInformation extends DefaultStyleInformation {
  public String bigText;
  public Boolean htmlFormatBigText;
  public String contentTitle;
  public Boolean htmlFormatContentTitle;
  public String summaryText;
  public Boolean htmlFormatSummaryText;

  public BigTextStyleInformation(
      Boolean htmlFormatTitle,
      Boolean htmlFormatBody,
      String bigText,
      Boolean htmlFormatBigText,
      String contentTitle,
      Boolean htmlFormatContentTitle,
      String summaryText,
      Boolean htmlFormatSummaryText) {
    super(htmlFormatTitle, htmlFormatBody);
    this.bigText = bigText;
    this.htmlFormatBigText = htmlFormatBigText;
    this.contentTitle = contentTitle;
    this.htmlFormatContentTitle = htmlFormatContentTitle;
    this.summaryText = summaryText;
    this.htmlFormatSummaryText = htmlFormatSummaryText;
  }
}
