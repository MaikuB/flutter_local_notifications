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
    private static final String PAYLOAD = "payload";
    private static final String ID = "id";
    private static final String TITLE = "title";
    private static final String BODY = "body";
    private static final String MILLISECONDS_SINCE_EPOCH = "millisecondsSinceEpoch";
    private static final String CALLED_AT = "calledAt";
    private static final String REPEAT_INTERVAL = "repeatInterval";
    private static final String REPEAT_TIME = "repeatTime";
    private static final String PLATFORM_SPECIFICS = "platformSpecifics";
    private static final String AUTO_CANCEL = "autoCancel";
    private static final String ONGOING = "ongoing";
    private static final String STYLE = "style";
    private static final String ICON = "icon";
    private static final String PRIORITY = "priority";
    private static final String PLAY_SOUND = "playSound";
    private static final String SOUND = "sound";
    private static final String ENABLE_VIBRATION = "enableVibration";
    private static final String VIBRATION_PATTERN = "vibrationPattern";
    private static final String GROUP_KEY = "groupKey";
    private static final String SET_AS_GROUP_SUMMARY = "setAsGroupSummary";
    private static final String GROUP_ALERT_BEHAVIOR = "groupAlertBehavior";
    private static final String CHANNEL_ID = "channelId";
    private static final String CHANNEL_NAME = "channelName";
    private static final String CHANNEL_DESCRIPTION = "channelDescription";
    private static final String IMPORTANCE = "importance";
    private static final String STYLE_INFORMATION = "styleInformation";
    private static final String BIG_TEXT = "bigText";
    private static final String HTML_FORMAT_BIG_TEXT = "htmlFormatBigText";
    private static final String CONTENT_TITLE = "contentTitle";
    private static final String HTML_FORMAT_CONTENT_TITLE = "htmlFormatContentTitle";
    private static final String SUMMARY_TEXT = "summaryText";
    private static final String HTML_FORMAT_SUMMARY_TEXT = "htmlFormatSummaryText";
    private static final String LINES = "lines";
    private static final String HTML_FORMAT_LINES = "htmlFormatLines";
    private static final String HTML_FORMAT_TITLE = "htmlFormatTitle";
    private static final String HTML_FORMAT_CONTENT = "htmlFormatContent";

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
    public Time repeatTime;
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
        notificationDetails.payload = (String) arguments.get(PAYLOAD);
        notificationDetails.id = (Integer) arguments.get(ID);
        notificationDetails.title = (String) arguments.get(TITLE);
        notificationDetails.body = (String) arguments.get(BODY);
        if (arguments.containsKey(MILLISECONDS_SINCE_EPOCH)) {
            notificationDetails.millisecondsSinceEpoch = (Long) arguments.get(MILLISECONDS_SINCE_EPOCH);
        }
        if(arguments.containsKey(CALLED_AT)) {
            notificationDetails.calledAt = (Long) arguments.get(CALLED_AT);
        }
        if(arguments.containsKey(REPEAT_INTERVAL)) {
            notificationDetails.repeatInterval = RepeatInterval.values()[(Integer)arguments.get(REPEAT_INTERVAL)];
        }
        if (arguments.containsKey(REPEAT_TIME)) {
            @SuppressWarnings("unchecked")
            Map<String, Object> repeatTimeParams = (Map<String, Object>)arguments.get(REPEAT_TIME);
            notificationDetails.repeatTime = Time.from(repeatTimeParams);
        }
        @SuppressWarnings("unchecked")
        Map<String, Object> platformChannelSpecifics = (Map<String, Object>) arguments.get(PLATFORM_SPECIFICS);
        if (platformChannelSpecifics != null) {
            notificationDetails.autoCancel = (Boolean) arguments.get(AUTO_CANCEL);
            notificationDetails.ongoing = (Boolean) arguments.get(ONGOING);
            notificationDetails.style = NotificationStyle.values()[(Integer) platformChannelSpecifics.get(STYLE)];
            ProcessStyleInformation(notificationDetails, platformChannelSpecifics);
            notificationDetails.icon = (String) platformChannelSpecifics.get(ICON);
            notificationDetails.priority = (Integer) platformChannelSpecifics.get(PRIORITY);
            notificationDetails.playSound = (Boolean) platformChannelSpecifics.get(PLAY_SOUND);
            notificationDetails.sound = (String) platformChannelSpecifics.get(SOUND);
            notificationDetails.enableVibration = (Boolean) platformChannelSpecifics.get(ENABLE_VIBRATION);
            notificationDetails.vibrationPattern = (long[]) platformChannelSpecifics.get(VIBRATION_PATTERN);
            notificationDetails.groupKey = (String) platformChannelSpecifics.get(GROUP_KEY);
            notificationDetails.setAsGroupSummary = (Boolean) platformChannelSpecifics.get(SET_AS_GROUP_SUMMARY);
            notificationDetails.groupAlertBehavior = (Integer) platformChannelSpecifics.get(GROUP_ALERT_BEHAVIOR);
            getChannelInformation(notificationDetails, platformChannelSpecifics);
        }
        return notificationDetails;
    }

    private static void getChannelInformation(NotificationDetails notificationDetails, Map<String, Object> platformChannelSpecifics) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationDetails.channelId = (String) platformChannelSpecifics.get(CHANNEL_ID);
            notificationDetails.channelName = (String) platformChannelSpecifics.get(CHANNEL_NAME);
            notificationDetails.channelDescription = (String) platformChannelSpecifics.get(CHANNEL_DESCRIPTION);
            notificationDetails.importance = (Integer) platformChannelSpecifics.get(IMPORTANCE);
        }
    }

    private static void ProcessStyleInformation(NotificationDetails notificationDetails, Map<String, Object> platformSpecifics) {
        @SuppressWarnings("unchecked")
        Map<String, Object> styleInformation = (Map<String, Object>) platformSpecifics.get(STYLE_INFORMATION);
        DefaultStyleInformation defaultStyleInformation = getDefaultStyleInformation(styleInformation);
        if (notificationDetails.style == NotificationStyle.Default) {
            notificationDetails.styleInformation = defaultStyleInformation;
        } else if (notificationDetails.style == NotificationStyle.BigText) {
            String bigText = (String) styleInformation.get(BIG_TEXT);
            Boolean htmlFormatBigText = (Boolean) styleInformation.get(HTML_FORMAT_BIG_TEXT);
            String contentTitle = (String) styleInformation.get(CONTENT_TITLE);
            Boolean htmlFormatContentTitle = (Boolean) styleInformation.get(HTML_FORMAT_CONTENT_TITLE);
            String summaryText = (String) styleInformation.get(SUMMARY_TEXT);
            Boolean htmlFormatSummaryText = (Boolean) styleInformation.get(HTML_FORMAT_SUMMARY_TEXT);
            notificationDetails.styleInformation = new BigTextStyleInformation(defaultStyleInformation.htmlFormatTitle, defaultStyleInformation.htmlFormatBody, bigText, htmlFormatBigText, contentTitle, htmlFormatContentTitle, summaryText, htmlFormatSummaryText);
        } else if (notificationDetails.style == NotificationStyle.Inbox) {
            String contentTitle = (String) styleInformation.get(CONTENT_TITLE);
            Boolean htmlFormatContentTitle = (Boolean) styleInformation.get(HTML_FORMAT_CONTENT_TITLE);
            String summaryText = (String) styleInformation.get(SUMMARY_TEXT);
            Boolean htmlFormatSummaryText = (Boolean) styleInformation.get(HTML_FORMAT_SUMMARY_TEXT);
            @SuppressWarnings("unchecked")
            ArrayList<String> lines = (ArrayList<String>) styleInformation.get(LINES);
            Boolean htmlFormatLines = (Boolean) styleInformation.get(HTML_FORMAT_LINES);
            notificationDetails.styleInformation = new InboxStyleInformation(defaultStyleInformation.htmlFormatTitle, defaultStyleInformation.htmlFormatBody, contentTitle, htmlFormatContentTitle, summaryText, htmlFormatSummaryText, lines, htmlFormatLines);
        }
    }

    private static DefaultStyleInformation getDefaultStyleInformation(Map<String, Object> styleInformation) {
        Boolean htmlFormatTitle = (Boolean) styleInformation.get(HTML_FORMAT_TITLE);
        Boolean htmlFormatBody = (Boolean) styleInformation.get(HTML_FORMAT_CONTENT);
        return new DefaultStyleInformation(htmlFormatTitle, htmlFormatBody);
    }
}
