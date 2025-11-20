class Character {
  // Attributes
  int strength;
  int dexterity;
  int constitution;
  int intelligence;
  int wisdom;
  int charisma;

  // Vitals
  int maxHp;
  int currentHp;
  int armorClass;
  int proficiency;

  List<String> proficientSkills;

  Character({
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
    this.maxHp = 20,
    this.currentHp = 20,
    this.armorClass = 10,
    this.proficiency = 2,
    List<String>? proficientSkills,
  }) : proficientSkills = proficientSkills != null
           ? List<String>.from(proficientSkills)
           : [];

  Map<String, dynamic> toJson() => {
    'strength': strength,
    'dexterity': dexterity,
    'constitution': constitution,
    'intelligence': intelligence,
    'wisdom': wisdom,
    'charisma': charisma,
    'maxHp': maxHp,
    'currentHp': currentHp,
    'armorClass': armorClass,
    'proficiency': proficiency,
    'proficientSkills': proficientSkills,
  };

  factory Character.fromJson(Map<String, dynamic> json) => Character(
    strength: json['strength'] ?? 10,
    dexterity: json['dexterity'] ?? 10,
    constitution: json['constitution'] ?? 10,
    intelligence: json['intelligence'] ?? 10,
    wisdom: json['wisdom'] ?? 10,
    charisma: json['charisma'] ?? 10,
    maxHp: json['maxHp'] ?? 20,
    currentHp: json['currentHp'] ?? 20,
    armorClass: json['armorClass'] ?? 10,
    proficiency: json['proficiency'] ?? 2,
    proficientSkills: List<String>.from(json['proficientSkills'] ?? []),
  );
}
