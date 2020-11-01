package com.dexterous.flutterlocalnotifications.models;

import java.util.Map;

public class NotificationAction {

	private static final String ID = "id";
	private static final String TITLE = "title";
	private static final String ICON = "icon";
	private static final String ICON_SOURCE = "iconBitmapSource";

	public String id;
	public String title;
	public String icon;
	public IconSource iconSource;

	public static NotificationAction from(Map<String, Object> arguments) {
		NotificationAction action = new NotificationAction();
		action.id = (String) arguments.get(ID);
		action.title = (String) arguments.get(TITLE);
		action.icon = (String) arguments.get(ICON);
		Integer iconSourceIndex = (Integer) arguments.get(ICON_SOURCE);
		if (iconSourceIndex != null) {
			action.iconSource = IconSource.values()[iconSourceIndex];
		}

		return action;
	}
}