package com.dexterous.flutterlocalnotifications.models;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;

public class NotificationActionBroadcastReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (context == null || intent == null) return;

        String actionKey = intent.getAction();
        System.out.println("NotificationActionBroadcastReceiver.onReceive: " + actionKey + " ");

        FlutterLocalNotificationsPlugin.instance.notifyActionTapped(actionKey);
    }
}
