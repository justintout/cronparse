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
