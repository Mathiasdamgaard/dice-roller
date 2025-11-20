import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/dice_controller.dart';

class PresetsSheet extends StatelessWidget {
  const PresetsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final presets = context.watch<DiceController>().presets;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Saved Rolls",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (presets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                "No saved presets yet.",
                style: TextStyle(color: Colors.white38),
              ),
            ),
          if (presets.isNotEmpty)
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: presets.length,
                itemBuilder: (ctx, index) {
                  final preset = presets[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF334155),
                      child: Text(
                        "d${preset.diceSides}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      preset.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      "${preset.diceCount}d${preset.diceSides} ${preset.modifier >= 0 ? '+' : ''}${preset.modifier} (${preset.mode.name})",
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        context.read<DiceController>().deletePreset(preset.id);
                        HapticFeedback.mediumImpact();
                      },
                    ),
                    onTap: () {
                      context.read<DiceController>().loadPreset(preset);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
