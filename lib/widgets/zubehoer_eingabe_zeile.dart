import 'package:flutter/material.dart';

class ZubehoerEingabeZeile extends StatelessWidget {
  final String label;
  final String selectedValue;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final TextEditingController snController;
  final bool showSnField;

  const ZubehoerEingabeZeile({
    Key? key,
    required this.label,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    required this.snController,
    this.showSnField = true, // Das SN-Feld ist standardmäßig sichtbar
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              decoration: InputDecoration(labelText: label),
              items: options.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: onChanged,
            ),
          ),
          // Das Seriennummernfeld wird nur angezeigt, wenn es benötigt wird.
          if (showSnField) ...[
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: snController,
                decoration: const InputDecoration(labelText: 'Seriennummer'),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
