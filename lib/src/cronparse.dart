// check interfaces in that cron package and conform to them 
// if we feel nice 

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
      switch(expr) {
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
      }
    } else {
      _parsedExpr = expr;
    }

    final field = _parsedExpr.split(" ");
    assert(field.length == 5);

    _minuteField = field[0].contains("/") 
      ? field[0].replaceFirst("*", "0-59")
      : field[0];
    _hourField = field[1].contains("/") 
      ? field[1].replaceFirst("*", "0-23")
      : field[1];
    _dayOfMonthField = field[2].contains("/") 
      ? field[2].replaceFirst("*", "1-31")
      : field[2];

    _monthField = field[3].contains("/") 
      ? field[3].replaceFirst("*", "1-12")
      : field[3];
    _monthField = _monthField.toLowerCase()
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

    _dayOfWeekField = field[4].contains("/") 
      ? field[4].replaceFirst("*", "0-7")
      : field[4];
    _dayOfWeekField = _dayOfWeekField.toLowerCase()
      .replaceAll('mon', '1')
      .replaceAll('tue', '2')
      .replaceAll('wed', '3')
      .replaceAll('thu', '4')
      .replaceAll('fri', '5')
      .replaceAll('sat', '6')
      .replaceAll('sun', '7');
  }

  final String expr;
  String _parsedExpr;
  String _minuteField;
  String _hourField;
  String _dayOfMonthField;
  String _monthField;
  String _dayOfWeekField;

  /// `matches` returns true if the full expression matches the given time;
  bool matches(DateTime time) {
    return minuteMatches(time) 
      && hourMatches(time)
      && monthMatches(time)
      && (dayOfMonthMatches(time) || dayOfWeekMatches(time));
  }

  /// `minuteMatches` returns true if the minute field of the expression
  /// matches the minute of the given time
  bool minuteMatches(DateTime time) {
    if (_minuteField == '*') return true;

    if (_minuteField.contains("/")) {
      final s = _minuteField.split("/");
      var skips = int.parse(s[1]);
      final bounds = s[0].split("-").map((v) => int.parse(v)).toList();
      for (var i = bounds[0]; i <= bounds[1]; i+=skips) {
        if (i == time.minute) return true;
      }
      return false;
    }
    assert(!_minuteField.contains("/"));

    final values = _minuteField.split(',');
    for (final value in values) {
      if (value.contains("-")) {
        final bounds = value.split("-").map((v) => int.parse(v)).toList();
        for (var i = bounds[0]; i <= bounds[1]; i++) {
          if (i == time.minute) return true;
        }
        continue;
      }
      assert(!value.contains("-"));
      if (int.parse(value) == time.minute) return true;
    }
    return false;
  }

  /// `hourMatches` returns true if the hour field of the expression
  /// matches the hour of the given time
  bool hourMatches(DateTime time) {
    if (_hourField == '*') return true;

    if (_hourField.contains("/")) {
      final s = _hourField.split("/");
      var skips = int.parse(s[1]);
      final bounds = s[0].split("-").map((v) => int.parse(v)).toList();
      for (var i = bounds[0]; i <= bounds[1]; i+=skips) {
        if (i == time.hour) return true;
      }
      return false;
    }
    assert(!_hourField.contains("/"));

    final values = _hourField.split(',');
    for (final value in values) {
      if (value.contains("-")) {
        final bounds = _hourField.split("-").map((v) => int.parse(v)).toList();
        for (var i = bounds[0]; i <= bounds[1]; i++) {
          if (i == time.hour) return true;
        }
      }
      if (int.parse(value) == time.hour) return true;
    }
    return false;
  }

  /// `dayOfMonthMatches` returns true if the day of month field of the expression
  /// matches the day of month of the given time
  bool dayOfMonthMatches(DateTime time) { 
    if (_dayOfMonthField == '*') return true;

    if (_dayOfMonthField.contains("/")) {
      final s = _dayOfWeekField.split("/");
      var skips = int.parse(s[1]);
      final bounds = s[0].split("-").map((v) => int.parse(v)).toList();
      for (var i = bounds[0]; i <= bounds[1]; i+=skips) {
        if (i == time.day) return true;
      }
      return false;
    }
    assert(!_dayOfMonthField.contains("/"));

    final values = _dayOfMonthField.split(',');
    for (final value in values) {
      if (value.contains("-")) {
        final bounds = _dayOfMonthField.split("-").map((v) => int.parse(v)).toList();
        for (var i = bounds[0]; i <= bounds[1]; i++) {
          if (i == time.day) return true;
        }
      }
      if (int.parse(value) == time.day) return true;
    }
    return false;
  }

  /// `monthMatches` returns true if the month field of the expression
  /// matches the month of the given time
  bool monthMatches(DateTime time) {
    assert(!_dayOfWeekField.contains(RegExp(r'a-zA-Z')));

    if (_monthField == '*') return true;

    if (_monthField.contains("/")) {
      final s = _minuteField.split("/");
      var skips = int.parse(s[1]);
      final bounds = s[0].split("-").map((v) => int.parse(v)).toList();
      for (var i = bounds[0]; i <= bounds[1]; i+=skips) {
        if (i == time.month) return true;
      }
      return false;
    }
    assert(!_monthField.contains("/"));

    final values = _monthField.split(',');
    for (final value in values) {
      if (value.contains("-")) {
        final bounds = _monthField.split("-").map((v) => int.parse(v)).toList();
        for (var i = bounds[0]; i <= bounds[1]; i++) {
          if (i == time.month) return true;
        }
      }
      if (int.parse(value) == time.month) return true;
    }
    return false;
  }

  /// `dayOfWeekMatches` returns true if the day of week field of the expression
  /// matches the day of week of the given time
  bool dayOfWeekMatches(DateTime time) {
    assert(!_dayOfWeekField.contains(RegExp(r'a-zA-Z')));

    if (_dayOfWeekField == '*') return true;    

    if (_dayOfWeekField.contains("/")) {
      final s = _dayOfWeekField.split("/");
      var skips = int.parse(s[1]);
      final bounds = s[0].split("-").map((v) => int.parse(v)).toList();
      for (var i = bounds[0]; i <= bounds[1]; i+=skips) {
        if (i == time.weekday || (i == 0 && time.weekday == 7)) return true;
      }
      return false;
    }
    assert(!_dayOfWeekField.contains("/"));

    final values = _dayOfWeekField.split(',');
    for (final value in values) {
      if (value.contains("-")) {
        final bounds = _dayOfWeekField.split("-").map((v) => int.parse(v)).toList();
        for (var i = bounds[0]; i <= bounds[1]; i++) {
          if (i == time.weekday || (i == 0 && time.weekday == 7)) return true;
        }
      }
      final v = int.parse(value);
      if (v == time.weekday || (v == 0 && time.weekday == 7)) return true;
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
  /// `nextRelativeTo` uses a naive strategy to find the next time by searching forward each minute 
  /// until a match is found.  
  DateTime nextRelativeTo(DateTime time) {
    // round the given time to the next exact minute to start the search
    time = time.add(Duration(minutes: 1) - Duration(seconds: time.second, milliseconds: time.millisecond, microseconds: time.microsecond));
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
  /// `previousRelativeTo` uses a naive strategy to find the next time by searching backward each minute 
  /// until a match is found.  
  DateTime previousRelativeTo(DateTime time) {
    // round the given time to the previous exact minute to start the search
    time = time.subtract(Duration(minutes: 1) + Duration(seconds: time.second, milliseconds: time.millisecond, microseconds: time.microsecond));
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
