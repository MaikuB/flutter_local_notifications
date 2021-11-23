package com.dexterous.flutterlocalnotifications.models;

import androidx.annotation.Keep;

import java.io.Serializable;
import java.util.Map;

@Keep
public class NotificationChannelGroupDetails implements Serializable {
  private static final String ID = "id";
  private static final String NAME = "name";
  private static final String DESCRIPTION = "description";

  public String id;
  public String name;
  public String description;

  public static NotificationChannelGroupDetails from(Map<String, Object> arguments) {
    NotificationChannelGroupDetails notificationChannelGroupDetails =
        new NotificationChannelGroupDetails();
    notificationChannelGroupDetails.id = (String) arguments.get(ID);
    notificationChannelGroupDetails.name = (String) arguments.get(NAME);
    notificationChannelGroupDetails.description = (String) arguments.get(DESCRIPTION);
    return notificationChannelGroupDetails;
  }
}
