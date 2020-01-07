package com.dexterous.flutterlocalnotifications;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class ScheduledNotificationBootReceiver extends BroadcastReceiver
{
    @Override
    public void onReceive(final Context context, Intent intent) {
        String action = intent.getAction();
        System.out.println("rebooted");
        if (action != null && action.equals(android.content.Intent.ACTION_BOOT_COMPLETED)) {
            FlutterLocalNotificationsPlugin.rescheduleNotifications(context);
        }
    }
}
