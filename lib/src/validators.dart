import './cronparse.dart';
import './fields.dart';

/// Whether [expr] is a cron expression that [Cron] accepts.
///
/// [expr] is valid if it follows the Vixie cron grammar and matches at least
/// one real date. `0 0 30 2 *` is well formed, but February never has a 30th,
/// so it is not valid. The nickname `@reboot` is not valid either.
// TODO: support Jenkins "H"?
// TODO: support "L", "?", "W", "#"
bool isValid(String expr) => parseFields(expr) != null;
