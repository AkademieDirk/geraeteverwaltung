import 'package.flutter/material.dart';

class ChoiceChipRow extends StatelessWidget {
  final String label;
  final String groupValue;
  final ValueChanged<String> onSelected;

  const ChoiceChipRow({
    Key? key,
    required this.label,
    required this.groupValue,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Ja'),
                selected: groupValue == 'Ja',
                onSelected: (selected) {
                  if (selected) onSelected('Ja');
                },
                selectedColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(color: groupValue == 'Ja' ? Colors.white : Colors.black),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Nein'),
                selected: groupValue == 'Nein',
                onSelected: (selected) {
                  if (selected) onSelected('Nein');
                },
                selectedColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(color: groupValue == 'Nein' ? Colors.white : Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
