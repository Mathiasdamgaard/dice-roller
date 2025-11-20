import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_controller.dart';
import '../providers/dice_controller.dart';
import '../models/roll_result.dart'; // For RollMode

class CharacterScreen extends StatelessWidget {
  final VoidCallback? onRollRequest;

  const CharacterScreen({super.key, this.onRollRequest});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Character Sheet"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () => controller.toggleEditMode(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Vitals Row (HP, AC) ---
            Row(
              children: [
                _buildVitalCard(
                  context,
                  "HP",
                  "${char.currentHp}/${char.maxHp}",
                  Icons.favorite,
                  onTap: isEditing
                      ? () => _editVital(
                          context,
                          "Current HP",
                          char.currentHp,
                          (v) => controller.updateVitals(hp: v),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                _buildVitalCard(
                  context,
                  "AC",
                  "${char.armorClass}",
                  Icons.shield,
                  onTap: isEditing
                      ? () => _editVital(
                          context,
                          "Armor Class",
                          char.armorClass,
                          (v) => controller.updateVitals(ac: v),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                _buildVitalCard(
                  context,
                  "PROF",
                  "+${char.proficiency}",
                  Icons.school,
                  onTap: isEditing
                      ? () => _editVital(
                          context,
                          "Proficiency",
                          char.proficiency,
                          (v) => controller.updateVitals(prof: v),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Attributes Grid ---
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildAttrCard(context, "STR", char.strength, controller),
                _buildAttrCard(context, "DEX", char.dexterity, controller),
                _buildAttrCard(context, "CON", char.constitution, controller),
                _buildAttrCard(context, "INT", char.intelligence, controller),
                _buildAttrCard(context, "WIS", char.wisdom, controller),
                _buildAttrCard(context, "CHA", char.charisma, controller),
              ],
            ),

            const SizedBox(height: 32),

            // --- Skills Sections (Grouped by Attribute) ---
            ...orderedAttrs.map((attr) {
              final skills = skillsByAttr[attr];
              if (skills == null || skills.isEmpty)
                return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
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
                    spacing: 8,
                    runSpacing: 8,
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
                            // FIX: Use context.read for actions to ensure the latest controller state is used
                            context
                                .read<CharacterController>()
                                .toggleSkillProficiency(skillName);
                          } else {
                            // Roll Logic
                            final diceController = context
                                .read<DiceController>();
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
                  const SizedBox(height: 24),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- Sleek Skill Chip Widget ---
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
      behavior: HitTestBehavior.opaque, // FIX: Ensures taps are caught reliably
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          // Subtle background tint if proficient
          color: isProficient
              ? primaryColor.withValues(alpha: 0.15)
              : const Color(0xFF334155),
          borderRadius: BorderRadius.circular(12),
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
              const SizedBox(width: 8),
            ],
            Text(
              name,
              style: TextStyle(
                color: isProficient ? Colors.white : Colors.white70,
                fontWeight: isProficient ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            // Bonus Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                bonusStr,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isProficient
                      ? primaryColor.withValues(alpha: 0.9)
                      : Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: Colors.white54),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white38,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttrCard(
    BuildContext context,
    String label,
    int score,
    CharacterController controller,
  ) {
    final mod = ((score - 10) / 2).floor();
    final modStr = mod >= 0 ? "+$mod" : "$mod";
    final isEditing = controller.isEditing;

    return GestureDetector(
      onTap: isEditing
          ? () => _editAttribute(context, label, score, controller)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              modStr,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$score",
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editAttribute(
    BuildContext context,
    String label,
    int current,
    CharacterController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _NumberEditDialog(
        label: label,
        initialValue: current,
        onSave: (v) => controller.updateAttribute(label, v),
      ),
    );
  }

  void _editVital(
    BuildContext context,
    String label,
    int current,
    Function(int) onSave,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _NumberEditDialog(
        label: label,
        initialValue: current,
        onSave: onSave,
      ),
    );
  }
}

class _NumberEditDialog extends StatefulWidget {
  final String label;
  final int initialValue;
  final Function(int) onSave;

  const _NumberEditDialog({
    required this.label,
    required this.initialValue,
    required this.onSave,
  });

  @override
  State<_NumberEditDialog> createState() => _NumberEditDialogState();
}

class _NumberEditDialogState extends State<_NumberEditDialog> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: Text("Edit ${widget.label}"),
      content: TextField(
        controller: _ctrl,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color(0xFF0F172A),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () {
            final val = int.tryParse(_ctrl.text) ?? widget.initialValue;
            widget.onSave(val);
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
