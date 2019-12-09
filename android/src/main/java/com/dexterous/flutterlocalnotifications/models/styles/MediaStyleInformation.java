package com.dexterous.flutterlocalnotifications.models.styles;

import java.util.ArrayList;

public class MediaStyleInformation extends DefaultStyleInformation {
    public ArrayList<Integer> showActionsInCompactView;

    public MediaStyleInformation(ArrayList<Integer> showActionsInCompactView, Boolean htmlFormatTitle, Boolean htmlFormatBody) {
        super(htmlFormatTitle, htmlFormatBody);
        this.showActionsInCompactView = showActionsInCompactView;
    }
}
