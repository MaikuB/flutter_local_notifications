package com.dexterous.flutterlocalnotifications.models;

import androidx.annotation.Nullable;

/**
 * Represents a mapping between a view ID and its associated data.
 * Used to configure custom notification views by mapping Android view IDs
 * to their corresponding text content or action IDs.
 */
public class CustomViewMapping {
    /**
     * The Android resource ID name of the view.
     */
    public String viewId;

    /**
     * The text content to display in the view (for TextViews).
     */
    @Nullable
    public String text;

    /**
     * The action identifier for clickable views (for Buttons).
     */
    @Nullable
    public String actionId;

    public CustomViewMapping(String viewId, @Nullable String text, @Nullable String actionId) {
        this.viewId = viewId;
        this.text = text;
        this.actionId = actionId;
    }
}
