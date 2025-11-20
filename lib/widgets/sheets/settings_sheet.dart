import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dice_controller.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DiceController>();
    final colors = [
      const Color(0xFF6750A4), // Deep Purple
      const Color(0xFFB91C1C), // Red
      const Color(0xFF15803D), // Green
      const Color(0xFFCA8A04), // Gold
      const Color(0xFF0EA5E9), // Sky Blue
      const Color(0xFFEC4899), // Pink
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("App Theme", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: colors.map((color) {
              final isSelected =
                  controller.seedColor.toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () => controller.setThemeColor(color),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),

          Text("Gameplay", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              "Instant Roll",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              "Roll immediately when selecting a die type",
              style: TextStyle(color: Colors.white54),
            ),
            value: controller.instantRoll,
            activeThumbColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) => controller.toggleInstantRoll(),
          ),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              "Exploding Dice",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              "Re-roll max values and add to total",
              style: TextStyle(color: Colors.white54),
            ),
            secondary: const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
            ),
            value: controller.explodingDice,
            activeThumbColor: Colors.orange,
            onChanged: (val) => controller.toggleExplodingDice(),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
