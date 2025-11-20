import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/roll_result.dart';
import '../models/saved_preset.dart';

class DiceController extends ChangeNotifier {
  // --- State ---
  int _selectedSides = 20;
  int _diceCount = 1;
  int _modifier = 0;
  RollMode _mode = RollMode.normal;
  bool _isRolling = false;

  // New Feature State
  bool _instantRoll = false;
  Color _seedColor = const Color(0xFF6750A4);

  List<RollResult> _history = [];
  List<SavedPreset> _presets = [];

  // --- Getters ---
  int get selectedSides => _selectedSides;
  int get diceCount => _diceCount;
  int get modifier => _modifier;
  RollMode get mode => _mode;
  bool get isRolling => _isRolling;
  bool get instantRoll => _instantRoll;
  Color get seedColor => _seedColor;

  RollResult? get lastResult => _history.isNotEmpty ? _history.first : null;
  List<RollResult> get history => List.unmodifiable(_history);
  List<SavedPreset> get presets => List.unmodifiable(_presets);

  // --- Persistence ---
  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // History
    final historyJson = prefs.getStringList('history');
    if (historyJson != null) {
      _history = historyJson
          .map((e) => RollResult.fromJson(jsonDecode(e)))
          .toList();
    }

    // Presets
    final presetsJson = prefs.getStringList('presets');
    if (presetsJson != null) {
      _presets = presetsJson
          .map((e) => SavedPreset.fromJson(jsonDecode(e)))
          .toList();
    }

    // Settings
    final colorValue = prefs.getInt('seedColor');
    if (colorValue != null) _seedColor = Color(colorValue);

    _instantRoll = prefs.getBool('instantRoll') ?? false;

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    final historyJson = _history
        .take(50)
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    await prefs.setStringList('history', historyJson);

    final presetsJson = _presets.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('presets', presetsJson);

    // FIXED: Use toARGB32() instead of deprecated .value
    await prefs.setInt('seedColor', _seedColor.toARGB32());
    await prefs.setBool('instantRoll', _instantRoll);
  }

  // --- Actions ---

  void setThemeColor(Color color) {
    _seedColor = color;
    _saveData();
    notifyListeners();
  }

  void toggleInstantRoll() {
    _instantRoll = !_instantRoll;
    _saveData();
    notifyListeners();
  }

  void setSides(int sides) {
    _selectedSides = sides;
    HapticFeedback.selectionClick();
    notifyListeners();
    if (_instantRoll) rollDice(); // Trigger instant roll
  }

  void setDiceCount(int count) {
    _diceCount = max(1, count);
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void setModifier(int value) {
    _modifier = value;
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void setMode(RollMode newMode) {
    _mode = newMode;
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void loadPreset(SavedPreset preset) {
    _selectedSides = preset.diceSides;
    _diceCount = preset.diceCount;
    _modifier = preset.modifier;
    _mode = preset.mode;
    HapticFeedback.mediumImpact();
    notifyListeners();
    if (_instantRoll) rollDice();
  }

  void saveCurrentPreset(String name) {
    final newPreset = SavedPreset(
      id: DateTime.now().toIso8601String(),
      name: name,
      diceCount: _diceCount,
      diceSides: _selectedSides,
      modifier: _modifier,
      mode: _mode,
    );
    _presets.add(newPreset);
    _saveData();
    notifyListeners();
  }

  void deletePreset(String id) {
    _presets.removeWhere((p) => p.id == id);
    _saveData();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _saveData();
    notifyListeners();
  }

  Future<void> rollDice() async {
    if (_isRolling) return;

    _isRolling = true;
    HapticFeedback.vibrate();
    notifyListeners();

    // Faster animation for instant rolls
    await Future.delayed(Duration(milliseconds: _instantRoll ? 300 : 600));

    final rng = Random();

    ({int total, List<int> rolls}) performRoll() {
      List<int> rolls = [];
      int sum = 0;
      for (int i = 0; i < _diceCount; i++) {
        int roll = rng.nextInt(_selectedSides) + 1;
        rolls.add(roll);
        sum += roll;
      }
      return (total: sum + _modifier, rolls: rolls);
    }

    RollResult newResult;

    if (_mode == RollMode.normal) {
      final result = performRoll();
      newResult = RollResult(
        total: result.total,
        individualRolls: result.rolls,
        modifier: _modifier,
        mode: _mode,
        dieSides: _selectedSides,
        timestamp: DateTime.now(),
      );
    } else {
      final setA = performRoll();
      final setB = performRoll();

      bool keepA = _mode == RollMode.advantage
          ? setA.total >= setB.total
          : setA.total <= setB.total;

      newResult = RollResult(
        total: keepA ? setA.total : setB.total,
        individualRolls: keepA ? setA.rolls : setB.rolls,
        discardedRolls: keepA ? setB.rolls : setA.rolls,
        modifier: _modifier,
        mode: _mode,
        dieSides: _selectedSides,
        timestamp: DateTime.now(),
      );
    }

    _history.insert(0, newResult);
    if (_history.length > 50) _history.removeLast();
    _saveData();

    _isRolling = false;
    await HapticFeedback.heavyImpact();

    // Only double thud for manual rolls
    if (!_instantRoll) {
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.heavyImpact();
    }

    notifyListeners();
  }
}
