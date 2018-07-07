package com.dexterous.flutterlocalnotifications;

import android.app.Notification;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.support.v4.app.NotificationManagerCompat;

import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import com.dexterous.flutterlocalnotifications.utils.StringUtils;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;

/**
 * Created by michaelbui on 24/3/18.
 */

public class ScheduledNotificationReceiver extends BroadcastReceiver {


    @Override
    public void onReceive(final Context context, Intent intent) {
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
        String notificationDetailsJson = intent.getStringExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_DETAILS);
        boolean repeat = intent.getBooleanExtra(FlutterLocalNotificationsPlugin.REPEAT, false);

        // TODO: remove this branching logic as it's legacy code to fix an issue where notifications weren't reporting the correct time
        if(StringUtils.isNullOrEmpty(notificationDetailsJson)) {
            Notification notification = intent.getParcelableExtra(FlutterLocalNotificationsPlugin.NOTIFICATION);
            notification.when = System.currentTimeMillis();
            int notificationId = intent.getIntExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_ID,
                    0);
            notificationManager.notify(notificationId, notification);
            if (repeat) {
                return;
            }
            FlutterLocalNotificationsPlugin.removeNotificationFromCache(notificationId, context);
        } else {
            Gson gson = FlutterLocalNotificationsPlugin.buildGson();
            Type type = new TypeToken<NotificationDetails>() {
            }.getType();
            NotificationDetails notificationDetails  = gson.fromJson(notificationDetailsJson, type);
            Notification notification = FlutterLocalNotificationsPlugin.createNotification(context, notificationDetails);
            notificationManager.notify(notificationDetails.id, notification);
            if (repeat) {
                return;
            }
            FlutterLocalNotificationsPlugin.removeNotificationFromCache(notificationDetails.id, context);
        }

    }

}
