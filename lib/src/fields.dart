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
const _days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

/// `normalizeFields` rewrites the five fields of an expression into numeric
/// form: `*/n` becomes `min-max/n`, and month and day names become numbers.
List<String> normalizeFields(List<String> fields) {
  return [
    _expandStepAsterisk(fields[0], 0, 59),
    _expandStepAsterisk(fields[1], 0, 23),
    _expandStepAsterisk(fields[2], 1, 31),
    _replaceNames(_expandStepAsterisk(fields[3], 1, 12), _months),
    _replaceNames(_expandStepAsterisk(fields[4], 0, 7), _days),
  ];
}

String _expandStepAsterisk(String field, int min, int max) {
  return field.contains('/') ? field.replaceFirst('*', '$min-$max') : field;
}

String _replaceNames(String field, List<String> names) {
  var result = field.toLowerCase();
  for (var i = 0; i < names.length; i++) {
    result = result.replaceAll(names[i], '${i + 1}');
  }
  return result;
}

/// `fieldMatches` evaluates a single normalized cron field against an integer
/// [value].
///
/// It handles the shared grammar for every field: asterisk, skips
/// (`a-b/n`), exact values, ranges (`a-b`), and comma-separated sets
/// of any of those. When [sundayAlias] is set (day-of-week), a field value of
/// 0 also matches a [value] of 7 so that both 0 and 7 mean Sunday.
bool fieldMatches(String field, int value, {bool sundayAlias = false}) {
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
