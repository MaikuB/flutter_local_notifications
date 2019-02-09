package com.dexterous.flutterlocalnotifications.models;

import com.dexterous.flutterlocalnotifications.BitmapSource;

public class PersonDetails {
    public Boolean bot;
    public String icon;
    public BitmapSource iconBitmapSource;
    public Boolean important;
    public String key;
    public String name;
    public String uri;

    public PersonDetails(Boolean bot, String icon, BitmapSource iconBitmapSource, Boolean important, String key, String name, String uri) {
        this.bot = bot;
        this.icon = icon;
        this.iconBitmapSource = iconBitmapSource;
        this.important = important;
        this.key = key;
        this.name = name;
        this.uri = uri;
    }
}
