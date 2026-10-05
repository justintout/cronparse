## [0.3.1] - 2026-10-05
* Fix `previousRelativeTo`, `previous`, `sincePreviousRelativeTo` and
  `sincePrevious`, which skipped a match earlier in the same minute.
  `*/15 * * * *` at 16:00:30 now returns 16:00 instead of 15:45.
* Document the whole public API, including what the `Cron` constructor
  accepts and when it throws.

## [0.3.0] - 2026-10-05
* **Breaking:** `isValid` rejects expressions that can never match, and `Cron`
  throws an `ArgumentError` for them. These are reversed ranges (`30-10`), zero
  steps (`*/0`), and a day of month that never occurs in the selected months
  (`0 0 30 2 *`). Previously `nextRelativeTo` and `previousRelativeTo` looped
  forever on them. (#13)
* **Breaking:** a day field that starts with `*`, such as `*/2`, no longer
  counts as restricted for the day-of-month / day-of-week rule, matching Vixie
  cron. The two fields then combine with AND, so `0 0 13 * */2` runs only on a
  13th that falls on an even weekday.
* Parse with Vixie cron's grammar. Any run of spaces or tabs separates fields.
  Lists accept steps (`1-10/2,20-30/5`) and `*` (`*,5`). Month names work in
  lists and ranges (`jan-mar`, `jan,feb`).
* Sunday is both 0 and 7 by name, so `sun-sat` and `fri-sun` are both valid.
* Fix `@midnight`, which ran at 23:00 instead of 00:00. (#14)
* `Cron('@reboot')` now throws its "not supported" message instead of the
  generic invalid-expression message. (#15)
* Parse each field once at construction instead of once per minute searched.

## [0.2.0] - 2026-07-14
* **Breaking:** migrate to sound null safety; the SDK constraint is now `^3.0.0`
  (Dart 2.x is no longer supported).
* Fix the POSIX day-of-month / day-of-week rule: when both fields are restricted
  (neither is `*`), a time now matches if *either* field matches. When only one
  is restricted, only that field applies. (#3, #4, #5)
* Fix day-of-month matching, which iterated over the day-of-week field and could
  ignore a restricted day-of-month, e.g. `0 19 7 8 *` now returns August 7th
  rather than August 1st. (#5)
* Fix range handling (`a-b`) in the hour, day-of-month, month, and day-of-week
  fields, which previously threw on comma-separated ranges. (#5)
* Fix the "the bug" day-of-week test, which used a malformed expression. (#8)
* Run `dart format` across the repository (80-column default). (#7)

Thanks to [@nilsreichardt](https://github.com/nilsreichardt), who filed #5–#8 and
worked out that day-of-month matching was reading the day-of-week field. That
diagnosis is what #5, #3, and #4 were all symptoms of.

## [0.1.1] - 2020-06-12
* Fix pub.dev health suggestions

## [0.1.0] - 2020-06-04 
* Initial pub.dev release

## [0.0.1] - 2020-05-22 
* GitHub repo initialized
