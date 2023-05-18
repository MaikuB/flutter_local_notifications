package com.dexterous.flutterlocalnotifications.models;

import androidx.annotation.Keep;

import com.google.gson.*;

import java.lang.reflect.Type;

@Keep
public enum ScheduleMode {
  alarmClock,
  exact,
  exactAllowWhileIdle,
  inexact,
  inexactAllowWhileIdle;

  public boolean useAllowWhileIdle() {
    return this == exactAllowWhileIdle || this == inexactAllowWhileIdle;
  }

  public boolean useExactAlarm() {
    return this == exact || this == exactAllowWhileIdle;
  }

  public boolean useAlarmClock() {
    return this == alarmClock;
  }

  public static class Deserializer implements JsonDeserializer<ScheduleMode> {
    @Override
    public ScheduleMode deserialize(
        JsonElement json, Type typeOfT, JsonDeserializationContext context)
        throws JsonParseException {
      try {
        return ScheduleMode.valueOf(json.getAsString());
      } catch (Exception e) {
        return json.getAsBoolean() ? ScheduleMode.exactAllowWhileIdle : ScheduleMode.exact;
      }
    }
  }
}
