package com.dexterous.flutterlocalnotifications.models;

import static org.junit.Assert.assertEquals;

import com.dexterous.flutterlocalnotifications.models.NotificationAction.NotificationActionInput;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class NotificationActionTest {
  @Test
  public void constructor_populatesAllFields() {
    final HashMap<String, Object> raw = new HashMap<>();

    raw.put("id", "id123");
    raw.put("cancelNotification", true);
    raw.put("title", "abc");
    raw.put("titleColorAlpha", 123);
    raw.put("titleColorRed", 124);
    raw.put("titleColorGreen", 125);
    raw.put("titleColorBlue", 126);
    raw.put("icon", "icon");
    raw.put("contextual", true);
    raw.put("showsUserInterface", true);
    raw.put("allowGeneratedReplies", true);
    raw.put("iconBitmapSource", 4);

    final List<Map<String, Object>> inputs = new ArrayList<>();
    final Map<String, Object> aInput = new HashMap<>();
    aInput.put("choices", Collections.singletonList("choice"));
    aInput.put("allowFreeFormInput", true);
    aInput.put("label", "label");
    aInput.put("allowedMimeTypes", Collections.singletonList("text/plain"));
    inputs.add(aInput);

    raw.put("inputs", inputs);

    final NotificationAction action = new NotificationAction(raw);

    assertEquals("id123", action.id);
    assertEquals(true, action.cancelNotification);
    assertEquals("abc", action.title);
    assertEquals(new Integer(2071756158), action.titleColor);
    assertEquals("icon", action.icon);
    assertEquals(true, action.contextual);
    assertEquals(true, action.showsUserInterface);
    assertEquals(true, action.allowGeneratedReplies);
    assertEquals(IconSource.ByteArray, action.iconSource);
    assertEquals(
        new NotificationActionInput(
            Collections.singletonList("choice"),
            true,
            "label",
            Collections.singletonList("text/plain")),
        action.actionInputs.get(0));
  }
}
