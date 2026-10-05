import './fields.dart';
import './validators.dart';

/// A parsed cron expression that finds the times it is scheduled for.
///
/// ```dart
/// final cron = Cron('0 22 * * MON-FRI');
/// final time = DateTime.parse('2019-11-22 16:00:00'); // a Friday
/// cron.nextRelativeTo(time); // 2019-11-22 22:00:00.000
/// cron.untilNextRelativeTo(time); // 6:00:00.000000
/// ```
///
/// Expressions follow Vixie cron, the `cron` in most Linux distributions.
/// See `crontab(5)` for the grammar. Times are compared using the fields of
/// the [DateTime] given, so a local time is matched in local time and a UTC
/// time in UTC.
class Cron {
  /// Parses [expr], a five-field cron expression or a nickname such as
  /// `@daily`.
  ///
  /// Throws an [ArgumentError] if [expr] is not a valid expression, if it can
  /// never match a real date (such as `0 0 30 2 *`), or if it is `@reboot`,
  /// which names an event rather than a time. [isValid] reports the same
  /// errors without throwing.
  Cron(this.expr) {
    if (expr == "@reboot") {
      throw ArgumentError('nickname expression "@reboot" is not supported');
    }
    final fields = parseFields(expr);
    if (fields == null) {
      throw ArgumentError('invalid cron expression: "$expr"');
    }
    _fields = fields;
  }

  /// The expression as passed to the constructor.
  final String expr;
  late final CronFields _fields;

  /// Whether [time] falls on a minute the expression is scheduled for.
  ///
  /// Seconds and smaller units of [time] are ignored. As in cron, when both
  /// day fields are restricted (neither starts with `*`), [time] matches if
  /// either day field matches. Otherwise both must match.
  bool matches(DateTime time) {
    if (!minuteMatches(time) || !hourMatches(time) || !monthMatches(time)) {
      return false;
    }
    // Vixie cron day rule: when either day field starts with `*`, a time must
    // match both. Otherwise both are restricted, and a time matches if EITHER
    // field matches.
    if (_fields.dayOfMonthStar || _fields.dayOfWeekStar) {
      return dayOfMonthMatches(time) && dayOfWeekMatches(time);
    }
    return dayOfMonthMatches(time) || dayOfWeekMatches(time);
  }

  /// Whether the minute field selects the minute of [time].
  bool minuteMatches(DateTime time) => _fields.minutes.contains(time.minute);

  /// Whether the hour field selects the hour of [time].
  bool hourMatches(DateTime time) => _fields.hours.contains(time.hour);

  /// Whether the day-of-month field selects the day of [time].
  bool dayOfMonthMatches(DateTime time) =>
      _fields.daysOfMonth.contains(time.day);

  /// Whether the month field selects the month of [time].
  bool monthMatches(DateTime time) => _fields.months.contains(time.month);

  /// Whether the day-of-week field selects the weekday of [time].
  ///
  /// In the expression, both 0 and 7 mean Sunday.
  bool dayOfWeekMatches(DateTime time) =>
      _fields.daysOfWeek.contains(time.weekday % 7);

  /// The next time the expression is scheduled for after now.
  ///
  /// See [nextRelativeTo].
  DateTime next() {
    return nextRelativeTo(DateTime.now());
  }

  /// The first time the expression is scheduled for after [time].
  ///
  /// The result is always a whole minute and is never [time] itself. The
  /// search steps forward one minute at a time, so a rare schedule such as
  /// `0 0 29 2 *` (February 29th) can take up to about a second.
  DateTime nextRelativeTo(DateTime time) {
    // round the given time to the next exact minute to start the search
    time = time.add(Duration(minutes: 1) -
        Duration(
            seconds: time.second,
            milliseconds: time.millisecond,
            microseconds: time.microsecond));
    while (!matches(time)) {
      time = time.add(Duration(minutes: 1));
    }
    return time;
  }

  /// The last time the expression was scheduled for before now.
  ///
  /// See [previousRelativeTo].
  DateTime previous() {
    return previousRelativeTo(DateTime.now());
  }

  /// The last time the expression was scheduled for before [time].
  ///
  /// The result is always a whole minute and is never [time] itself. The
  /// search steps backward one minute at a time, so a rare schedule can take
  /// up to about a second.
  DateTime previousRelativeTo(DateTime time) {
    // round the given time to the previous exact minute to start the search
    time = time.subtract(Duration(minutes: 1) +
        Duration(
            seconds: time.second,
            milliseconds: time.millisecond,
            microseconds: time.microsecond));
    while (!matches(time)) {
      time = time.subtract(Duration(minutes: 1));
    }
    return time;
  }

  /// The time from now until [next]. Always positive.
  Duration untilNext() {
    return untilNextRelativeTo(DateTime.now());
  }

  /// The time from [time] until [nextRelativeTo] of [time]. Always positive.
  Duration untilNextRelativeTo(DateTime time) {
    return nextRelativeTo(time).difference(time);
  }

  /// The time from now back to [previous]. Always negative.
  Duration sincePrevious() {
    return sincePreviousRelativeTo(DateTime.now());
  }

  /// The time from [time] back to [previousRelativeTo] of [time]. Always
  /// negative, matching [DateTime.difference].
  Duration sincePreviousRelativeTo(DateTime time) {
    return previousRelativeTo(time).difference(time);
  }
}
