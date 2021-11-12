package com.dexterous.flutterlocalnotifications.models.styles;

import androidx.annotation.Keep;

import java.util.ArrayList;

@Keep
public class InboxStyleInformation extends DefaultStyleInformation {
  public Boolean htmlFormatLines;
  public ArrayList<String> lines;
  public String contentTitle;
  public Boolean htmlFormatContentTitle;
  public String summaryText;
  public Boolean htmlFormatSummaryText;

  public InboxStyleInformation(
      Boolean htmlFormatTitle,
      Boolean htmlFormatBody,
      String contentTitle,
      Boolean htmlFormatContentTitle,
      String summaryText,
      Boolean htmlFormatSummaryText,
      ArrayList<String> lines,
      Boolean htmlFormatLines) {
    super(htmlFormatTitle, htmlFormatBody);
    this.contentTitle = contentTitle;
    this.htmlFormatContentTitle = htmlFormatContentTitle;
    this.summaryText = summaryText;
    this.htmlFormatSummaryText = htmlFormatSummaryText;
    this.lines = lines;
    this.htmlFormatLines = htmlFormatLines;
  }
}
