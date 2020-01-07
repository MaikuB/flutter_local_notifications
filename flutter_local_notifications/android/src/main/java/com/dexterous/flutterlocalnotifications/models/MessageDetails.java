package com.dexterous.flutterlocalnotifications.models;

public class MessageDetails {
    public String text;
    public Long timestamp;
    public PersonDetails person;
    public String dataMimeType;
    public String dataUri;

    public MessageDetails(String text, Long timestamp, PersonDetails person, String dataMimeType, String dataUri) {
        this.text = text;
        this.timestamp = timestamp;
        this.person = person;
        this.dataMimeType = dataMimeType;
        this.dataUri = dataUri;
    }
}
