package com.dexterous.flutterlocalnotifications;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;

/**
 * Created by michaelbui on 24/3/18.
 */

public class ScheduledNotificationReceiver extends BroadcastReceiver {


    @Override
    public void onReceive(final Context context, Intent intent) {
        String notificationDetailsJson = intent.getStringExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_DETAILS);
        Gson gson = FlutterLocalNotificationsPlugin.buildGson();
        Type type = new TypeToken<NotificationDetails>() {
        }.getType();
        NotificationDetails notificationDetails = gson.fromJson(notificationDetailsJson, type);
        FlutterLocalNotificationsPlugin.showNotification(context, notificationDetails);
        if (notificationDetails.scheduledNotificationRepeatFrequency != null) {
            FlutterLocalNotificationsPlugin.zonedScheduleNextNotification(context, notificationDetails);
        } else if (notificationDetails.repeatInterval != null) {
            FlutterLocalNotificationsPlugin.scheduleNextRepeatingNotification(context, notificationDetails);
        } else {
            FlutterLocalNotificationsPlugin.removeNotificationFromCache(context, notificationDetails.id);
        }

    }

}
