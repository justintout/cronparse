// check interfaces in that cron package and conform to them 
// if we feel nice 

import './validators.dart';

/// [CronParser] is an object exposing various methods to 
/// calculate [DateTime]s and [Duration]s from a given cron expression. 
class CronParser {
  CronParser(this.expr) {
    if (!validCronExpression(expr)) {
      throw ArgumentError('invalid cron expression: "$expr"');
    }
  }

  final String expr;

  /// `next` calculates the next [DateTime] 
  /// the expression is scheduled for, relative to 
  /// the current time
  DateTime next() {
    return nextRelativeTo(DateTime.now());
  }

  /// `nextRelativeTo` calculates the next [DateTime] 
  /// the expression is scheduled for, relative to 
  /// the given time
  DateTime nextRelativeTo(DateTime time) {
    throw UnimplementedError();
  }

  /// `previous` calculates the last [DateTime]
  /// the expression would have been scheduled for, 
  /// relative to the current time
  DateTime previous() {
    return previousRelativeTo(DateTime.now());
  }

  /// `previousRelativeTo` calculates the last [DateTime]
  /// the expression would have been scheduled for, 
  /// relative to the given time
  DateTime previousRelativeTo(DateTime time) {
    throw UnimplementedError();
  }

  /// `untilNext` returns the [Duration] until
  /// the expression's next scheduled time, relative
  /// to the current time
  Duration untilNext() {
    return untilNextRelativeTo(DateTime.now());
  }

  /// `untilNextRelativeTo` returns the [Duration] until
  /// the expression's next scheduled time, relative
  /// to the given time
  Duration untilNextRelativeTo(DateTime time) {
    throw UnimplementedError();
  }

  /// `sincePrevious` calculates the [Duration]
  /// since the previous time the expression
  /// would have been scheduled for, relative to
  /// the current time
  Duration sincePrevious() {
    return sincePreviousRelativeTo(DateTime.now());
  }

  /// `sincePreviousRelativeTo` calculates the [Duration]
  /// since the previous time the expression
  /// would have been scheduled for, relative to
  /// the given time
  Duration sincePreviousRelativeTo(DateTime time) {
    throw UnimplementedError();
  }
}