package com.dexterous.flutterlocalnotifications.models;

import android.graphics.Color;
import androidx.annotation.Nullable;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class NotificationAction {
  public static class NotificationActionInput {

    public NotificationActionInput(
        @Nullable List<String> choices,
        Boolean allowFreeFormInput,
        String label,
        @Nullable List<String> allowedMimeTypes) {
      this.choices = choices;
      this.allowFreeFormInput = allowFreeFormInput;
      this.label = label;
      this.allowedMimeTypes = allowedMimeTypes;
    }

    @Nullable public List<String> choices;
    public Boolean allowFreeFormInput;
    public String label;
    @Nullable public List<String> allowedMimeTypes;
  }

  private static final String ID = "id";
  private static final String TITLE = "title";
  private static final String TITLE_COLOR_ALPHA = "titleColorAlpha";
  private static final String TITLE_COLOR_RED = "titleColorRed";
  private static final String TITLE_COLOR_GREEN = "titleColorGreen";
  private static final String TITLE_COLOR_BLUE = "titleColorBlue";
  private static final String ICON = "icon";
  private static final String ICON_SOURCE = "iconBitmapSource";

  public String id;
  public String title;
  public Integer titleColor;
  public String icon;
  public Boolean contextual;
  public Boolean showsUserInterface;
  public Boolean allowGeneratedReplies;
  public IconSource iconSource;
  public List<NotificationActionInput> inputs;

  public static NotificationAction from(Map<String, Object> arguments) {
    NotificationAction action = new NotificationAction();
    action.id = (String) arguments.get(ID);
    action.title = (String) arguments.get(TITLE);

    Integer a = (Integer) arguments.get(TITLE_COLOR_ALPHA);
    Integer r = (Integer) arguments.get(TITLE_COLOR_RED);
    Integer g = (Integer) arguments.get(TITLE_COLOR_GREEN);
    Integer b = (Integer) arguments.get(TITLE_COLOR_BLUE);
    if (a != null && r != null && g != null && b != null) {
      action.titleColor = Color.argb(a, r, g, b);
    }

    action.icon = (String) arguments.get(ICON);
    action.contextual = (Boolean) arguments.get("contextual");
    action.showsUserInterface = (Boolean) arguments.get("showsUserInterface");
    action.allowGeneratedReplies = (Boolean) arguments.get("allowGeneratedReplies");
    Integer iconSourceIndex = (Integer) arguments.get(ICON_SOURCE);
    if (iconSourceIndex != null) {
      action.iconSource = IconSource.values()[iconSourceIndex];
    }
    action.inputs = new ArrayList<>();
    if (arguments.get("inputs") != null) {
      List<Map<String, Object>> inputs = (List<Map<String, Object>>) arguments.get("inputs");
      for (Map<String, Object> input : inputs) {
        action.inputs.add(
            new NotificationActionInput(
                (List<String>) input.get("choices"),
                (Boolean) input.get("allowFreeFormInput"),
                (String) input.get("label"),
                (List<String>) input.get("allowedMimeTypes")));
      }
    }

    return action;
  }
}
