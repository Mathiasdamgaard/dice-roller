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
  
  // Animation State
  double _shakeIntensity = 1.0;

  // Feature State
  bool _instantRoll = false;
  bool _explodingDice = false; // New Toggle
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
  bool get explodingDice => _explodingDice;
  double get shakeIntensity => _shakeIntensity;
  Color get seedColor => _seedColor;
  
  RollResult? get lastResult => _history.isNotEmpty ? _history.first : null;
  List<RollResult> get history => List.unmodifiable(_history);
  List<SavedPreset> get presets => List.unmodifiable(_presets);

  // --- Persistence ---
  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    
    final historyJson = prefs.getStringList('history');
    if (historyJson != null) {
      _history = historyJson.map((e) => RollResult.fromJson(jsonDecode(e))).toList();
    }

    final presetsJson = prefs.getStringList('presets');
    if (presetsJson != null) {
      _presets = presetsJson.map((e) => SavedPreset.fromJson(jsonDecode(e))).toList();
    }

    final colorValue = prefs.getInt('seedColor');
    if (colorValue != null) _seedColor = Color(colorValue);
    
    _instantRoll = prefs.getBool('instantRoll') ?? false;
    _explodingDice = prefs.getBool('explodingDice') ?? false; // Load setting

    _selectedSides = prefs.getInt('selectedSides') ?? 20;
    _diceCount = prefs.getInt('diceCount') ?? 1;
    _modifier = prefs.getInt('modifier') ?? 0;
    final modeIndex = prefs.getInt('mode') ?? 0;
    _mode = RollMode.values[modeIndex];
    
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final historyJson = _history.take(50).map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('history', historyJson);

    final presetsJson = _presets.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('presets', presetsJson);

    await prefs.setInt('seedColor', _seedColor.toARGB32());
    await prefs.setBool('instantRoll', _instantRoll);
    await prefs.setBool('explodingDice', _explodingDice); // Save setting

    await prefs.setInt('selectedSides', _selectedSides);
    await prefs.setInt('diceCount', _diceCount);
    await prefs.setInt('modifier', _modifier);
    await prefs.setInt('mode', _mode.index);
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

  void toggleExplodingDice() {
    _explodingDice = !_explodingDice;
    _saveData();
    notifyListeners();
  }

  void setSides(int sides) {
    _selectedSides = sides;
    _saveData();
    HapticFeedback.selectionClick();
    notifyListeners();
    if (_instantRoll) rollDice();
  }

  void setDiceCount(int count) {
    _diceCount = max(1, count);
    _saveData();
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void setModifier(int value) {
    _modifier = value;
    _saveData();
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void setMode(RollMode newMode) {
    _mode = newMode;
    _saveData();
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void loadPreset(SavedPreset preset) {
    _selectedSides = preset.diceSides;
    _diceCount = preset.diceCount;
    _modifier = preset.modifier;
    _mode = preset.mode;
    
    _saveData(); 
    HapticFeedback.mediumImpact();
    notifyListeners();
    rollDice();
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

  // --- Core Logic ---

  Future<void> rollDice() async {
    if (_isRolling) return;

    final rng = Random();

    // 1. Helper: Perform the actual roll calculation first
    ({int total, List<int> rolls, int explosions}) performRoll() {
      List<int> rolls = [];
      int sum = 0;
      int totalExplosions = 0;

      for (int i = 0; i < _diceCount; i++) {
        int currentRoll = rng.nextInt(_selectedSides) + 1;
        int dieTotal = currentRoll;
        
        // Exploding Logic
        if (_explodingDice) {
          // Prevent infinite loops in case of crazy RNG or 1d1
          int loopGuard = 0;
          while (currentRoll == _selectedSides && loopGuard < 50) {
            totalExplosions++;
            loopGuard++;
            currentRoll = rng.nextInt(_selectedSides) + 1;
            dieTotal += currentRoll;
          }
        }

        rolls.add(dieTotal);
        sum += dieTotal;
      }
      return (total: sum + _modifier, rolls: rolls, explosions: totalExplosions);
    }

    // 2. Calculate Result BEFORE animation
    RollResult pendingResult;
    int totalExplosions = 0;

    if (_mode == RollMode.normal) {
      final result = performRoll();
      totalExplosions = result.explosions;
      pendingResult = RollResult(
        total: result.total,
        individualRolls: result.rolls,
        modifier: _modifier,
        mode: _mode,
        dieSides: _selectedSides,
        timestamp: DateTime.now(),
        explosionCount: totalExplosions,
      );
    } else {
      final setA = performRoll();
      final setB = performRoll();
      
      bool keepA = _mode == RollMode.advantage 
          ? setA.total >= setB.total 
          : setA.total <= setB.total;

      final keptSet = keepA ? setA : setB;
      totalExplosions = keptSet.explosions;

      pendingResult = RollResult(
        total: keptSet.total,
        individualRolls: keptSet.rolls,
        discardedRolls: keepA ? setB.rolls : setA.rolls,
        modifier: _modifier,
        mode: _mode,
        dieSides: _selectedSides,
        timestamp: DateTime.now(),
        explosionCount: totalExplosions,
      );
    }

    // 3. Set Intensity based on Explosions
    // Base = 1.0. Each explosion adds 0.5 intensity. Cap at 3.0 (Wild!)
    _shakeIntensity = 1.0 + (totalExplosions * 0.5);
    if (_shakeIntensity > 4.0) _shakeIntensity = 4.0;

    // 4. Start Animation
    _isRolling = true;
    HapticFeedback.vibrate(); 
    notifyListeners();

    // Wait for animation (wilder rolls feel better with slight delays)
    await Future.delayed(Duration(milliseconds: _instantRoll ? 300 : 600));

    // 5. Commit Result
    _history.insert(0, pendingResult);
    if (_history.length > 50) _history.removeLast();
    _saveData();
    
    _isRolling = false;
    
    // 6. Haptics (More explosions = More haptics)
    await HapticFeedback.heavyImpact();
    if (!_instantRoll || totalExplosions > 0) {
       await Future.delayed(const Duration(milliseconds: 50));
       await HapticFeedback.heavyImpact();
       
       // If it was a massive explosion, give a third thud
       if (totalExplosions > 1) {
         await Future.delayed(const Duration(milliseconds: 50));
         await HapticFeedback.heavyImpact();
       }
    }
    
    notifyListeners();
  }
}