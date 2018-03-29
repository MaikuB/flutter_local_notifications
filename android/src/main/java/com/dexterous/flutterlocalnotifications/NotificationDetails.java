package com.dexterous.flutterlocalnotifications;

import android.app.NotificationManager;
import android.os.Build;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationManagerCompat;

import java.util.ArrayList;
import java.util.Map;

public class NotificationDetails {
    public Integer id;
    public String title;
    public String body;
    public String icon;
    public Long delay;
    public String channelId = "Default_Channel_Id";
    public String channelName;
    public String channelDescription;
    public Integer importance;
    public Integer priority;
    public Boolean playSound;
    public String sound;
    public Boolean enableVibration;
    public long[] vibrationPattern;


    public static NotificationDetails from(Map<String, Object> arguments) {
        NotificationDetails notificationDetails = new NotificationDetails();
        notificationDetails.id = (Integer) arguments.get("id");
        notificationDetails.title = (String) arguments.get("title");
        notificationDetails.body = (String) arguments.get("body");
        if (arguments.containsKey("millisecondsSinceEpoch")) {
            Long millisecondsSinceEpoch = (Long) arguments.get("millisecondsSinceEpoch");
            notificationDetails.delay = millisecondsSinceEpoch - System.currentTimeMillis();
        }
        Map<String, Object> platformChannelSpecifics = (Map<String, Object>) arguments.get("platformSpecifics");
        notificationDetails.icon = (String) platformChannelSpecifics.get("icon");
        notificationDetails.priority = (Integer) platformChannelSpecifics.get("priority");
        notificationDetails.playSound = (Boolean) platformChannelSpecifics.get("playSound");
        notificationDetails.sound = (String) platformChannelSpecifics.get("sound");
        notificationDetails.enableVibration = (Boolean) platformChannelSpecifics.get("enableVibration");
        notificationDetails.vibrationPattern = (long[]) platformChannelSpecifics.get("vibrationPattern");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationDetails.channelId = (String) platformChannelSpecifics.get("channelId");
            notificationDetails.channelName = (String) platformChannelSpecifics.get("channelName");
            notificationDetails.channelDescription = (String) platformChannelSpecifics.get("channelDescription");
            notificationDetails.importance = (Integer) platformChannelSpecifics.get("importance");
        }

        return notificationDetails;
    }
}
