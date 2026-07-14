import 'package:test/test.dart';

import 'package:cronparse/cronparse.dart';
import 'fixtures.dart';

void main() {
  group("Cron", () {
    group("constructor", () {
      test('throws on invalid expressions', () {
        final tests = regexTests.where((t) => t[1] == false);
        for (final t in tests) {
          final res = () => Cron(t[0] as String);
          expect(res, throwsArgumentError,
              reason: "input: ${t[0]}, expected: ArgumentError");
        }
      });
      test('returns a Cron from valid expressions', () {
        final tests = regexTests.where((t) => t[1] == true);
        for (final t in tests) {
          print(t[0]);
          final expr = t[0] as String;
          expect(
            Cron(expr),
            isA<Cron>(),
            reason: "input: $expr, expected: Cron, got: ${Cron(expr)}",
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
        expect(result, isTrue,
            reason:
                "expression: $expression, time: $time, got: $result, expected: true");
      });
      group("minute", () {
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
            final cron = Cron(t[0] as String);
            final time = DateTime.parse(t[1] as String);
            final result = cron.minuteMatches(time);
            expect(result, t[2] as Matcher,
                reason:
                    "expression: ${t[0]}, time: ${t[1]}, got: $result, expected: ${t[2] == isTrue ? true : false}");
          }
        });
        test("matches range values", () {
          final tests = [
            ['5-9 * * * *', '2020-02-03 08:06:49', isTrue],
            ['5-9 * * * *', '2020-02-03 08:15:49', isFalse],
          ];
          for (final t in tests) {
            final cron = Cron(t[0] as String);
            final time = DateTime.parse(t[1] as String);
            final result = cron.minuteMatches(time);
            expect(result, t[2] as Matcher,
                reason:
                    "expression: ${t[0]}, time: ${t[1]}, got: $result, expected: ${t[2] == isTrue ? true : false}");
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
            final cron = Cron(t[0] as String);
            final time = DateTime.parse(t[1] as String);
            final result = cron.minuteMatches(time);
            expect(result, t[2] as Matcher,
                reason:
                    "expression: ${t[0]}, time: ${t[1]}, got: $result, expected: ${t[2] == isTrue ? true : false}");
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
            final cron = Cron(t[0] as String);
            final time = DateTime.parse(t[1] as String);
            final result = cron.minuteMatches(time);
            expect(result, t[2] as Matcher,
                reason:
                    "expression: ${t[0]}, time: ${t[1]}, got: $result, expected: ${t[2] == isTrue ? true : false}");
          }
        });
      });
      group("hour", () {});
      group("day of month", () {});
      group("month", () {});
      group("day of week", () {
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
            final cron = Cron(t[0] as String);
            final time = DateTime.parse(t[1] as String);
            final result = cron.dayOfWeekMatches(time);
            expect(result, t[2] as Matcher,
                reason:
                    "expression: ${t[0]}, time: ${t[1]}, got: $result, expected: ${t[2] == isTrue ? true : false}");
          }
        });
        test("matches range values", () {
          final tests = [
            ['* * * * 4-7', '2019-11-23 05:00:00', isTrue],
            ['* * * * 1-3', '2019-11-23 05:00:00', isFalse],
          ];
          for (final t in tests) {
            final cron = Cron(t[0] as String);
            final time = DateTime.parse(t[1] as String);
            final result = cron.dayOfWeekMatches(time);
            expect(result, t[2] as Matcher,
                reason:
                    "expression: ${t[0]}, time: ${t[1]}, got: $result, expected: ${t[2] == isTrue ? true : false}");
          }
        });
        test("we pass a test for 'the bug'", () {
          // https://crontab.guru/cron-bug.html
          // When BOTH day-of-month and day-of-week are restricted, POSIX cron
          // matches a time if EITHER field matches. `* * 13 * SUN` therefore
          // fires on every Sunday as well as on the 13th of every month.
          // 2019-11-24 is a Sunday (and not the 13th), so it matches via the
          // day-of-week field.
          const expression = '* * 13 * SUN';
          const timeString = '2019-11-24 05:00:00';
          final cron = Cron(expression);
          final time = DateTime.parse(timeString);
          final result = cron.matches(time);
          expect(result, true,
              reason:
                  "expression: $expression, time: $timeString, got: $result, expected: true");
        });
      });
    });
    group("DateTime calculations", () {
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
          expect(result, expected,
              reason: "expression: ${t[0]}, got: $result, expected: $expected");
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
          expect(result, expected,
              reason: "expression: ${t[0]}, got: $result, expected: $expected");
        }
      });
    });
    group("Duration calculations", () {
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
          [
            "*/5 * * * *",
            "2019-11-23 12:00:01",
            Duration(minutes: 4, seconds: 59)
          ],
        ];
        for (final t in tests) {
          final cron = Cron(t[0] as String);
          final input = DateTime.parse(t[1] as String);
          final expected = t[2];
          final result = cron.untilNextRelativeTo(input);
          expect(result, expected,
              reason: "expression: ${t[0]}, got: $result, expected: $expected");
        }
      });
      test(
          "sincePreviousRelativeTo returns the duration since the previous match",
          () {
        final tests = [
          // simple tests
          ["* * * * *", "2019-11-23 12:00:00", -Duration(minutes: 1)],
          [
            "* * * * *",
            "2019-11-23 12:00:01",
            -Duration(minutes: 1, seconds: 1)
          ],
          [
            "5 * * * *",
            "2019-11-23 12:00:01",
            -Duration(minutes: 55, seconds: 1)
          ],
          [
            "0 13 * * *",
            "2019-11-23 12:00:01",
            -Duration(hours: 23, seconds: 1)
          ],
          // TODO: range tests
          // TODO: set tests
          // TODO: skip tests
          [
            "*/5 * * * *",
            "2019-11-23 12:00:01",
            -Duration(minutes: 5, seconds: 1)
          ],
        ];
        for (final t in tests) {
          final cron = Cron(t[0] as String);
          final input = DateTime.parse(t[1] as String);
          final expected = t[2];
          final result = cron.sincePreviousRelativeTo(input);
          expect(result, expected,
              reason: "expression: ${t[0]}, got: $result, expected: $expected");
        }
      });
    });
    group("regressions", () {
      // https://github.com/justintout/cronparse/issues/3
      // "0 0 1 * *" / @monthly used to return "tomorrow" instead of the 1st of
      // the following month.
      test("#3: monthly job returns the 1st of next month, not tomorrow", () {
        final current = DateTime.parse('2021-07-11 13:00:01');
        expect(
          Cron('0 0 1 * *').nextRelativeTo(current),
          DateTime.parse('2021-08-01 00:00:00'),
        );
        expect(
          Cron('@monthly').nextRelativeTo(current),
          DateTime.parse('2021-08-01 00:00:00'),
        );
      });

      // https://github.com/justintout/cronparse/issues/5
      // A restricted day-of-month was ignored, so "0 19 7 8 *" returned the 1st
      // of August instead of the 7th.
      group("#5: day-of-month is honored", () {
        final current = DateTime.parse('2021-07-11 13:00:01');

        test('"0 19 7 8 *" next is 2021-08-07 19:00:00', () {
          expect(
            Cron('0 19 7 8 *').nextRelativeTo(current),
            DateTime.parse('2021-08-07 19:00:00'),
          );
        });
        test('"0 19 7 * *" next is 2021-08-07 19:00:00', () {
          expect(
            Cron('0 19 7 * *').nextRelativeTo(current),
            DateTime.parse('2021-08-07 19:00:00'),
          );
        });
        test('"0 19 * 8 *" next is 2021-08-01 19:00:00', () {
          expect(
            Cron('0 19 * 8 *').nextRelativeTo(current),
            DateTime.parse('2021-08-01 19:00:00'),
          );
        });
        test('"0 19 7 8 *" previous is 2020-08-07 19:00:00', () {
          expect(
            Cron('0 19 7 8 *').previousRelativeTo(current),
            DateTime.parse('2020-08-07 19:00:00'),
          );
        });
        test('"0 19 7 * *" previous is 2021-07-07 19:00:00', () {
          expect(
            Cron('0 19 7 * *').previousRelativeTo(current),
            DateTime.parse('2021-07-07 19:00:00'),
          );
        });
        test('"0 19 * 8 *" previous is 2020-08-31 19:00:00', () {
          expect(
            Cron('0 19 * 8 *').previousRelativeTo(current),
            DateTime.parse('2020-08-31 19:00:00'),
          );
        });
      });

      // https://github.com/justintout/cronparse/issues/4
      // POSIX day rule: with both day-of-month and day-of-week restricted, a
      // time matches if EITHER field matches.
      test("#4: restricted DOM and DOW match on either field", () {
        final cron = Cron('0 0 13 * SUN');
        // 2021-11-13 is a Saturday, the 13th -> matches via day-of-month.
        expect(cron.matches(DateTime.parse('2021-11-13 00:00:00')), isTrue);
        // 2021-11-14 is a Sunday, not the 13th -> matches via day-of-week.
        expect(cron.matches(DateTime.parse('2021-11-14 00:00:00')), isTrue);
        // 2021-11-15 is a Monday, not the 13th -> matches neither.
        expect(cron.matches(DateTime.parse('2021-11-15 00:00:00')), isFalse);
      });
    });
  });
}
