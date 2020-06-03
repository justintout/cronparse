import 'package:cronparse/cronparse.dart';

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