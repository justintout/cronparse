/// `isValid` returns true if the given string is 
/// a valid cron expression
// TODO: support Jenkins "H"? 
bool isValid(String expr) {
  if (expr.startsWith('@')) {
    return _nicknameValid(expr);
  }
  final parts = expr.split(' ');
  if (parts.length != 5) return false;
  for (final part in parts) {
    if (part.contains(RegExp(r'^[0-9]+/'))) return false;
    if (part.contains("/") && part.contains(",")) return false;
  }

  return _minuteValid(parts[0])
    && _hourValid(parts[1])
    && _dayOfMonthValid(parts[2])
    && _monthValid(parts[3])
    && _dayOfWeekValid(parts[4]);
}

bool _nicknameValid(String expr) {
  return expr == "@yearly"
    || expr == "@annually"
    || expr == "@monthly" 
    || expr == "@weekly" 
    || expr == "@daily"
    || expr == "@midnight"
    || expr == "@hourly";
}

bool _minuteValid(String part) {
  const int min = 0;
  const int max = 59;
  return _isAsterisk(part) || _hasAllPartsWithin(part, min, max);

}

bool _hourValid(String part) {
  const int min = 0;
  const int max = 23;
  return _isAsterisk(part) || _hasAllPartsWithin(part, min, max);

}

// TODO: support "L", "?", "W"
bool _dayOfMonthValid(String part) {
  const int min = 1;
  const int max = 31;
  return _isAsterisk(part) || _hasAllPartsWithin(part, min, max);
}

bool _monthValid(String part) {
  const int min = 1;
  const int max = 12;
  return _isAsterisk(part) 
    || _isMonthName(part)
    || _hasAllPartsWithin(part, min, max);
}

bool _isMonthName(String part) {
  const months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
  return months.contains(part.toLowerCase());
}

// TODO: support "L", "?", "#"
bool _dayOfWeekValid(String part) {
  const int min = 0;
  const int max = 7;
  return _isAsterisk(part) 
    || _isDayName(part)
    || _hasAllPartsWithin(part, min, max);
}

bool _isDayName(String part) {
  const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  final pp = _explodeParts(part);
  for (final p in pp) {
    if (!days.contains(p.toLowerCase())) return false;
  }
  return true;
}

bool _isWithin(int val, int min, int max) {
  return val >= min && val <= max;
}

bool _isAsterisk(String part) {
  final regex = RegExp(r"^\*(/[0-9]+)?$");
  return regex.hasMatch(part);
}

bool _isValueWithin(String part, int min, int max) {
  try {
    final v = int.parse(part);
    return _isWithin(v, min, max);
  } catch (e) {
    return false;
  }
}

bool _hasAllPartsWithin(String part, int min, int max) {
  final parts = _explodeParts(part);
  for (final p in parts) {
    if (!_isValueWithin(p, min, max)) return false;
  }
  return true;
}

final _partsRegex = RegExp(r"[-\,]");
List<String> _explodeParts(String part) {
  final p = part.split('/')[0];
  return p.split(_partsRegex);
}