package com.dexterous.flutterlocalnotifications;

public class BigTextStyleInformation extends StyleInformation {
    public String bigText;
    public Boolean htmlFormatBigText;
    public String contentTitle;
    public Boolean htmlFormatContentTitle;
    public String summaryText;
    public Boolean htmlFormatSummaryText;

    public BigTextStyleInformation(String bigText, Boolean htmlFormatBigText, String contentTitle, Boolean htmlFormatContentTitle, String summaryText, Boolean htmlFormatSummaryText) {
        this.bigText = bigText;
        this.htmlFormatBigText = htmlFormatBigText;
        this.contentTitle = contentTitle;
        this.htmlFormatContentTitle = htmlFormatContentTitle;
        this.summaryText = summaryText;
        this.htmlFormatSummaryText = htmlFormatSummaryText;
    }
}
