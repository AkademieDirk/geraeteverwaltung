import 'package:flutter/material.dart';

class FuellstaendeSection extends StatelessWidget {
  final int rtb;
  final int tonerK;
  final int tonerC;
  final int tonerM;
  final int tonerY;
  final List<int> prozentSchritte;
  final ValueChanged<int?> onRtbChanged;
  final ValueChanged<int?> onTonerKChanged;
  final ValueChanged<int?> onTonerCChanged;
  final ValueChanged<int?> onTonerMChanged;
  final ValueChanged<int?> onTonerYChanged;

  const FuellstaendeSection({
    Key? key,
    required this.rtb,
    required this.tonerK,
    required this.tonerC,
    required this.tonerM,
    required this.tonerY,
    required this.prozentSchritte,
    required this.onRtbChanged,
    required this.onTonerKChanged,
    required this.onTonerCChanged,
    required this.onTonerMChanged,
    required this.onTonerYChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DropdownButtonFormField<int> buildDropdown(String label, int value, ValueChanged<int?> onChanged) {
      return DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: prozentSchritte
            .map((v) => DropdownMenuItem(value: v, child: Text('$v%')))
            .toList(),
        onChanged: onChanged,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Füllstände (in %):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: buildDropdown('RTB', rtb, onRtbChanged)),
            SizedBox(width: 8),
            Expanded(child: buildDropdown('Toner K', tonerK, onTonerKChanged)),
            SizedBox(width: 8),
            Expanded(child: buildDropdown('Toner C', tonerC, onTonerCChanged)),
            SizedBox(width: 8),
            Expanded(child: buildDropdown('Toner M', tonerM, onTonerMChanged)),
            SizedBox(width: 8),
            Expanded(child: buildDropdown('Toner Y', tonerY, onTonerYChanged)),
          ],
        ),
      ],
    );
  }
}
