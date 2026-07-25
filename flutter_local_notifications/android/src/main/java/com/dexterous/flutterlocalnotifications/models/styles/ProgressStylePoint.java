package com.dexterous.flutterlocalnotifications.models.styles;

import androidx.annotation.Keep;

import java.io.Serializable;

@Keep
public class ProgressStylePoint implements Serializable {
  public Integer position;
  public Integer id;
  public Integer color;

  public ProgressStylePoint(Integer position, Integer id, Integer color) {
    this.position = position;
    this.id = id;
    this.color = color;
  }
}
