import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/roll_result.dart';
import '../models/saved_preset.dart';

class DiceController extends ChangeNotifier {
  int _selectedSides = 20;
  int _diceCount = 1;
  int _modifier = 0;
  RollMode _mode = RollMode.normal;
  bool _isRolling = false;

  final List<RollResult> _history = [];
  final List<SavedPreset> _presets = [];

  int get selectedSides => _selectedSides;
  int get diceCount => _diceCount;
  int get modifier => _modifier;
  RollMode get mode => _mode;
  bool get isRolling => _isRolling;

  RollResult? get lastResult => _history.isNotEmpty ? _history.first : null;
  List<RollResult> get history => List.unmodifiable(_history);
  List<SavedPreset> get presets => List.unmodifiable(_presets);

  void setSides(int sides) {
    _selectedSides = sides;
    HapticFeedback.selectionClick();
    notifyListeners();
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
    notifyListeners();
  }

  void deletePreset(String id) {
    _presets.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  Future<void> rollDice() async {
    if (_isRolling) return;

    _isRolling = true;
    HapticFeedback.vibrate();
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

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

      bool keepA;
      if (_mode == RollMode.advantage) {
        keepA = setA.total >= setB.total;
      } else {
        keepA = setA.total <= setB.total;
      }

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

    _isRolling = false;

    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();

    notifyListeners();
  }
}
