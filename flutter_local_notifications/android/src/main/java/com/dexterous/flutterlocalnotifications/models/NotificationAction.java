package com.dexterous.flutterlocalnotifications.models;

import android.graphics.Color;

import androidx.annotation.Keep;
import androidx.annotation.Nullable;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@Keep
public class NotificationAction implements Serializable {
  public static class NotificationActionInput implements Serializable {

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

    @SuppressWarnings("EqualsReplaceableByObjectsCall")
    @Override
    public boolean equals(Object o) {
      if (this == o) {
        return true;
      }
      if (o == null || getClass() != o.getClass()) {
        return false;
      }

      NotificationActionInput that = (NotificationActionInput) o;

      if (choices != null ? !choices.equals(that.choices) : that.choices != null) {
        return false;
      }
      if (allowFreeFormInput != null
          ? !allowFreeFormInput.equals(that.allowFreeFormInput)
          : that.allowFreeFormInput != null) {
        return false;
      }
      if (label != null ? !label.equals(that.label) : that.label != null) {
        return false;
      }
      return allowedMimeTypes != null
          ? allowedMimeTypes.equals(that.allowedMimeTypes)
          : that.allowedMimeTypes == null;
    }

    @Override
    public int hashCode() {
      int result = choices != null ? choices.hashCode() : 0;
      result = 31 * result + (allowFreeFormInput != null ? allowFreeFormInput.hashCode() : 0);
      result = 31 * result + (label != null ? label.hashCode() : 0);
      result = 31 * result + (allowedMimeTypes != null ? allowedMimeTypes.hashCode() : 0);
      return result;
    }

    @Nullable public final List<String> choices;
    public final Boolean allowFreeFormInput;
    public final String label;
    @Nullable public final List<String> allowedMimeTypes;
  }

  private static final String ID = "id";
  private static final String INPUTS = "inputs";
  private static final String TITLE = "title";
  private static final String TITLE_COLOR_ALPHA = "titleColorAlpha";
  private static final String TITLE_COLOR_RED = "titleColorRed";
  private static final String TITLE_COLOR_GREEN = "titleColorGreen";
  private static final String TITLE_COLOR_BLUE = "titleColorBlue";
  private static final String ICON = "icon";
  private static final String ICON_SOURCE = "iconBitmapSource";

  private static final String CONTEXTUAL = "contextual";
  private static final String SHOWS_USER_INTERFACE = "showsUserInterface";
  private static final String ALLOW_GENERATED_REPLIES = "allowGeneratedReplies";
  private static final String CANCEL_NOTIFICATION = "cancelNotification";

  public final String id;
  public final String title;
  @Nullable public final Integer titleColor;
  @Nullable public final String icon;
  @Nullable public final Boolean cancelNotification;
  @Nullable public final Boolean contextual;
  @Nullable public final Boolean showsUserInterface;
  @Nullable public final Boolean allowGeneratedReplies;
  @Nullable public final IconSource iconSource;
  // actionInputs is annotated as nullable as the Flutter API use to allow this to be nullable
  // before null-safety was added in
  @Nullable public final List<NotificationActionInput> actionInputs = new ArrayList<>();

  public NotificationAction(Map<String, Object> arguments) {
    id = (String) arguments.get(ID);
    cancelNotification = (Boolean) arguments.get(CANCEL_NOTIFICATION);
    title = (String) arguments.get(TITLE);

    Integer a = (Integer) arguments.get(TITLE_COLOR_ALPHA);
    Integer r = (Integer) arguments.get(TITLE_COLOR_RED);
    Integer g = (Integer) arguments.get(TITLE_COLOR_GREEN);
    Integer b = (Integer) arguments.get(TITLE_COLOR_BLUE);
    if (a != null && r != null && g != null && b != null) {
      titleColor = Color.argb(a, r, g, b);
    } else {
      titleColor = null;
    }

    icon = (String) arguments.get(ICON);
    contextual = (Boolean) arguments.get(CONTEXTUAL);
    showsUserInterface = (Boolean) arguments.get(SHOWS_USER_INTERFACE);
    allowGeneratedReplies = (Boolean) arguments.get(ALLOW_GENERATED_REPLIES);

    Integer iconSourceIndex = (Integer) arguments.get(ICON_SOURCE);
    if (iconSourceIndex != null) {
      iconSource = IconSource.values()[iconSourceIndex];
    } else {
      iconSource = null;
    }

    if (arguments.get(INPUTS) != null) {
      @SuppressWarnings("unchecked")
      List<Map<String, Object>> inputs = (List<Map<String, Object>>) arguments.get(INPUTS);

      if (inputs != null) {
        for (Map<String, Object> input : inputs) {
          actionInputs.add(
              new NotificationActionInput(
                  castList(String.class, (Collection<?>) input.get("choices")),
                  (Boolean) input.get("allowFreeFormInput"),
                  (String) input.get("label"),
                  castList(String.class, (Collection<?>) input.get("allowedMimeTypes"))));
        }
      }
    }
  }

  public static <T> List<T> castList(
      Class<? extends T> clazz, @Nullable Collection<?> rawCollection) {
    if (rawCollection == null) {
      return Collections.emptyList();
    }

    List<T> result = new ArrayList<>(rawCollection.size());
    for (Object o : rawCollection) {
      try {
        result.add(clazz.cast(o));
      } catch (ClassCastException e) {
        // log the exception or other error handling
      }
    }
    return result;
  }
}
