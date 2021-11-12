package com.dexterous.flutterlocalnotifications.utils;

import androidx.annotation.Keep;

@Keep
public class BooleanUtils {
  public static boolean getValue(Boolean booleanObject) {
    return booleanObject != null && booleanObject.booleanValue();
  }
}
