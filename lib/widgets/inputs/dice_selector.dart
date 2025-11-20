import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dice_controller.dart';

class DiceTypeRow extends StatelessWidget {
  const DiceTypeRow({super.key});

  final List<int> diceOptions = const [4, 6, 8, 10, 12, 20, 100];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DiceController>();
    final selected = state.selectedSides;
    final themeColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: diceOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sides = diceOptions[index];
          final isSelected = sides == selected;

          return GestureDetector(
            onTap: () => context.read<DiceController>().setSides(sides),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? themeColor : const Color(0xFF334155),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: themeColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
                border: isSelected
                    ? Border.all(color: Colors.white, width: 1)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                "d$sides",
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
