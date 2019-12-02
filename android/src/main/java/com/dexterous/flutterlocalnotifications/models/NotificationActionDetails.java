package com.dexterous.flutterlocalnotifications.models;

public class NotificationActionDetails {
    public String icon;
    public String title;
    public String actionKey;

    public NotificationActionDetails(String icon, String title, String actionKey) {
        this.icon = icon;
        this.title = title;
        this.actionKey = actionKey;
    }
}
