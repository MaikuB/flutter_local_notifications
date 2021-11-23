package com.dexterous.flutterlocalnotifications.models.styles;

import androidx.annotation.Keep;

@Keep
public class DefaultStyleInformation extends StyleInformation {
  public Boolean htmlFormatTitle;
  public Boolean htmlFormatBody;

  public DefaultStyleInformation(Boolean htmlFormatTitle, Boolean htmlFormatBody) {
    this.htmlFormatTitle = htmlFormatTitle;
    this.htmlFormatBody = htmlFormatBody;
  }
}
