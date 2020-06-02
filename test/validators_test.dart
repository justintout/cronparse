import 'package:test/test.dart';

import 'package:cronparse/src/validators.dart';

import 'fixtures.dart';

void main() {
  group("`isValid`", () {
    test('returns true for valid cron expressions', () {
      for (final t in regexTests.where((t) => t[1] == true)) {
        final res = isValid(t[0]);
        expect(res, equals(t[1]), reason: "input: ${t[0]}, expected: ${t[1]}, got: $res");
      }
    });
    test('returns false for invalid cron expressions', () {
      for (final t in regexTests.where((t) => t[1] == false)) {
        final res = isValid(t[0]);
        expect(res, equals(t[1]), reason: "input: ${t[0]}, expected: false, got: $res");
      }
    });
  });
}