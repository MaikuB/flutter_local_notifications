package com.dexterous.flutterlocalnotifications.models.styles;

import androidx.annotation.Keep;

import java.io.Serializable;

@Keep
public class ProgressStyleSegment implements Serializable {
  public Integer length;
  public Integer id;
  public Integer color;

  public ProgressStyleSegment(Integer length, Integer id, Integer color) {
    this.length = length;
    this.id = id;
    this.color = color;
  }
}
