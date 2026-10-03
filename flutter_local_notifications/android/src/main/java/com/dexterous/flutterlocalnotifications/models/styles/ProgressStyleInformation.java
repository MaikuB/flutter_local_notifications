package com.dexterous.flutterlocalnotifications.models.styles;

import androidx.annotation.Keep;

import com.dexterous.flutterlocalnotifications.models.IconSource;

import java.util.ArrayList;

@Keep
public class ProgressStyleInformation extends DefaultStyleInformation {
  public Integer progress;
  public Boolean progressIndeterminate;
  public Boolean styledByProgress;
  public ArrayList<ProgressStyleSegment> segments;
  public ArrayList<ProgressStylePoint> points;
  public Object progressTrackerIcon;
  public IconSource progressTrackerIconSource;
  public Object progressStartIcon;
  public IconSource progressStartIconSource;
  public Object progressEndIcon;
  public IconSource progressEndIconSource;

  public ProgressStyleInformation(
      Boolean htmlFormatTitle,
      Boolean htmlFormatBody,
      Integer progress,
      Boolean progressIndeterminate,
      Boolean styledByProgress,
      ArrayList<ProgressStyleSegment> segments,
      ArrayList<ProgressStylePoint> points,
      Object progressTrackerIcon,
      IconSource progressTrackerIconSource,
      Object progressStartIcon,
      IconSource progressStartIconSource,
      Object progressEndIcon,
      IconSource progressEndIconSource) {
    super(htmlFormatTitle, htmlFormatBody);
    this.progress = progress;
    this.progressIndeterminate = progressIndeterminate;
    this.styledByProgress = styledByProgress;
    this.segments = segments;
    this.points = points;
    this.progressTrackerIcon = progressTrackerIcon;
    this.progressTrackerIconSource = progressTrackerIconSource;
    this.progressStartIcon = progressStartIcon;
    this.progressStartIconSource = progressStartIconSource;
    this.progressEndIcon = progressEndIcon;
    this.progressEndIconSource = progressEndIconSource;
  }
}
