package com.dexterous.flutterlocalnotifications.models;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import static com.dexterous.flutterlocalnotifications.models.NotificationDetails.ACTION_EXTRAS;

public class NotificationActionBroadcastReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (context == null || intent == null) return;

        String actionKey = intent.getAction();
        Map<String, String> actionExtras = getExtras(intent);

        FlutterLocalNotificationsPlugin.instance.notifyActionTapped(actionKey, actionExtras);
    }

    @SuppressWarnings("unchecked")
    private Map<String, String> getExtras(Intent intent)
    {
        Serializable rawExtras = intent.getSerializableExtra(ACTION_EXTRAS);

        if (!(rawExtras instanceof HashMap)) {
            return null;
        }

        return (HashMap<String, String>) rawExtras;
    }
}
