# cronparse
> Parse and calculate different times related to Unix cron expressions

**Note: Not yet implemented. First implemented release will be `0.1.0`.**


Parse Unix cron expressions and calculate things like:

- whether the expression is valid
- the next time the expression will run
- the last time the expression would have run
- the duration until the next time the expression will run
- the duration since the last time the expression would have run

## Usage 

```dart
import 'package:cronparse/cronparse.dart';

void main() {
    // validate a cron expression
    print("validCronExpression(54 2-3,4-9 */3 FEB MON-FRI)"); // true

    // calculate times based on a cron expression
    final time = DateTime().parse("2019-11-23 18:22:00");

    final simpleParser = CronParser("0 22 * * *");
    print(simpleParser.nextRelativeTo(time)); // "2020-11-23 22:00:00"

    final skipParser = CronParser("*/15 * * * *");
    print(skipParser.untilNextRelativeTo(time)); // "0:08:00.000000"
}
```

## Cron expression matching strategy 

### High-level explanation on matching 

- if the expression is a predefined nickname, translate it to the relevant actual expression. note: this library does not parse the `@reboot` nickname.
- tokenize the expression to each part (minute, hour, day of month, month, day of week)
- test each of these tokens to match
    - token values can be in a few forms: 
        - an asterisk (`*`): this always matches
        - an asterisk with skips (`*/15`): iterate through the valid range for the field, incrementing by the skip. if any of these match, the expression matches. 
        - exact value (`48`, `feb`, `WED`): match these exactly 
        - range of values without skips (`5-9`): iterate through the range, starting at the lower bound and ending at the higher bound, incrementing by 1. if any of these match, the value matches 
        - range of values with skip (`20-30/2`): iterate through the range, starting at the lower bound and ending at the higher bound, incrementing by the skip value. if any of these match, the value matches.
        - set of values or ranges (`1,2,3`, `5-10,45-50`): test each value in the set using the above strategy. if any of the member values match, the value matches. 
- iff all tokens match, the expression matches 

### `@reboot`

This library is focused on temporal calculation for cron expressions. The `@reboot` nickname is shorthand for "exactly once after reboot." Since the `@reboot` nickname is not a temporal representation, it is not handled by this library. 

## Links 
- [`cron` man page](https://linux.die.net/man/5/crontab)
- [A cron-like job scheduler for Dart](https://pub.dev/packages/cron)
- [A Node.js library with similar functionality](https://github.com/harrisiirak/cron-parser)
