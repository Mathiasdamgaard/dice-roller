enum RollMode { normal, advantage, disadvantage }

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

  Map<String, dynamic> toJson() => {
    'total': total,
    'individualRolls': individualRolls,
    'modifier': modifier,
    'mode': mode.index,
    'discardedRolls': discardedRolls,
    'dieSides': dieSides,
    'timestamp': timestamp.toIso8601String(),
  };

  factory RollResult.fromJson(Map<String, dynamic> json) => RollResult(
    total: json['total'],
    individualRolls: List<int>.from(json['individualRolls']),
    modifier: json['modifier'],
    mode: RollMode.values[json['mode']],
    discardedRolls: json['discardedRolls'] != null ? List<int>.from(json['discardedRolls']) : null,
    dieSides: json['dieSides'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}