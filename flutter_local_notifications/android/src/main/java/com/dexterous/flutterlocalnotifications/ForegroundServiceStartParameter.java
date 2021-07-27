package com.dexterous.flutterlocalnotifications;

import com.dexterous.flutterlocalnotifications.models.NotificationDetails;

import java.io.Serializable;

public class ForegroundServiceStartParameter implements Serializable {
    public final static String EXTRA = "com.dexterous.flutterlocalnotifications.ForegroundServiceStartParameter";

    public final NotificationDetails notificationData;
    public final int startMode;
    public final boolean hasForegroundServiceType;
    public final int foregroundServiceType;

    public ForegroundServiceStartParameter(NotificationDetails notificationData, int startMode, boolean hasForegroundServiceType, int foregroundServiceType) {
        this.notificationData = notificationData;
        this.startMode = startMode;
        this.hasForegroundServiceType = hasForegroundServiceType;
        this.foregroundServiceType = foregroundServiceType;
    }

    @Override
    public String toString() {
        return "ForegroundServiceStartParameter{" +
                "notificationData=" + notificationData +
                ", startMode=" + startMode +
                ", hasForegroundServiceType=" + hasForegroundServiceType +
                ", foregroundServiceType=" + foregroundServiceType +
                '}';
    }
}
