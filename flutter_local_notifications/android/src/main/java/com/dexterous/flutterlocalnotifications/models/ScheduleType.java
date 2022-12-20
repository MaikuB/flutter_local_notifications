
package com.dexterous.flutterlocalnotifications.models;

import androidx.annotation.Keep;

import com.google.gson.*;

import java.lang.reflect.Type;

@Keep
public enum ScheduleType {
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

    public static class Deserializer implements JsonDeserializer<ScheduleType> {
        @Override
        public ScheduleType deserialize(
                JsonElement json, Type typeOfT, JsonDeserializationContext context)
                throws JsonParseException {
            try {
                return ScheduleType.valueOf(json.getAsString());
            } catch (Exception e) {
                return json.getAsBoolean() ? ScheduleType.exactAllowWhileIdle : ScheduleType.inexact;
            }
        }
    }
}