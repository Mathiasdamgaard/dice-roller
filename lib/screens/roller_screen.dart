import 'package:dice_roller/widgets/inputs/dice_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dice_controller.dart';
import '../widgets/display/result_display.dart';
import '../widgets/inputs/count_selector.dart';
import '../widgets/inputs/modifier_selector.dart';
import '../widgets/inputs/mode_selector.dart';
import '../widgets/sheets/presets_sheet.dart';
import '../widgets/sheets/history_sheet.dart';
import '../widgets/sheets/settings_sheet.dart';

class DiceRollerScreen extends StatelessWidget {
  const DiceRollerScreen({super.key});

  void _showSaveDialog(BuildContext context) {
    final controller = context.read<DiceController>();
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Save Preset"),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: "Preset Name",
            hintText: "e.g., Fireball",
            filled: true,
            fillColor: Color(0xFF0F172A),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                controller.saveCurrentPreset(textController.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Preset Saved!")));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showPresetsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => const PresetsSheet(),
    );
  }

  void _showHistorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => const HistorySheet(),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      showDragHandle: true,
      builder: (ctx) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRolling = context.select((DiceController c) => c.isRolling);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "FateForged",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.history),
          tooltip: "History",
          onPressed: () => _showHistorySheet(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: () => _showSettingsSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.book),
            tooltip: "Saved Presets",
            onPressed: () => _showPresetsSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // CHANGED: Reduced flex from 4 to 3 to shrink the result area
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: const ResultDisplay(),
              ),
            ),
            // CHANGED: Kept flex 5, effectively giving controls ~62% of screen (vs 55% before)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                // CHANGED: Reduced top padding from 32 to 20
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Dice Type",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),

                      const DiceTypeRow(),

                      // CHANGED: Reduced gap from 24 to 16
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(child: DiceCountSelector()),
                          SizedBox(width: 16),
                          Expanded(child: ModifierSelector()),
                        ],
                      ),

                      // CHANGED: Reduced gap from 24 to 16
                      const SizedBox(height: 16),
                      const Text(
                        "Mode",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const ModeSelector(),

                      // CHANGED: Reduced gap from 32 to 24
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isRolling
                                  ? null
                                  : () => _showSaveDialog(context),
                              icon: const Icon(Icons.save_alt),
                              label: const Text("Save"),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: const BorderSide(color: Colors.white24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: isRolling
                                    ? const LinearGradient(
                                        colors: [Colors.grey, Colors.grey],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          colorScheme.primary,
                                          colorScheme.tertiary,
                                        ],
                                      ),
                                boxShadow: isRolling
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: colorScheme.primary.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: isRolling
                                    ? null
                                    : () => context
                                          .read<DiceController>()
                                          .rollDice(),
                                icon: isRolling
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.casino),
                                label: Text(
                                  isRolling ? "ROLLING..." : "ROLL DICE",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: colorScheme.onPrimary,
                                  disabledForegroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
