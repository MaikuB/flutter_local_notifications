package com.dexterous.flutterlocalnotifications;

import static org.junit.Assert.assertEquals;

import com.dexterous.flutterlocalnotifications.models.DateTimeComponents;
import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import java.time.Clock;
import java.time.LocalDateTime;
import java.time.ZoneId;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class NextFireDateMatchingDateTimeComponentsTest {
  // In Europe/Berlin, clocks go forward from 02:00 to 03:00 on 2027-03-28 (a Sunday) and back
  // from 03:00 to 02:00 on 2026-10-25.
  private static final ZoneId BERLIN = ZoneId.of("Europe/Berlin");

  @Test
  public void dailyTimeInGap_isKeptForTheTransitionDay() {
    NotificationDetails details = details("2027-03-29T02:30", DateTimeComponents.Time);

    // The alarm for this date resolves 02:30 to 03:30, but 02:30 is what gets stored.
    assertEquals("2027-03-28T02:30:00", nextFireDate(details, "2027-03-27T21:00"));
  }

  @Test
  public void dailyTimeInGap_repeatsAtTheSameTimeAfterTheTransition() {
    // The transition day's occurrence fired at 03:30 and computes the next one.
    NotificationDetails details = details("2027-03-28T02:30", DateTimeComponents.Time);

    assertEquals("2027-03-29T02:30:00", nextFireDate(details, "2027-03-28T03:30:05"));
  }

  @Test
  public void weeklyTimeInGap_keepsItsTimeWhenTheSearchCrossesTheTransition() {
    NotificationDetails details =
        details("2027-03-22T02:30", DateTimeComponents.DayOfWeekAndTime); // a Monday

    assertEquals("2027-03-29T02:30:00", nextFireDate(details, "2027-03-26T21:00"));
  }

  @Test
  public void dailyTimeInOverlap_firesOnlyAtItsFirstOccurrence() {
    NotificationDetails details = details("2026-10-24T02:30", DateTimeComponents.Time);

    // 02:30:05 resolves to the first 02:30 (CEST), right after it fired.
    assertEquals("2026-10-26T02:30:00", nextFireDate(details, "2026-10-25T02:30:05"));
  }

  @Test
  public void timeOutsideTransitions_isUnchanged() {
    NotificationDetails daily = details("2027-03-20T09:00", DateTimeComponents.Time);
    NotificationDetails weekly = details("2027-03-20T09:00", DateTimeComponents.DayOfWeekAndTime);
    NotificationDetails monthly =
        details("2027-01-31T09:00", DateTimeComponents.DayOfMonthAndTime);
    NotificationDetails yearly = details("2026-02-14T09:00", DateTimeComponents.DateAndTime);

    assertEquals("2027-03-27T09:00:00", nextFireDate(daily, "2027-03-27T08:00"));
    assertEquals("2027-03-28T09:00:00", nextFireDate(daily, "2027-03-27T10:00"));
    assertEquals("2027-03-27T09:00:00", nextFireDate(weekly, "2027-03-22T10:00"));
    assertEquals("2027-03-31T09:00:00", nextFireDate(monthly, "2027-03-01T10:00"));
    assertEquals("2028-02-14T09:00:00", nextFireDate(yearly, "2027-02-14T10:00"));
  }

  private static NotificationDetails details(
      String scheduledDateTime, DateTimeComponents matchDateTimeComponents) {
    NotificationDetails details = new NotificationDetails();
    details.scheduledDateTime = scheduledDateTime;
    details.timeZoneName = BERLIN.getId();
    details.matchDateTimeComponents = matchDateTimeComponents;
    return details;
  }

  private static String nextFireDate(NotificationDetails details, String localNow) {
    Clock clock = Clock.fixed(LocalDateTime.parse(localNow).atZone(BERLIN).toInstant(), BERLIN);
    return FlutterLocalNotificationsPlugin.getNextFireDateMatchingDateTimeComponents(
        details, clock);
  }
}
