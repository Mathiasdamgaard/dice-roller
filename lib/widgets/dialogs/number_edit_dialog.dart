import 'package:flutter/material.dart';

class NumberEditDialog extends StatefulWidget {
  final String label;
  final int initialValue;
  final Function(int) onSave;

  const NumberEditDialog({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onSave,
  });

  @override
  State<NumberEditDialog> createState() => _NumberEditDialogState();
}

class _NumberEditDialogState extends State<NumberEditDialog> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
