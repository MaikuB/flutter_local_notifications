package com.dexterous.flutterlocalnotifications;

import android.app.Notification;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;

public class ForegroundService extends Service {

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        ForegroundServiceStartParameter parameter = (ForegroundServiceStartParameter) intent.getSerializableExtra(
                ForegroundServiceStartParameter.EXTRA);
        Notification notification = FlutterLocalNotificationsPlugin.
                createNotification(this, parameter.notificationData);
        if (parameter.hasForegroundServiceType && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(parameter.notificationData.id, notification, parameter.foregroundServiceType);
        } else {
            startForeground(parameter.notificationData.id, notification);
        }
        return parameter.startMode;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
