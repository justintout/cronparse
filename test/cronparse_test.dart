import 'package:test/test.dart';

import 'package:cronparse/cronparse.dart';
import 'fixtures.dart';

void main() {
  group("CronParser constructor", () {
    test('throws on invalid expressions', () {
      final tests = regexTests.where((t) => t[1] == false);
      for (final t in tests) {
        final res = () => CronParser(t[0]);
        expect(
          res,
          throwsArgumentError,
          reason: "input: ${t[0]}, expected: ArgumentError"
        );
      }
    });
    test('returns a CronParser from valid expressions', () {
      final tests = regexTests.where((t) => t[1] == true);
      for (final t in tests) {
        expect(
          CronParser(t[0]), 
          isA<CronParser>(),
          reason: "input: ${t[0]}, expected: CronParser, got: ${CronParser(t[0])}",
        );
      }
    });
  });
}

