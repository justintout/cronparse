# cronparse

[![pub package](https://img.shields.io/pub/v/cronparse.svg)](https://pub.dev/packages/cronparse)
[![docs](https://img.shields.io/badge/docs-pub.dev-blue)](https://pub.dev/documentation/cronparse/latest/)

> Parse and calculate different times related to Unix cron expressions

Parse Unix cron expressions and calculate things like:

- whether the expression is valid, as a `bool`. an expression that can never match, such as `0 0 30 2 *` or the reversed range `30-10 * * * *`, is invalid
- the next time the expression will run, as a `DateTime`
- the last time the expression would have run, as a `DateTime`
- the duration until the next time the expression will run, as a `Duration`
- the duration since the last time the expression would have run, as a negative `Duration`

## Usage 

```dart
void main() {
    // validate a cron expression
    final valid = isValid("54 2-3,4-9 */3 FEB MON-FRI");
    print(valid); // true

    // calculate times based on a cron expression
    final time = DateTime.parse("2019-11-23 16:00:00");

    var cron = Cron("0 22 * * *");
    print(cron.nextRelativeTo(time)); // "2019-11-23 22:00:00.000"
    print(cron.untilNextRelativeTo(time) == Duration(hours: 6)); // true

    cron = Cron("*/15 * * * *");
    print(cron.previousRelativeTo(time)); // "2019-11-23 15:45:00.000"
    print(cron.sincePreviousRelativeTo(time) == Duration(minutes: -15)); // true
}
```

## Cron expression matching strategy 

### High-level explanation on matching 

- if the expression is a predefined nickname, translate it to the relevant actual expression. note: this library does not parse the `@reboot` nickname.
- tokenize the expression to each part (minute, hour, day of month, month, day of week). parts are separated by any run of spaces or tabs
- test each of these tokens to match
    - token values can be in a few forms: 
        - an asterisk (`*`): this always matches
        - an asterisk with skips (`*/15`): iterate through the valid range for the field, incrementing by the skip. if any of these match, the expression matches. 
        - exact value (`48`, `feb`, `WED`): match these exactly. month and day names are case-insensitive and work anywhere a number does, including ranges (`jan-mar`, `MON-FRI`). Sunday is both `0` and `7`, so `sun` starts a range as 0 (`sun-sat`) and ends one as 7 (`fri-sun`) 
        - range of values without skips (`5-9`): iterate through the range, starting at the lower bound and ending at the higher bound, incrementing by 1. if any of these match, the value matches 
        - range of values with skip (`20-30/2`): iterate through the range, starting at the lower bound and ending at the higher bound, incrementing by the skip value. if any of these match, the value matches.
        - set of values or ranges (`1,2,3`, `5-10,45-50`, `1-10/2,20-30/5`): test each value in the set using the above strategy. if any of the member values match, the value matches. 
- the expression matches when all five tokens match, with one exception. when both day of month and day of week are restricted (neither starts with `*`), the expression matches if either of the two matches. this is the rule cron itself uses, so `0 0 13 * 5` runs on the 13th of the month and on every Friday. as in cron, a field like `*/2` starts with `*` and so does not count as restricted: `0 0 13 * */2` runs only on a 13th that falls on an even weekday

### `@reboot`

This library is focused on temporal calculation for cron expressions. The `@reboot` nickname is shorthand for "exactly once after reboot." Since the `@reboot` nickname is not a temporal representation, it is not handled by this library. 

## Links 
- [`cron` man page](https://linux.die.net/man/5/crontab)
- [A cron-like job scheduler for Dart](https://pub.dev/packages/cron)
- [A Node.js library with similar functionality](https://github.com/harrisiirak/cron-parser)
