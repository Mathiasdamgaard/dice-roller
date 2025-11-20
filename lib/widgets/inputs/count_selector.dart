import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dice_controller.dart';

class DiceCountSelector extends StatelessWidget {
  const DiceCountSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select((DiceController c) => c.diceCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Count",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF334155),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () =>
                    context.read<DiceController>().setDiceCount(count - 1),
                icon: const Icon(Icons.remove, size: 16),
              ),
              Text(
                "$count",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () =>
                    context.read<DiceController>().setDiceCount(count + 1),
                icon: const Icon(Icons.add, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
