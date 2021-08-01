package com.dexterous.flutterlocalnotifications;

import com.dexterous.flutterlocalnotifications.models.NotificationDetails;

import java.io.Serializable;

public class ForegroundServiceStartParameter implements Serializable {
    public final static String EXTRA = "com.dexterous.flutterlocalnotifications.ForegroundServiceStartParameter";

    public final NotificationDetails notificationData;
    public final int startMode;
    public final int[] foregroundServiceType;

    public ForegroundServiceStartParameter(NotificationDetails notificationData, int startMode, int[] foregroundServiceType) {
        this.notificationData = notificationData;
        this.startMode = startMode;
        this.foregroundServiceType = foregroundServiceType;
    }

    @Override
    public String toString() {
        return "ForegroundServiceStartParameter{" +
                "notificationData=" + notificationData +
                ", startMode=" + startMode +
                ", foregroundServiceType=" + foregroundServiceType +
                '}';
    }
}
