const _nicknames = {
  '@yearly': '0 0 1 1 *',
  '@annually': '0 0 1 1 *',
  '@monthly': '0 0 1 * *',
  '@weekly': '0 0 * * 0',
  '@daily': '0 0 * * *',
  '@midnight': '0 0 * * *',
  '@hourly': '0 * * * *',
};

const _months = [
  'jan',
  'feb',
  'mar',
  'apr',
  'may',
  'jun',
  'jul',
  'aug',
  'sep',
  'oct',
  'nov',
  'dec'
];
const _days = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];

final _digits = RegExp(r'^[0-9]+$');

/// [CronFields] holds the values each field of a cron expression selects.
class CronFields {
  CronFields._(this.minutes, this.hours, this.daysOfMonth, this.months,
      this.daysOfWeek, this.dayOfMonthStar, this.dayOfWeekStar);

  final Set<int> minutes;
  final Set<int> hours;
  final Set<int> daysOfMonth;
  final Set<int> months;

  /// Days of the week, where 0 is Sunday. 7 is folded into 0.
  final Set<int> daysOfWeek;

  // Vixie cron treats a day field that starts with `*` as unrestricted, even
  // with a step such as `*/2`. This decides whether the day fields combine
  // with AND or with OR.
  final bool dayOfMonthStar;
  final bool dayOfWeekStar;
}

/// `parseFields` parses a cron expression or nickname, following the rules of
/// Vixie cron. It returns null if the expression is malformed or can never
/// match a real date.
CronFields? parseFields(String expr) {
  final expanded = expr.startsWith('@') ? _nicknames[expr] : expr.trim();
  if (expanded == null) return null;
  final parts = expanded.split(RegExp(r'\s+'));
  if (parts.length != 5) return null;

  final minutes = _parseField(parts[0], 0, 59);
  final hours = _parseField(parts[1], 0, 23);
  final daysOfMonth = _parseField(parts[2], 1, 31);
  final months = _parseField(parts[3], 1, 12, names: _months, firstName: 1);
  final daysOfWeek = _parseField(parts[4], 0, 7, names: _days, firstName: 0);
  if (minutes == null ||
      hours == null ||
      daysOfMonth == null ||
      months == null ||
      daysOfWeek == null) {
    return null;
  }
  if (daysOfWeek.remove(7)) daysOfWeek.add(0);

  final fields = CronFields._(minutes, hours, daysOfMonth, months, daysOfWeek,
      parts[2].startsWith('*'), parts[4].startsWith('*'));
  return _hasPossibleDay(fields) ? fields : null;
}

// Every field selects at least one value, so only the day fields can rule out
// every date. With both restricted, a day matches on either field, and every
// weekday occurs. Otherwise day-of-month must name a day that occurs in one of
// the selected months (Feb 30 never does).
bool _hasPossibleDay(CronFields f) {
  if (!f.dayOfMonthStar && !f.dayOfWeekStar) return true;
  for (final month in f.months) {
    // 2000 is a leap year, so February counts its 29th.
    final days = DateTime(2000, month + 1, 0).day;
    if (f.daysOfMonth.any((day) => day <= days)) return true;
  }
  return false;
}

/// `_parseField` returns the values a field selects, or null if the field is
/// malformed. A field is a comma-separated list of elements. Each element is
/// `*`, a value, or a range `a-b`, and `*` or a range may take a step `/n`.
Set<int>? _parseField(String field, int min, int max,
    {List<String> names = const [], int firstName = 0}) {
  int? value(String s) {
    if (_digits.hasMatch(s)) return int.parse(s);
    final i = names.indexOf(s.toLowerCase());
    return i < 0 ? null : i + firstName;
  }

  final values = <int>{};
  for (final element in field.split(',')) {
    final stepParts = element.split('/');
    if (stepParts.length > 2) return null;
    final range = stepParts[0];
    final bounds = range.split('-');
    if (bounds.length > 2) return null;

    int? lo, hi;
    if (range == '*') {
      lo = min;
      hi = max;
    } else {
      // A step needs a range to step through: `5/2` is invalid.
      if (bounds.length == 1 && stepParts.length == 2) return null;
      lo = value(bounds[0]);
      hi = value(bounds.last);
      // `sun` is 0, so a range ending on it, like `fri-sun`, uses 7 instead.
      if (names == _days && bounds.length == 2 && lo != 0) {
        if (bounds[1].toLowerCase() == 'sun') hi = 7;
      }
    }

    var step = 1;
    if (stepParts.length == 2) {
      if (!_digits.hasMatch(stepParts[1])) return null;
      step = int.parse(stepParts[1]);
      if (step < 1) return null;
    }
    if (lo == null || hi == null || lo < min || hi > max || lo > hi) {
      return null;
    }
    for (var i = lo; i <= hi; i += step) {
      values.add(i);
    }
  }
  return values;
}
