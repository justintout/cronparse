import 'package:test/test.dart';

import 'package:cronparse/cronparse.dart';
import 'fixtures.dart';

void main() {
  group("Cron", () {
    group("constructor", () {
      test('throws on invalid expressions', () {
        final tests = regexTests.where((t) => t[1] == false);
        for (final t in tests) {
          final res = () => Cron(t[0]);
          expect(
            res,
            throwsArgumentError,
            reason: "input: ${t[0]}, expected: ArgumentError"
          );
        }
      });
      test('returns a Cron from valid expressions', () {
        final tests = regexTests.where((t) => t[1] == true);
        for (final t in tests) {
          print(t[0]);
          expect(
            Cron(t[0]), 
            isA<Cron>(),
            reason: "input: ${t[0]}, expected: Cron, got: ${Cron(t[0])}",
          );
        }
      });
    });
    group("matchers", () {
      test("always matches all asterisks", () {
        final expression = "* * * * *";
        final cron = Cron(expression);
        final time = DateTime.now();
        final result = cron.matches(time);
        expect(result, isTrue, reason: "expression: $expression, time: $time, got: $result, expected: true");
      });
      group("minute", (){
        test('always matches *', () {
          final cron = Cron("* 1 1 1 1");
          expect(cron.minuteMatches(DateTime.now()), isTrue);
        });
        test("matches an exact value", () {
          final tests = [
            ['0 * * * *', "2020-02-03 08:00:49", isTrue],
            ['0 * * * *', "2020-02-03 08:01:49", isFalse]
          ];
          for (final t in tests) {
            final cron = Cron(t[0]);
            final time = DateTime.parse(t[1]);
            final result = cron.minuteMatches(time);
            expect(result, t[2], reason: "expression: ${t[0]}, time: ${t[1]}, got: $result, expected: ${t[2] == isTrue ? true : false}");
          }
        });
        test("matches range values", () {
          final tests = [
            ['5-9 * * * *', '2020-02-03 08:06:49', isTrue],
            ['5-9 * * * *', '2020-02-03 08:15:49', isFalse],
          ];
          for (final t in tests) {
            final cron = Cron(t[0]);
            final time = DateTime.parse(t[1]);
            final result = cron.minuteMatches(time);
            expect(result, t[2], reason: "expression: ${t[0]}, time: ${t[1]}, got: $result, expected: ${t[2] == isTrue ? true : false}");
          }
        });
        test("matches within a set of values", () {
          final tests = [
            ['1,2,3,4 * * * *', '2020-02-03 08:02:49', isTrue],
            ['1,2,3,4 * * * *', '2020-02-03 08:05:49', isFalse],
            ['1-5,20-30 * * * *', '2020-02-03 08:03:49', isTrue],
            ['1-5,20-30 * * * *', '2020-02-03 08:25:49', isTrue],
            ['1-5,20-30 * * * *', '2020-02-03 08:50:49', isFalse],
            ['1,2,3,50-59 * * * *', '2020-02-03 08:03:49', isTrue],
            ['1,2,3,50-59 * * * *', '2020-02-03 08:53:49', isTrue],
            ['1,2,3,50-59 * * * *', '2020-02-03 08:12:49', isFalse],
          ];
          for (final t in tests) {
            final cron = Cron(t[0]);
            final time = DateTime.parse(t[1]);
            final result = cron.minuteMatches(time);
            expect(result, t[2], reason: "expression: ${t[0]}, time: ${t[1]}, got: $result, expected: ${t[2] == isTrue ? true : false}");
          }
        });
        test("matches skip values", () {
          final tests = [
            ['*/15 * * * *', '2020-02-03 08:30:49', isTrue],
            ['*/15 * * * *', '2020-02-03 08:25:49', isFalse],
            ['10-30/2 * * * *', '2020-02-03 08:25:49', isFalse],
            ['10-30/2 * * * *', '2020-02-03 08:22:49', isTrue],
          ];
          for (final t in tests) {
            final cron = Cron(t[0]);
            final time = DateTime.parse(t[1]);
            final result = cron.minuteMatches(time);
            expect(result, t[2], reason: "expression: ${t[0]}, time: ${t[1]}, got: $result, expected: ${t[2] == isTrue ? true : false}");
          }
        });
      });
      group("hour", (){});
      group("day of month", (){});
      group("month", (){});
      group("day of week", (){
        test('always matches *', () {
          final cron = Cron("1 1 1 1 *");
          expect(cron.dayOfWeekMatches(DateTime.now()), isTrue);
        });
        test("matches an exact value", () {
          final tests = [
            ['* * * * 6', '2019-11-23 05:00:00', isTrue],
            ['* * * * 0', '2019-11-24 05:00:00', isTrue],
            ['* * * * 7', '2019-11-24 05:00:00', isTrue],
            ['* * * * 4', '2019-11-24 05:00:00', isFalse],
          ];
          for (final t in tests) {
            final cron = Cron(t[0]);
            final time = DateTime.parse(t[1]);
            final result = cron.dayOfWeekMatches(time);
            expect(result, t[2], reason: "expression: ${t[0]}, time: ${t[1]}, got: $result, expected: ${t[2] == isTrue ? true : false}");
          }
        });
        test("matches range values", () {
          final tests = [
            ['* * * * 4-7', '2019-11-23 05:00:00', isTrue],
            ['* * * * 1-3', '2019-11-23 05:00:00', isFalse],
          ];
          for (final t in tests) {
            final cron = Cron(t[0]);
            final time = DateTime.parse(t[1]);
            final result = cron.dayOfWeekMatches(time);
            expect(result, t[2], reason: "expression: ${t[0]}, time: ${t[1]}, got: $result, expected: ${t[2] == isTrue ? true : false}");
          }
        });
        test("we pass a test for 'the bug'", () {
          // https://crontab.guru/cron-bug.html
          final cron = Cron('* * *,* * SUN');
          final time = DateTime.parse('2019-11-23 05:00:00');
          final result = cron.matches(time);
          expect(result, true, reason: "expression: ${'* * *,* * SUN'}, time: ${'2019-11-23 05:00:00'}, got: $result, expected: ${true}");
        });
      });
    });
    group("DateTime calculations", (){
      test("nextRelativeTo returns the next matching time", () {
        final tests = [
          // simple tests
          ["* * * * *", "2019-11-23 12:00:00", "2019-11-23 12:01:00"],
          ["* * * * *", "2019-11-23 12:00:01", "2019-11-23 12:01:00"],
          ["5 * * * *", "2019-11-23 12:00:01", "2019-11-23 12:05:00"],
          ["0 13 * * *", "2019-11-23 12:00:01", "2019-11-23 13:00:00"],
          // TODO: range tests
          // TODO: set tests
          // TODO: skip tests
          ["*/5 * * * *", "2019-11-23 12:00:01", "2019-11-23 12:05:00"],
        ];
        for (final t in tests) {
          final cron = Cron(t[0]);
          final input = DateTime.parse(t[1]);
          final expected = DateTime.parse(t[2]);
          final result = cron.nextRelativeTo(input);
          expect(result, expected, reason: "expression: ${t[0]}, got: $result, expected: $expected");
        }
      });
      test("previousRelativeTo returns the previous matching time", () {
        final tests = [
          // simple tests
          ["* * * * *", "2019-11-23 12:00:00", "2019-11-23 11:59:00"],
          ["* * * * *", "2019-11-23 12:00:01", "2019-11-23 11:59:00"],
          ["5 * * * *", "2019-11-23 12:00:00", "2019-11-23 11:05:00"],
          ["0 13 * * *", "2019-11-23 12:00:00", "2019-11-22 13:00:00"],
          // TODO: range tests
          // TODO: set tests
          // TODO: skip tests
          ["*/5 * * * *", "2019-11-23 12:00:01", "2019-11-23 11:55:00"],
        ];
        for (final t in tests) {
          final cron = Cron(t[0]);
          final input = DateTime.parse(t[1]);
          final expected = DateTime.parse(t[2]);
          final result = cron.previousRelativeTo(input);
          expect(result, expected, reason: "expression: ${t[0]}, got: $result, expected: $expected");
        }
      });
    });
    group("Duration calculations", (){
      test("untilNextRelativeTo returns the duration to the next match", () {
        final tests = [
          // simple tests
          ["* * * * *", "2019-11-23 12:00:00", Duration(minutes: 1)],
          ["* * * * *", "2019-11-23 12:00:01", Duration(seconds: 59)],
          ["5 * * * *", "2019-11-23 12:00:00", Duration(minutes: 5)],
          ["0 13 * * *", "2019-11-23 12:00:00", Duration(hours: 1)],
          // TODO: range tests
          // TODO: set tests
          // TODO: skip tests
          ["*/5 * * * *", "2019-11-23 12:00:01", Duration(minutes: 4, seconds: 59)],
        ];
        for (final t in tests) {
          final cron = Cron(t[0]);
          final input = DateTime.parse(t[1]);
          final expected = t[2];
          final result = cron.untilNextRelativeTo(input);
          expect(result, expected, reason: "expression: ${t[0]}, got: $result, expected: $expected");
        }
      });
      test("sincePreviousRelativeTo returns the duration since the previous match", () {
        final tests = [
          // simple tests
          ["* * * * *", "2019-11-23 12:00:00", -Duration(minutes: 1)],
          ["* * * * *", "2019-11-23 12:00:01", -Duration(minutes: 1, seconds: 1)],
          ["5 * * * *", "2019-11-23 12:00:01", -Duration(minutes: 55, seconds: 1)],
          ["0 13 * * *", "2019-11-23 12:00:01", -Duration(hours: 23, seconds: 1)],
          // TODO: range tests
          // TODO: set tests
          // TODO: skip tests
          ["*/5 * * * *", "2019-11-23 12:00:01", -Duration(minutes: 5, seconds: 1)],
        ];
        for (final t in tests) {
          final cron = Cron(t[0]);
          final input = DateTime.parse(t[1]);
          final expected = t[2];
          final result = cron.sincePreviousRelativeTo(input);
          expect(result, expected, reason: "expression: ${t[0]}, got: $result, expected: $expected");
        }
      });
    });
  });
}

