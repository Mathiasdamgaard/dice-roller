import 'saved_preset.dart';

class RollResult {
  final int total;
  final List<int> individualRolls;
  final int modifier;
  final RollMode mode;
  final List<int>? discardedRolls;
  final int dieSides;
  final DateTime timestamp;

  RollResult({
    required this.total,
    required this.individualRolls,
    required this.modifier,
    required this.mode,
    required this.dieSides,
    required this.timestamp,
    this.discardedRolls,
  });
}
