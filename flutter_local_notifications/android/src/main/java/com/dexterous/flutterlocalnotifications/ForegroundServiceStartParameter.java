package com.dexterous.flutterlocalnotifications;

import com.dexterous.flutterlocalnotifications.models.NotificationDetails;

import java.io.Serializable;
import java.util.ArrayList;

public class ForegroundServiceStartParameter implements Serializable {
  public static final String EXTRA =
      "com.dexterous.flutterlocalnotifications.ForegroundServiceStartParameter";

  public final NotificationDetails notificationData;
  public final int startMode;
  public final ArrayList<Integer> foregroundServiceTypes;

  public ForegroundServiceStartParameter(
      NotificationDetails notificationData,
      int startMode,
      ArrayList<Integer> foregroundServiceTypes) {
    this.notificationData = notificationData;
    this.startMode = startMode;
    this.foregroundServiceTypes = foregroundServiceTypes;
  }

  @Override
  public String toString() {
    return "ForegroundServiceStartParameter{"
        + "notificationData="
        + notificationData
        + ", startMode="
        + startMode
        + ", foregroundServiceTypes="
        + foregroundServiceTypes
        + '}';
  }
}
