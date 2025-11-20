import 'package:dice_roller/models/saved_preset.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dice_controller.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.select((DiceController c) => c.mode);

    return Container(
      height: 48,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSegment(context, mode, RollMode.normal, "Normal"),
          _buildSegment(context, mode, RollMode.advantage, "Adv"),
          _buildSegment(context, mode, RollMode.disadvantage, "Disadv"),
        ],
      ),
    );
  }

  Widget _buildSegment(
    BuildContext context,
    RollMode current,
    RollMode target,
    String label,
  ) {
    final isSelected = current == target;
    Color activeColor;
    if (target == RollMode.advantage)
      activeColor = const Color(0xFF059669);
    else if (target == RollMode.disadvantage)
      activeColor = const Color(0xFFE11D48);
    else
      activeColor = const Color(0xFF4F46E5);

    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<DiceController>().setMode(target),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
