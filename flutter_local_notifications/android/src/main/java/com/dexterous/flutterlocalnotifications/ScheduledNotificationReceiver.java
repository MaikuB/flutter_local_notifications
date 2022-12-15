package com.dexterous.flutterlocalnotifications;

import android.app.Notification;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Keep;
import androidx.core.app.NotificationManagerCompat;

import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import com.dexterous.flutterlocalnotifications.utils.StringUtils;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Type;

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
            if (notification == null) {
                fault("Notification is null - invalid data.", intent);
                return;
            }
            notification.when = System.currentTimeMillis();
            int notificationId = intent.getIntExtra("notification_id",
                    0);
            NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
            notificationManager.notify(notificationId, notification);
            boolean repeat = intent.getBooleanExtra("repeat", false);
            if (!repeat) {
                FlutterLocalNotificationsPlugin.removeNotificationFromCache(context, notificationId);
            }
        } else {
            Gson gson = FlutterLocalNotificationsPlugin.buildGson();
            Type type = new TypeToken<NotificationDetails>() {
            }.getType();
            NotificationDetails notificationDetails = gson.fromJson(notificationDetailsJson, type);
            if (notificationDetails == null) {
                fault("NotificationDetails is null - gson.fromJson can't parse it.", intent);
                return;
            }

            try {
                FlutterLocalNotificationsPlugin.showNotification(context, notificationDetails);
            } catch (Exception e) {
                fault("Exception while showing notification.", e, intent);
                return;
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

    private void fault(String message, Intent intent) {
        fault(message, null, intent);
    }

    private void fault(String message, Exception e, Intent intent) {
        Bundle bundle = intent.getExtras();
        StringBuilder sb = new StringBuilder();
        if (bundle != null) {
            sb.append("{\n");
            for (String key : bundle.keySet()) {
                sb.append("\t").append(key).append(" : ").append(bundle.get(key) != null ? bundle.get(key) : "NULL");
                sb.append("\n");
            }
            sb.append("}");
        } else {
            sb.append("NULL");
        }

        StringBuilder msg = new StringBuilder(message);
        msg.append("\n");
        if (e != null) {
            msg.append("Exception: ").append(e).append("\n");
        }
        msg.append("Intent extras: ");
        msg.append(sb);

        if (e != null) {
            StringWriter errors = new StringWriter();
            e.printStackTrace(new PrintWriter(errors));
            msg.append("\n").append("Exception Stack trace:\n").append(errors);
        }

        throw new RuntimeException(msg.toString());
    }

}
