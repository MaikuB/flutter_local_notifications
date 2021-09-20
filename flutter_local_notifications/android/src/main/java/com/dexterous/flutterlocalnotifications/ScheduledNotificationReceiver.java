package com.dexterous.flutterlocalnotifications;

import android.app.Notification;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import com.dexterous.flutterlocalnotifications.utils.StringUtils;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;

import androidx.annotation.Keep;
import androidx.core.app.NotificationManagerCompat;

/**
 * Created by michaelbui on 24/3/18.
 */

@Keep
public class ScheduledNotificationReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(final Context context, Intent intent) {
        String notificationDetailsJson = intent.getStringExtra(FlutterLocalNotificationsPlugin.NOTIFICATION_DETAILS);
        if (StringUtils.isNullOrEmpty(notificationDetailsJson)) {
            // This logic is needed for apps that used the plugin prior to 0.3.4
            Notification notification = intent.getParcelableExtra("notification");
            if (notification != null) {
                notification.when = System.currentTimeMillis();
                int notificationId = intent.getIntExtra("notification_id", 0);
                NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
                notificationManager.notify(notificationId, notification);
                boolean repeat = intent.getBooleanExtra("repeat", false);
                if (!repeat) {
                    FlutterLocalNotificationsPlugin.removeNotificationFromCache(context, notificationId);
                }
            }
        } else {
            Gson gson = FlutterLocalNotificationsPlugin.buildGson();
            Type type = new TypeToken<NotificationDetails>() {}.getType();
            NotificationDetails notificationDetails = gson.fromJson(notificationDetailsJson, type);

            // It seems the that the notification details are sometimes missing channel id or name.
            // Calling the showNotification method without the required channel info results in a
            // crash, so we omit the notification if these parts of the notification are missing.
            if (notificationDetails.channelId == null || notificationDetails.channelId.isEmpty() ||
                notificationDetails.channelName == null || notificationDetails.channelName.isEmpty()) {
                return;
            }

            FlutterLocalNotificationsPlugin.showNotification(context, notificationDetails);
            FlutterLocalNotificationsPlugin.NotificationShownListener listener = FlutterLocalNotificationsPlugin.onNotificationShown;
            if (listener != null) {
                listener.onShown(context, notificationDetails);
            }

            if (notificationDetails.scheduledNotificationRepeatFrequency != null) {
                FlutterLocalNotificationsPlugin.zonedScheduleNextNotification(context, notificationDetails);
            } else if (notificationDetails.matchDateTimeComponents != null) {
                FlutterLocalNotificationsPlugin.zonedScheduleNextNotificationMatchingDateComponents(context, notificationDetails);
            } else if (notificationDetails.repeatInterval != null) {
                FlutterLocalNotificationsPlugin.scheduleNextRepeatingNotification(context, notificationDetails);
            } else {
                FlutterLocalNotificationsPlugin.removeNotificationFromCache(context, notificationDetails.id);
            }
        }

    }

}
