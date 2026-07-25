import 'dart:ui';

import '../icon.dart';
import 'default_style_information.dart';

/// A single coloured segment of the track in a [ProgressStyleInformation].
///
/// The [length] is relative to the sum of the lengths of all segments, which
/// together define the range of [ProgressStyleInformation.progress].
class ProgressStyleSegment {
  /// Constructs an instance of [ProgressStyleSegment].
  const ProgressStyleSegment(this.length, {this.id, this.color});

  /// The length of the segment along the track.
  final int length;

  /// An optional stable identifier used to keep the segment consistent as the
  /// notification is updated.
  final int? id;

  /// The colour used to render the segment.
  final Color? color;
}

/// A single point (milestone) drawn on the track of a
/// [ProgressStyleInformation], for example to mark a stage of a delivery.
class ProgressStylePoint {
  /// Constructs an instance of [ProgressStylePoint].
  const ProgressStylePoint(this.position, {this.id, this.color});

  /// The position of the point along the track.
  final int position;

  /// An optional stable identifier used to keep the point consistent as the
  /// notification is updated.
  final int? id;

  /// The colour used to render the point.
  final Color? color;
}

/// Used to create a progress-centric ("Live Update") notification on
/// Android 16 (API level 36) and newer.
///
/// The track is split into [segments] and may be annotated with [points]. The
/// current [progress] moves an optional [progressTrackerIcon] along the track,
/// which may be bookended by [progressStartIcon] and [progressEndIcon]. This
/// style is one of the requirements for a notification to be promoted as a Live
/// Update; see [AndroidNotificationDetails.requestPromotedOngoing]. It is
/// ignored on older versions of Android.
class ProgressStyleInformation extends DefaultStyleInformation {
  /// Constructs an instance of [ProgressStyleInformation].
  const ProgressStyleInformation(
    this.segments, {
    this.points = const <ProgressStylePoint>[],
    this.progress = 0,
    this.progressIndeterminate = false,
    this.styledByProgress = true,
    this.progressTrackerIcon,
    this.progressStartIcon,
    this.progressEndIcon,
    bool htmlFormatContent = false,
    bool htmlFormatTitle = false,
  }) : super(htmlFormatContent, htmlFormatTitle);

  /// The segments that make up the track.
  final List<ProgressStyleSegment> segments;

  /// The points drawn on top of the track.
  final List<ProgressStylePoint> points;

  /// The current progress, between zero and the sum of the [segments] lengths.
  final int progress;

  /// Whether the progress is indeterminate.
  ///
  /// When `true` the [progress] value is ignored and an indeterminate
  /// animation is shown instead.
  final bool progressIndeterminate;

  /// Whether the track is styled (coloured) only up to the current [progress].
  final bool styledByProgress;

  /// The icon moved along the track to indicate the current [progress].
  final AndroidIcon<Object>? progressTrackerIcon;

  /// The icon shown at the start of the track.
  final AndroidIcon<Object>? progressStartIcon;

  /// The icon shown at the end of the track.
  final AndroidIcon<Object>? progressEndIcon;
}
