import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';

class CharacterController extends ChangeNotifier {
  Character _character = Character();
  bool _isEditing = false;

  Character get character => _character;
  bool get isEditing => _isEditing;

  // Master Skill List Data
  static const Map<String, String> skillMap = {
    'Athletics': 'STR',
    'Acrobatics': 'DEX',
    'Sleight of Hand': 'DEX',
    'Stealth': 'DEX',
    'Arcana': 'INT',
    'History': 'INT',
    'Investigation': 'INT',
    'Nature': 'INT',
    'Religion': 'INT',
    'Animal Handling': 'WIS',
    'Insight': 'WIS',
    'Medicine': 'WIS',
    'Perception': 'WIS',
    'Survival': 'WIS',
    'Deception': 'CHA',
    'Intimidation': 'CHA',
    'Performance': 'CHA',
    'Persuasion': 'CHA',
  };

  Future<void> loadCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    final charJson = prefs.getString('character_data');
    if (charJson != null) {
      _character = Character.fromJson(jsonDecode(charJson));
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('character_data', jsonEncode(_character.toJson()));
    notifyListeners();
  }

  void toggleEditMode() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  // --- Stat Updates ---

  void updateAttribute(String key, int value) {
    switch (key) {
      case 'STR':
        _character.strength = value;
        break;
      case 'DEX':
        _character.dexterity = value;
        break;
      case 'CON':
        _character.constitution = value;
        break;
      case 'INT':
        _character.intelligence = value;
        break;
      case 'WIS':
        _character.wisdom = value;
        break;
      case 'CHA':
        _character.charisma = value;
        break;
    }
    _save();
  }

  void updateVitals({int? hp, int? maxHp, int? ac, int? prof}) {
    if (hp != null) _character.currentHp = hp;
    if (maxHp != null) _character.maxHp = maxHp;
    if (ac != null) _character.armorClass = ac;
    if (prof != null) _character.proficiency = prof;
    _save();
  }

  // --- Skills Logic ---

  void toggleSkillProficiency(String skillName) {
    if (_character.proficientSkills.contains(skillName)) {
      _character.proficientSkills.remove(skillName);
    } else {
      _character.proficientSkills.add(skillName);
    }
    _save();
  }

  int getAttributeScore(String attr) {
    switch (attr) {
      case 'STR':
        return _character.strength;
      case 'DEX':
        return _character.dexterity;
      case 'CON':
        return _character.constitution;
      case 'INT':
        return _character.intelligence;
      case 'WIS':
        return _character.wisdom;
      case 'CHA':
        return _character.charisma;
      default:
        return 10;
    }
  }

  int getAttributeModifier(String attr) {
    final score = getAttributeScore(attr);
    return ((score - 10) / 2).floor();
  }

  int getSkillBonus(String skillName) {
    final attr = skillMap[skillName] ?? 'STR';
    final attrMod = getAttributeModifier(attr);
    final isProficient = _character.proficientSkills.contains(skillName);
    return attrMod + (isProficient ? _character.proficiency : 0);
  }
}
