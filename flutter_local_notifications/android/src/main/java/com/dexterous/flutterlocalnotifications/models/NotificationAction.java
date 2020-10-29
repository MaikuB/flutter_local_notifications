package com.dexterous.flutterlocalnotifications.models;

import java.util.Map;

public class NotificationAction {

	private static final String ID = "id";
	private static final String TITLE = "title";

	public String id;
	public String title;

	public static NotificationAction from(Map<String, Object> arguments) {
		NotificationAction action = new NotificationAction();
		action.id = (String) arguments.get(ID);
		action.title = (String) arguments.get(TITLE);
		return action;
	}
}