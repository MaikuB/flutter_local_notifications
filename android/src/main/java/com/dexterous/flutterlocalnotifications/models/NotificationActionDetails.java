package com.dexterous.flutterlocalnotifications.models;

import java.util.HashMap;

public class NotificationActionDetails {
    public String icon;
    public String title;
    public String actionKey;
    public HashMap<String, String> extras;

    public NotificationActionDetails(String icon, String title, String actionKey, HashMap<String, String> extras) {
        this.icon = icon;
        this.title = title;
        this.actionKey = actionKey;
        this.extras = extras;
    }
}
