package com.dexterous.flutterlocalnotifications.models;

public class PersonDetails {
    public Boolean bot;
    public String icon;
    public IconSource iconBitmapSource;
    public Boolean important;
    public String key;
    public String name;
    public String uri;
    public boolean circleIcon;

    public PersonDetails(Boolean bot, String icon, IconSource iconSource, Boolean important, String key, String name, String uri, boolean circleIcon) {
        this.bot = bot;
        this.icon = icon;
        this.iconBitmapSource = iconSource;
        this.important = important;
        this.key = key;
        this.name = name;
        this.uri = uri;
        this.circleIcon = circleIcon;
    }
}
