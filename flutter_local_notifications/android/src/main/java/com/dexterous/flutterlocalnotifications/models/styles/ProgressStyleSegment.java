package com.dexterous.flutterlocalnotifications.models.styles;

import androidx.annotation.Keep;

import java.io.Serializable;

@Keep
public class ProgressStyleSegment implements Serializable {
  public Integer length;
  public Integer id;
  public Integer color;
  public Integer semanticStyle;

  public ProgressStyleSegment(Integer length, Integer id, Integer color, Integer semanticStyle) {
    this.length = length;
    this.id = id;
    this.color = color;
    this.semanticStyle = semanticStyle;
  }
}
