import 'package:flutter/material.dart';

class ProzentDropdown extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int?> onChanged;
  final List<int> prozentSchritte = List.generate(11, (i) => i * 10);

  ProzentDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: prozentSchritte
            .map((v) => DropdownMenuItem(value: v, child: Text('$v%')))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
