package com.dexterous.flutterlocalnotifications.models;

public class NotificationAction {
    private NotificationAction(String identifier, String title) {
        this.identifier = identifier;
        this.title = title;
    }

    public String identifier;

    public String title;
}
