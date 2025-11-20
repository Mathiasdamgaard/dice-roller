import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/dice_controller.dart';

class SavePresetDialog extends StatefulWidget {
  const SavePresetDialog({super.key});

  @override
  State<SavePresetDialog> createState() => _SavePresetDialogState();
}

class _SavePresetDialogState extends State<SavePresetDialog> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<DiceController>();

    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: const Text("Save Preset"),
      content: TextField(
        controller: _textController,
        decoration: const InputDecoration(
          labelText: "Preset Name",
          hintText: "e.g., Fireball",
          filled: true,
          fillColor: AppColors.inputFill,
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              controller.saveCurrentPreset(_textController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Preset Saved!")));
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
