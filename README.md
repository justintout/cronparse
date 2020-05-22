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
    print("validCronExpression(54 2-3,4-9 */3 FEB MON-FRI)"); // true

    final time = DateTime().parse("2012-02-27 13:27:00");

    final simpleParser = CronParser("0 22 * * *");
    print(simpleParser.nextRelativeTo(time)); // "2012-02-27 22:00:00"

    final skipParser = CronParser("*/15 * * * *");
    print(skipParser.nextRelativeTo(time)); // "2012-02-27 13:30:00"
}
```

## 

## Links 
- [man page](https://linux.die.net/man/5/crontab)
- [A Dart cron-like task scheduler](https://pub.dev/packages/cron)

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
