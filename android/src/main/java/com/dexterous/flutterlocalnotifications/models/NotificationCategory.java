package com.dexterous.flutterlocalnotifications.models;

import java.util.List;

public class NotificationCategory {
    private NotificationCategory(String identifier, List<NotificationAction> actions) {
        this.identifier = identifier;
        this.actions = actions;
    }

    public String identifier;

    public List<NotificationAction> actions;
}
