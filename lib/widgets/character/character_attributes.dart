import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/character_controller.dart';
import '../dialogs/number_edit_dialog.dart';

class CharacterAttributes extends StatelessWidget {
  const CharacterAttributes({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CharacterController>();
    final char = controller.character;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      crossAxisSpacing: AppSpacing.m,
      mainAxisSpacing: AppSpacing.m,
      children: [
        _buildAttrCard(context, "STR", char.strength, controller),
        _buildAttrCard(context, "DEX", char.dexterity, controller),
        _buildAttrCard(context, "CON", char.constitution, controller),
        _buildAttrCard(context, "INT", char.intelligence, controller),
        _buildAttrCard(context, "WIS", char.wisdom, controller),
        _buildAttrCard(context, "CHA", char.charisma, controller),
      ],
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
          color: AppColors.attributeCardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: Offset(0, 2),
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
                color: AppColors.textWhite70,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              modStr,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.s),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.shadow,
                borderRadius: BorderRadius.circular(AppRadius.m),
              ),
              child: Text(
                "$score",
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textWhite54,
                ),
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
      builder: (ctx) => NumberEditDialog(
        label: label,
        initialValue: current,
        onSave: (v) => controller.updateAttribute(label, v),
      ),
    );
  }
}
