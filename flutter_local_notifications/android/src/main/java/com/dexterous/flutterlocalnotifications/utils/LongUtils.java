package com.dexterous.flutterlocalnotifications.utils;

public class LongUtils {
  public static Long parseLong(Object object) {
    if (object instanceof Integer) {
      return ((Integer) object).longValue();
    }
    if (object instanceof Long) {
      return (Long) object;
    }
    return null;
  }
}
