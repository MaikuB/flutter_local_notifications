package com.dexterous.flutterlocalnotifications.models;

import androidx.annotation.Keep;
import com.google.gson.annotations.SerializedName;
import java.io.Serializable;

@Keep
public class TitleStyle implements Serializable {
  @SerializedName("color")
  public Integer color;

  @SerializedName("sizeSp")
  public Double sizeSp;

  @SerializedName("bold")
  public Boolean bold;

  @SerializedName("italic")
  public Boolean italic;
}
