package com.dexterous.flutterlocalnotifications.models;

import android.graphics.Color;

import com.dexterous.flutterlocalnotifications.SoundSource;

import java.util.Map;

public class NotificationChannelPlugin {
    private static final String CHANNEL_ID = "channelId";
    private static final String CHANNEL_NAME = "channelName";
    private static final String CHANNEL_DESCRIPTION = "channelDescription";
    private static final String CHANNEL_SHOW_BADGE = "channelShowBadge";
    private static final String IMPORTANCE = "importance";
    private static final String PLAY_SOUND = "playSound";
    private static final String SOUND = "sound";
    private static final String SOUND_SOURCE = "soundSource";
    private static final String ENABLE_VIBRATION = "enableVibration";
    private static final String VIBRATION_PATTERN = "vibrationPattern";
    private static final String CHANNEL_ACTION = "channelAction";
    private static final String ENABLE_LIGHTS = "enableLights";
    private static final String LED_COLOR_ALPHA = "ledColorAlpha";
    private static final String LED_COLOR_RED = "ledColorRed";
    private static final String LED_COLOR_GREEN = "ledColorGreen";
    private static final String LED_COLOR_BLUE = "ledColorBlue";

    public String channelId = "Default_Channel_Id";
    public String channelName;
    public String channelDescription;
    public Boolean channelShowBadge;
    public Integer importance;
    public Boolean playSound;
    public String sound;
    public SoundSource soundSource;
    public Boolean enableVibration;
    public long[] vibrationPattern;
    public NotificationChannelAction channelAction;
    public Boolean enableLights;
    public Integer ledColor;


    public static NotificationChannelPlugin from(Map<String, Object> arguments) {
        NotificationChannelPlugin notificationChannel = new NotificationChannelPlugin();
        notificationChannel.channelId = (String) arguments.get(CHANNEL_ID);
        notificationChannel.channelName = (String) arguments.get(CHANNEL_NAME);
        notificationChannel.channelDescription = (String) arguments.get(CHANNEL_DESCRIPTION);
        notificationChannel.importance = (Integer) arguments.get(IMPORTANCE);
        notificationChannel.channelShowBadge = (Boolean) arguments.get(CHANNEL_SHOW_BADGE);
        notificationChannel.channelAction = NotificationChannelAction.values()[(Integer) arguments.get(CHANNEL_ACTION)];
        notificationChannel.enableVibration = (Boolean) arguments.get(ENABLE_VIBRATION);
        notificationChannel.vibrationPattern = (long[]) arguments.get(VIBRATION_PATTERN);

        notificationChannel.playSound = (Boolean) arguments.get(PLAY_SOUND);
        notificationChannel.sound = (String) arguments.get(SOUND);
        Integer soundSourceIndex = (Integer) arguments.get(SOUND_SOURCE);
        if (soundSourceIndex != null) {
            notificationChannel.soundSource = SoundSource.values()[soundSourceIndex];
        }

        Integer a = (Integer) arguments.get(LED_COLOR_ALPHA);
        Integer r = (Integer) arguments.get(LED_COLOR_RED);
        Integer g = (Integer) arguments.get(LED_COLOR_GREEN);
        Integer b = (Integer) arguments.get(LED_COLOR_BLUE);
        if (a != null && r != null && g != null && b != null) {
            notificationChannel.ledColor = Color.argb(a, r, g, b);
        }

        notificationChannel.enableLights = (Boolean) arguments.get(ENABLE_LIGHTS);
        return notificationChannel;
    }

    public static NotificationChannelPlugin fromNotificationDetails(NotificationDetails notificationDetails) {
        NotificationChannelPlugin notificationChannel = new NotificationChannelPlugin();
        notificationChannel.channelId = notificationDetails.channelId;
        notificationChannel.channelName = notificationDetails.channelName;
        notificationChannel.channelDescription = notificationDetails.channelDescription;
        notificationChannel.importance = notificationDetails.importance;
        notificationChannel.channelShowBadge = notificationDetails.channelShowBadge;
        notificationChannel.channelAction = notificationDetails.channelAction;
        notificationChannel.enableVibration = notificationDetails.enableVibration;
        notificationChannel.vibrationPattern = notificationDetails.vibrationPattern;
        notificationChannel.playSound = notificationDetails.playSound;
        notificationChannel.sound = notificationDetails.sound;
        notificationChannel.soundSource = notificationDetails.soundSource;
        notificationChannel.ledColor = notificationDetails.ledColor;
        notificationChannel.enableLights = notificationDetails.enableLights;
        return notificationChannel;
    }
}
