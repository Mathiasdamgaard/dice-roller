import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_controller.dart';
import '../widgets/character/character_vitals.dart';
import '../widgets/character/character_attributes.dart';
import '../widgets/character/character_skills.dart';

class CharacterScreen extends StatelessWidget {
  final VoidCallback? onRollRequest;

  const CharacterScreen({super.key, this.onRollRequest});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CharacterController>();
    final isEditing = controller.isEditing;

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
            const CharacterVitals(),
            const SizedBox(height: 24),

            // --- Attributes Grid ---
            const CharacterAttributes(),

            const SizedBox(height: 32),

            // --- Skills Sections (Grouped by Attribute) ---
            CharacterSkills(onRollRequest: onRollRequest),
          ],
        ),
      ),
    );
  }
}
