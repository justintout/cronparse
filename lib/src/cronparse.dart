import './fields.dart';

/// [Cron] is an object exposing various methods to
/// calculate [DateTime]s and [Duration]s from a given cron expression.
class Cron {
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

  final String expr;
  late final CronFields _fields;

  /// `matches` returns true if the full expression matches the given time;
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

  /// `minuteMatches` returns true if the minute field of the expression
  /// matches the minute of the given time
  bool minuteMatches(DateTime time) => _fields.minutes.contains(time.minute);

  /// `hourMatches` returns true if the hour field of the expression
  /// matches the hour of the given time
  bool hourMatches(DateTime time) => _fields.hours.contains(time.hour);

  /// `dayOfMonthMatches` returns true if the day of month field of the
  /// expression matches the day of month of the given time
  bool dayOfMonthMatches(DateTime time) =>
      _fields.daysOfMonth.contains(time.day);

  /// `monthMatches` returns true if the month field of the expression
  /// matches the month of the given time
  bool monthMatches(DateTime time) => _fields.months.contains(time.month);

  /// `dayOfWeekMatches` returns true if the day of week field of the expression
  /// matches the day of week of the given time.
  ///
  /// Both 0 and 7 represent Sunday. [DateTime.weekday] uses 7 for Sunday, so
  /// it is reduced modulo 7 to match the parsed field.
  bool dayOfWeekMatches(DateTime time) =>
      _fields.daysOfWeek.contains(time.weekday % 7);

  /// `next` calculates the next [DateTime]
  /// the expression is scheduled for, relative to
  /// the current time
  DateTime next() {
    return nextRelativeTo(DateTime.now());
  }

  /// `nextRelativeTo` calculates the next [DateTime]
  /// the expression is scheduled for, relative to
  /// the given time.
  ///
  /// `nextRelativeTo` uses a naive strategy to find the next time by
  /// searching forward each minute until a match is found.
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

  /// `previous` calculates the last [DateTime]
  /// the expression would have been scheduled for,
  /// relative to the current time
  DateTime previous() {
    return previousRelativeTo(DateTime.now());
  }

  /// `previousRelativeTo` calculates the last [DateTime]
  /// the expression would have been scheduled for,
  /// relative to the given time
  ///
  /// `previousRelativeTo` uses a naive strategy to find the previous time by
  /// searching backward each minute until a match is found.
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

  /// `untilNext` returns the [Duration] until
  /// the expression's next scheduled time, relative
  /// to the current time
  Duration untilNext() {
    return untilNextRelativeTo(DateTime.now());
  }

  /// `untilNextRelativeTo` returns the [Duration] until
  /// the expression's next scheduled time, relative
  /// to the given time
  Duration untilNextRelativeTo(DateTime time) {
    return nextRelativeTo(time).difference(time);
  }

  /// `sincePrevious` calculates the [Duration]
  /// since the previous time the expression
  /// would have been scheduled for, relative to
  /// the current time
  Duration sincePrevious() {
    return sincePreviousRelativeTo(DateTime.now());
  }

  /// `sincePreviousRelativeTo` calculates the [Duration]
  /// since the previous time the expression
  /// would have been scheduled for, relative to
  /// the given time
  Duration sincePreviousRelativeTo(DateTime time) {
    return previousRelativeTo(time).difference(time);
  }
}
