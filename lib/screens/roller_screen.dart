import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../widgets/display/result_display.dart';
import '../widgets/sheets/presets_sheet.dart';
import '../widgets/sheets/history_sheet.dart';
import '../widgets/sheets/settings_sheet.dart';
import '../widgets/roller/roller_controls.dart';

class DiceRollerScreen extends StatelessWidget {
  const DiceRollerScreen({super.key});

  void _showPresetsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheetBackground,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => const PresetsSheet(),
    );
  }

  void _showHistorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheetBackground,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => const HistorySheet(),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheetBackground,
      showDragHandle: true,
      builder: (ctx) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We still need to listen to isRolling to potentially disable actions in AppBar if needed,
    // but currently the AppBar actions don't depend on isRolling.
    // However, the original code accessed isRolling here.
    // Let's check if we need it. The original code used it for the buttons which are now in RollerControls.
    // So we might not need it here anymore unless we want to disable AppBar buttons during roll.
    // The original code didn't disable AppBar buttons.

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "VoidRoll",
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
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: const ResultDisplay(),
              ),
            ),
            const Expanded(flex: 4, child: RollerControls()),
          ],
        ),
      ),
    );
  }
}
