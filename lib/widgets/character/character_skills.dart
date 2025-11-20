import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/character_controller.dart';
import '../../providers/dice_controller.dart';
import '../../models/roll_result.dart';

class CharacterSkills extends StatelessWidget {
  final VoidCallback? onRollRequest;

  const CharacterSkills({super.key, this.onRollRequest});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CharacterController>();
    final char = controller.character;
    final isEditing = controller.isEditing;

    // 1. Group skills by attribute dynamically
    final skillsByAttr = <String, List<String>>{};
    CharacterController.skillMap.forEach((skill, attr) {
      if (!skillsByAttr.containsKey(attr)) skillsByAttr[attr] = [];
      skillsByAttr[attr]!.add(skill);
    });

    // 2. Define display order
    final orderedAttrs = ['STR', 'DEX', 'INT', 'WIS', 'CHA'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...orderedAttrs.map((attr) {
          final skills = skillsByAttr[attr];
          if (skills == null || skills.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xs,
                  bottom: AppSpacing.m,
                ),
                child: Text(
                  "$attr SKILLS",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: skills.map((skillName) {
                  final bonus = controller.getSkillBonus(skillName);
                  final isProficient = char.proficientSkills.contains(
                    skillName,
                  );

                  return _buildSkillChip(
                    context,
                    skillName,
                    bonus,
                    isProficient,
                    isEditing,
                    () {
                      if (isEditing) {
                        context
                            .read<CharacterController>()
                            .toggleSkillProficiency(skillName);
                      } else {
                        // Roll Logic
                        final diceController = context.read<DiceController>();
                        diceController.setDiceCount(1);
                        diceController.setSides(20);
                        diceController.setModifier(bonus);
                        diceController.setMode(RollMode.normal);

                        onRollRequest?.call(); // Switch Tabs
                        diceController.rollDice(); // Roll
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSkillChip(
    BuildContext context,
    String name,
    int bonus,
    bool isProficient,
    bool isEditing,
    VoidCallback onTap,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final bonusStr = bonus >= 0 ? "+$bonus" : "$bonus";

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          // Subtle background tint if proficient
          color: isProficient
              ? primaryColor.withValues(alpha: 0.15)
              : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(AppRadius.l),
          // Border highlight if proficient
          border: Border.all(
            color: isProficient ? primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Proficiency Dot (Only show if proficient or in edit mode)
            if (isProficient || isEditing) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isProficient ? primaryColor : Colors.white12,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
            ],
            Text(
              name,
              style: TextStyle(
                color: isProficient ? Colors.white : AppColors.textWhite70,
                fontWeight: isProficient ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            // Bonus Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.shadow,
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
              child: Text(
                bonusStr,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isProficient
                      ? primaryColor.withValues(alpha: 0.9)
                      : AppColors.textWhite54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
