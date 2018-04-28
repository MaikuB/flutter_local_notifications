package com.dexterous.flutterlocalnotifications;

import android.app.Notification;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.support.v4.app.NotificationManagerCompat;

/**
 * Created by michaelbui on 24/3/18.
 */

public class ScheduledNotificationReceiver extends BroadcastReceiver {


    @Override
    public void onReceive(final Context context, Intent intent) {
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
        Notification notification = intent.getParcelableExtra(FlutterLocalNotificationsPlugin.NOTIFICATION);
        int notificationId = intent.getIntExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_ID, 0);
        notificationManager.notify(notificationId, notification);
        boolean repeat = intent.getBooleanExtra(FlutterLocalNotificationsPlugin.REPEAT, false);
        if (repeat) {
            return;
        }
        FlutterLocalNotificationsPlugin.removeNotificationFromCache(notificationId, context);
    }

}
