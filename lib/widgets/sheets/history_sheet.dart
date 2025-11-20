import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/dice_controller.dart';

class HistorySheet extends StatelessWidget {
  const HistorySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<DiceController>().history;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Rolls",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () {
                    context.read<DiceController>().clearHistory();
                    Navigator.pop(context);
                    HapticFeedback.mediumImpact();
                  },
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: const Text("Clear"),
                ),
              ],
            ),
          ),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                "No recent rolls.",
                style: TextStyle(color: Colors.white38),
              ),
            ),
          if (history.isNotEmpty)
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: history.length,
                separatorBuilder: (ctx, i) =>
                    const Divider(height: 1, color: Colors.white10),
                itemBuilder: (ctx, index) {
                  final roll = history[index];
                  final isCrit = roll.individualRolls.contains(roll.dieSides);
                  final isFail = roll.individualRolls.contains(1);
                  Color scoreColor = Colors.white;
                  if (isCrit) scoreColor = Colors.amber;
                  if (isFail) scoreColor = Colors.redAccent;

                  return ListTile(
                    dense: true,
                    leading: Text(
                      "${roll.total}",
                      style: TextStyle(
                        color: scoreColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    title: Text(
                      "${roll.individualRolls.length}d${roll.dieSides} ${roll.modifier >= 0 ? '+' : ''}${roll.modifier}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    subtitle: Text(
                      "${roll.mode.name.toUpperCase()} • [${roll.individualRolls.join(', ')}]",
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
