enum RollMode { normal, advantage, disadvantage }

class SavedPreset {
  final String id;
  final String name;
  final int diceCount;
  final int diceSides;
  final int modifier;
  final RollMode mode;

  SavedPreset({
    required this.id,
    required this.name,
    required this.diceCount,
    required this.diceSides,
    required this.modifier,
    required this.mode,
  });
}
