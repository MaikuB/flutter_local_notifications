package com.dexterous.flutterlocalnotifications.models;

import androidx.annotation.NonNull;
import java.util.ArrayList;
import java.util.List;

/**
 * Configuration for a custom notification view layout.
 * Allows specifying a custom Android XML layout for notifications
 * and configuring the views within that layout.
 */
public class CustomNotificationView {
    /**
     * The name of the Android XML layout resource.
     */
    @NonNull
    public String layoutName;

    /**
     * List of view mappings that configure the views in the layout.
     */
    @NonNull
    public List<CustomViewMapping> viewMappings;

    public CustomNotificationView(@NonNull String layoutName, @NonNull List<CustomViewMapping> viewMappings) {
        this.layoutName = layoutName;
        this.viewMappings = viewMappings;
    }

    public CustomNotificationView(@NonNull String layoutName) {
        this(layoutName, new ArrayList<>());
    }
}
