import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/character_controller.dart';
import '../dialogs/number_edit_dialog.dart';

class CharacterVitals extends StatelessWidget {
  const CharacterVitals({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CharacterController>();
    final char = controller.character;
    final isEditing = controller.isEditing;

    return Row(
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
        const SizedBox(width: AppSpacing.m),
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
        const SizedBox(width: AppSpacing.m),
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
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: AppColors.textWhite54),
              const SizedBox(height: AppSpacing.s),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite38,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
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
      builder: (ctx) =>
          NumberEditDialog(label: label, initialValue: current, onSave: onSave),
    );
  }
}
