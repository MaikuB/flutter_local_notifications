package com.dexterous.flutterlocalnotifications.models.styles;

import androidx.annotation.Keep;

import java.io.Serializable;

@Keep
public class ProgressStylePoint implements Serializable {
  public Integer position;
  public Integer id;
  public Integer color;
  public Integer semanticStyle;

  public ProgressStylePoint(Integer position, Integer id, Integer color, Integer semanticStyle) {
    this.position = position;
    this.id = id;
    this.color = color;
    this.semanticStyle = semanticStyle;
  }
}
