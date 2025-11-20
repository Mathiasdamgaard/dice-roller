import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/dice_controller.dart';
import '../inputs/dice_selector.dart';
import '../inputs/count_selector.dart';
import '../inputs/modifier_selector.dart';
import '../inputs/mode_selector.dart';
import '../dialogs/save_preset_dialog.dart';

class RollerControls extends StatelessWidget {
  const RollerControls({super.key});

  void _showSaveDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => const SavePresetDialog());
  }

  @override
  Widget build(BuildContext context) {
    final isRolling = context.select((DiceController c) => c.isRolling);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheetTop),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 20, AppSpacing.xl, 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Group 1: Dice Type ---
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Dice Type",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite70,
                        ),
                      ),
                      SizedBox(height: AppSpacing.m),
                      DiceTypeRow(),
                    ],
                  ),

                  // --- Group 2: Counts ---
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.s),
                    child: Row(
                      children: [
                        Expanded(child: DiceCountSelector()),
                        SizedBox(width: AppSpacing.l),
                        Expanded(child: ModifierSelector()),
                      ],
                    ),
                  ),

                  // --- Group 3: Mode ---
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Mode",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite70,
                          ),
                        ),
                        SizedBox(height: AppSpacing.m),
                        ModeSelector(),
                      ],
                    ),
                  ),

                  // --- Group 4: Buttons ---
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
                              vertical: AppSpacing.l,
                            ),
                            side: const BorderSide(color: Colors.white24),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.l),
                      Expanded(
                        flex: 2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.xxl),
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
                                : () =>
                                      context.read<DiceController>().rollDice(),
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
                                vertical: AppSpacing.l,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xxl,
                                ),
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
          );
        },
      ),
    );
  }
}
