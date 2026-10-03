import './fields.dart';

/// `isValid` returns true if the given string is a valid cron expression
/// that can match at least one real date.
// TODO: support Jenkins "H"?
// TODO: support "L", "?", "W", "#"
bool isValid(String expr) => parseFields(expr) != null;
