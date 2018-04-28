package com.dexterous.flutterlocalnotifications.models;

import android.os.Build;

import com.dexterous.flutterlocalnotifications.NotificationStyle;
import com.dexterous.flutterlocalnotifications.RepeatInterval;
import com.dexterous.flutterlocalnotifications.models.styles.BigTextStyleInformation;
import com.dexterous.flutterlocalnotifications.models.styles.DefaultStyleInformation;
import com.dexterous.flutterlocalnotifications.models.styles.InboxStyleInformation;
import com.dexterous.flutterlocalnotifications.models.styles.StyleInformation;

import java.util.ArrayList;
import java.util.Map;

public class NotificationDetails {
    public Integer id;
    public String title;
    public String body;
    public String icon;
    public String channelId = "Default_Channel_Id";
    public String channelName;
    public String channelDescription;
    public Integer importance;
    public Integer priority;
    public Boolean playSound;
    public String sound;
    public Boolean enableVibration;
    public long[] vibrationPattern;
    public NotificationStyle style;
    public StyleInformation styleInformation;
    public RepeatInterval repeatInterval;
    public Long millisecondsSinceEpoch;
    public Long calledAt;
    public String payload;
    public String groupKey;
    public Boolean setAsGroupSummary;
    public Integer groupAlertBehavior;
    public Boolean autoCancel;
    public Boolean ongoing;

    // Note: this is set on the Android to save details about the icon that should be used when re-shydrating scheduled notifications when a device has been restarted
    public Integer iconResourceId;

    public static NotificationDetails from(Map<String, Object> arguments) {
        NotificationDetails notificationDetails = new NotificationDetails();
        notificationDetails.payload = (String) arguments.get("payload");
        notificationDetails.id = (Integer) arguments.get("id");
        notificationDetails.title = (String) arguments.get("title");
        notificationDetails.body = (String) arguments.get("body");
        if (arguments.containsKey("millisecondsSinceEpoch")) {
            notificationDetails.millisecondsSinceEpoch = (Long) arguments.get("millisecondsSinceEpoch");
        }
        if(arguments.containsKey("calledAt")) {
            notificationDetails.calledAt = (Long) arguments.get("calledAt");
        }
        if(arguments.containsKey("repeatInterval")) {
            notificationDetails.repeatInterval = RepeatInterval.values()[(Integer)arguments.get("repeatInterval")];
        }
        @SuppressWarnings("unchecked")
        Map<String, Object> platformChannelSpecifics = (Map<String, Object>) arguments.get("platformSpecifics");
        if (platformChannelSpecifics != null) {
            notificationDetails.autoCancel = (Boolean) arguments.get("autoCancel");
            notificationDetails.ongoing = (Boolean) arguments.get("ongoing");
            notificationDetails.style = NotificationStyle.values()[(Integer) platformChannelSpecifics.get("style")];
            ProcessStyleInformation(notificationDetails, platformChannelSpecifics);
            notificationDetails.icon = (String) platformChannelSpecifics.get("icon");
            notificationDetails.priority = (Integer) platformChannelSpecifics.get("priority");
            notificationDetails.playSound = (Boolean) platformChannelSpecifics.get("playSound");
            notificationDetails.sound = (String) platformChannelSpecifics.get("sound");
            notificationDetails.enableVibration = (Boolean) platformChannelSpecifics.get("enableVibration");
            notificationDetails.vibrationPattern = (long[]) platformChannelSpecifics.get("vibrationPattern");
            notificationDetails.groupKey = (String) platformChannelSpecifics.get("groupKey");
            notificationDetails.setAsGroupSummary = (Boolean) platformChannelSpecifics.get("setAsGroupSummary");
            notificationDetails.groupAlertBehavior = (Integer) platformChannelSpecifics.get("groupAlertBehavior");
            getChannelInformation(notificationDetails, platformChannelSpecifics);
        }
        return notificationDetails;
    }

    private static void getChannelInformation(NotificationDetails notificationDetails, Map<String, Object> platformChannelSpecifics) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationDetails.channelId = (String) platformChannelSpecifics.get("channelId");
            notificationDetails.channelName = (String) platformChannelSpecifics.get("channelName");
            notificationDetails.channelDescription = (String) platformChannelSpecifics.get("channelDescription");
            notificationDetails.importance = (Integer) platformChannelSpecifics.get("importance");
        }
    }

    private static void ProcessStyleInformation(NotificationDetails notificationDetails, Map<String, Object> platformSpecifics) {
        @SuppressWarnings("unchecked")
        Map<String, Object> styleInformation = (Map<String, Object>) platformSpecifics.get("styleInformation");
        DefaultStyleInformation defaultStyleInformation = getDefaultStyleInformation(styleInformation);
        if (notificationDetails.style == NotificationStyle.Default) {
            notificationDetails.styleInformation = defaultStyleInformation;
        } else if (notificationDetails.style == NotificationStyle.BigText) {
            String bigText = (String) styleInformation.get("bigText");
            Boolean htmlFormatBigText = (Boolean) styleInformation.get("htmlFormatBigText");
            String contentTitle = (String) styleInformation.get("contentTitle");
            Boolean htmlFormatContentTitle = (Boolean) styleInformation.get("htmlFormatContentTitle");
            String summaryText = (String) styleInformation.get("summaryText");
            Boolean htmlFormatSummaryText = (Boolean) styleInformation.get("htmlFormatSummaryText");
            notificationDetails.styleInformation = new BigTextStyleInformation(defaultStyleInformation.htmlFormatTitle, defaultStyleInformation.htmlFormatBody, bigText, htmlFormatBigText, contentTitle, htmlFormatContentTitle, summaryText, htmlFormatSummaryText);
        } else if (notificationDetails.style == NotificationStyle.Inbox) {
            String contentTitle = (String) styleInformation.get("contentTitle");
            Boolean htmlFormatContentTitle = (Boolean) styleInformation.get("htmlFormatContentTitle");
            String summaryText = (String) styleInformation.get("summaryText");
            Boolean htmlFormatSummaryText = (Boolean) styleInformation.get("htmlFormatSummaryText");
            @SuppressWarnings("unchecked")
            ArrayList<String> lines = (ArrayList<String>) styleInformation.get("lines");
            Boolean htmlFormatLines = (Boolean) styleInformation.get("htmlFormatLines");
            notificationDetails.styleInformation = new InboxStyleInformation(defaultStyleInformation.htmlFormatTitle, defaultStyleInformation.htmlFormatBody, contentTitle, htmlFormatContentTitle, summaryText, htmlFormatSummaryText, lines, htmlFormatLines);
        }
    }

    private static DefaultStyleInformation getDefaultStyleInformation(Map<String, Object> styleInformation) {
        Boolean htmlFormatTitle = (Boolean) styleInformation.get("htmlFormatTitle");
        Boolean htmlFormatBody = (Boolean) styleInformation.get("htmlFormatContent");
        return new DefaultStyleInformation(htmlFormatTitle, htmlFormatBody);
    }
}
