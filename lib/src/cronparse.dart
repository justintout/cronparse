import './validators.dart';

/// [Cron] is an object exposing various methods to
/// calculate [DateTime]s and [Duration]s from a given cron expression.
class Cron {
  Cron(this.expr) {
    if (!isValid(expr)) {
      throw ArgumentError('invalid cron expression: "$expr"');
    }
    if (expr == "@reboot") {
      throw ArgumentError('nickname expression "@reboot" is not supported');
    }

    if (expr.startsWith("@")) {
      switch (expr) {
        case "@yearly":
          _parsedExpr = "0 0 1 1 *";
          break;
        case "@annually":
          _parsedExpr = "0 0 1 1 *";
          break;
        case "@monthly":
          _parsedExpr = "0 0 1 * *";
          break;
        case "@weekly":
          _parsedExpr = "0 0 * * 0";
          break;
        case "@daily":
          _parsedExpr = "0 0 * * *";
          break;
        case "@hourly":
          _parsedExpr = "0 * * * *";
          break;
        case "@midnight":
          _parsedExpr = "0 23 * * *";
          break;
        default:
          _parsedExpr = expr;
      }
    } else {
      _parsedExpr = expr;
    }

    final field = _parsedExpr.split(" ");
    assert(field.length == 5);

    _minuteField =
        field[0].contains("/") ? field[0].replaceFirst("*", "0-59") : field[0];
    _hourField =
        field[1].contains("/") ? field[1].replaceFirst("*", "0-23") : field[1];
    _dayOfMonthField =
        field[2].contains("/") ? field[2].replaceFirst("*", "1-31") : field[2];

    final monthField =
        field[3].contains("/") ? field[3].replaceFirst("*", "1-12") : field[3];
    _monthField = monthField
        .toLowerCase()
        .replaceAll('jan', '1')
        .replaceAll('feb', '2')
        .replaceAll('mar', '3')
        .replaceAll('apr', '4')
        .replaceAll('may', '5')
        .replaceAll('jun', '6')
        .replaceAll('jul', '7')
        .replaceAll('aug', '8')
        .replaceAll('sep', '9')
        .replaceAll('oct', '10')
        .replaceAll('nov', '11')
        .replaceAll('dec', '12');

    final dayOfWeekField =
        field[4].contains("/") ? field[4].replaceFirst("*", "0-7") : field[4];
    _dayOfWeekField = dayOfWeekField
        .toLowerCase()
        .replaceAll('mon', '1')
        .replaceAll('tue', '2')
        .replaceAll('wed', '3')
        .replaceAll('thu', '4')
        .replaceAll('fri', '5')
        .replaceAll('sat', '6')
        .replaceAll('sun', '7');
  }

  final String expr;
  late final String _parsedExpr;
  late final String _minuteField;
  late final String _hourField;
  late final String _dayOfMonthField;
  late final String _monthField;
  late final String _dayOfWeekField;

  /// `matches` returns true if the full expression matches the given time;
  bool matches(DateTime time) {
    if (!minuteMatches(time) || !hourMatches(time) || !monthMatches(time)) {
      return false;
    }
    // POSIX cron day rule: when both the day-of-month and the day-of-week
    // fields are restricted (neither is `*`), a time matches if EITHER field
    // matches. When only one of them is restricted, only that field applies.
    final domRestricted = _dayOfMonthField != '*';
    final dowRestricted = _dayOfWeekField != '*';
    if (domRestricted && dowRestricted) {
      return dayOfMonthMatches(time) || dayOfWeekMatches(time);
    }
    return dayOfMonthMatches(time) && dayOfWeekMatches(time);
  }

  /// `minuteMatches` returns true if the minute field of the expression
  /// matches the minute of the given time
  bool minuteMatches(DateTime time) {
    return _fieldMatches(_minuteField, time.minute);
  }

  /// `hourMatches` returns true if the hour field of the expression
  /// matches the hour of the given time
  bool hourMatches(DateTime time) {
    return _fieldMatches(_hourField, time.hour);
  }

  /// `dayOfMonthMatches` returns true if the day of month field of the
  /// expression matches the day of month of the given time
  bool dayOfMonthMatches(DateTime time) {
    return _fieldMatches(_dayOfMonthField, time.day);
  }

  /// `monthMatches` returns true if the month field of the expression
  /// matches the month of the given time
  bool monthMatches(DateTime time) {
    return _fieldMatches(_monthField, time.month);
  }

  /// `dayOfWeekMatches` returns true if the day of week field of the expression
  /// matches the day of week of the given time.
  ///
  /// Both 0 and 7 represent Sunday. [DateTime.weekday] uses 7 for Sunday, so
  /// a cron value of 0 is treated as matching a weekday of 7.
  bool dayOfWeekMatches(DateTime time) {
    return _fieldMatches(_dayOfWeekField, time.weekday, sundayAlias: true);
  }

  /// `_fieldMatches` evaluates a single cron field against an integer [value].
  ///
  /// It handles the shared grammar for every field: asterisk, skips
  /// (`*/n`, `a-b/n`), exact values, ranges (`a-b`), and comma-separated sets
  /// of any of those. When [sundayAlias] is set (day-of-week), a field value of
  /// 0 also matches a [value] of 7 so that both 0 and 7 mean Sunday.
  bool _fieldMatches(String field, int value, {bool sundayAlias = false}) {
    if (field == '*') return true;

    bool hits(int i) => i == value || (sundayAlias && i == 0 && value == 7);

    for (final part in field.split(',')) {
      if (part.contains('/')) {
        final s = part.split('/');
        final skips = int.parse(s[1]);
        final bounds = s[0].split('-').map(int.parse).toList();
        for (var i = bounds[0]; i <= bounds[1]; i += skips) {
          if (hits(i)) return true;
        }
        continue;
      }
      if (part.contains('-')) {
        final bounds = part.split('-').map(int.parse).toList();
        for (var i = bounds[0]; i <= bounds[1]; i++) {
          if (hits(i)) return true;
        }
        continue;
      }
      if (hits(int.parse(part))) return true;
    }
    return false;
  }

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
