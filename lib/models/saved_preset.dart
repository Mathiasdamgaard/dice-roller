import 'roll_result.dart'; // Assuming RollMode is here, or import where you defined it

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'diceCount': diceCount,
    'diceSides': diceSides,
    'modifier': modifier,
    'mode': mode.index,
  };

  factory SavedPreset.fromJson(Map<String, dynamic> json) => SavedPreset(
    id: json['id'],
    name: json['name'],
    diceCount: json['diceCount'],
    diceSides: json['diceSides'],
    modifier: json['modifier'],
    mode: RollMode.values[json['mode']],
  );
}