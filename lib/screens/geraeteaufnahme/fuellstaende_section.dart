import 'package:flutter/material.dart';

class FuellstaendeSection extends StatelessWidget {
  final List<int> prozentSchritte;

  // RTB und Toner
  final int rtb;
  final ValueChanged<int?> onChangedRtb;
  final int tonerK;
  final ValueChanged<int?> onChangedTonerK;
  final int tonerC;
  final ValueChanged<int?> onChangedTonerC;
  final int tonerM;
  final ValueChanged<int?> onChangedTonerM;
  final int tonerY;
  final ValueChanged<int?> onChangedTonerY;

  // Laufzeiten Bildeinheit
  final int laufzeitBildeinheitK;
  final ValueChanged<int?> onChangedLaufzeitBildeinheitK;
  final int laufzeitBildeinheitC;
  final ValueChanged<int?> onChangedLaufzeitBildeinheitC;
  final int laufzeitBildeinheitM;
  final ValueChanged<int?> onChangedLaufzeitBildeinheitM;
  final int laufzeitBildeinheitY;
  final ValueChanged<int?> onChangedLaufzeitBildeinheitY;

  // Laufzeiten Entwickler
  final int laufzeitEntwicklerK;
  final ValueChanged<int?> onChangedLaufzeitEntwicklerK;
  final int laufzeitEntwicklerC;
  final ValueChanged<int?> onChangedLaufzeitEntwicklerC;
  final int laufzeitEntwicklerM;
  final ValueChanged<int?> onChangedLaufzeitEntwicklerM;
  final int laufzeitEntwicklerY;
  final ValueChanged<int?> onChangedLaufzeitEntwicklerY;

  // Fixiereinheit und Transferbelt
  final int laufzeitFixiereinheit;
  final ValueChanged<int?> onChangedLaufzeitFixiereinheit;
  final int laufzeitTransferbelt;
  final ValueChanged<int?> onChangedLaufzeitTransferbelt;

  const FuellstaendeSection({
    Key? key,
    required this.prozentSchritte,
    required this.rtb,
    required this.onChangedRtb,
    required this.tonerK,
    required this.onChangedTonerK,
    required this.tonerC,
    required this.onChangedTonerC,
    required this.tonerM,
    required this.onChangedTonerM,
    required this.tonerY,
    required this.onChangedTonerY,
    required this.laufzeitBildeinheitK,
    required this.onChangedLaufzeitBildeinheitK,
    required this.laufzeitBildeinheitC,
    required this.onChangedLaufzeitBildeinheitC,
    required this.laufzeitBildeinheitM,
    required this.onChangedLaufzeitBildeinheitM,
    required this.laufzeitBildeinheitY,
    required this.onChangedLaufzeitBildeinheitY,
    required this.laufzeitEntwicklerK,
    required this.onChangedLaufzeitEntwicklerK,
    required this.laufzeitEntwicklerC,
    required this.onChangedLaufzeitEntwicklerC,
    required this.laufzeitEntwicklerM,
    required this.onChangedLaufzeitEntwicklerM,
    required this.laufzeitEntwicklerY,
    required this.onChangedLaufzeitEntwicklerY,
    required this.laufzeitFixiereinheit,
    required this.onChangedLaufzeitFixiereinheit,
    required this.laufzeitTransferbelt,
    required this.onChangedLaufzeitTransferbelt,
  }) : super(key: key);

  Widget _buildProzentDropdown(String label, int value, ValueChanged<int?> onChanged) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Füllstände (in %):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildProzentDropdown('RTB', rtb, onChangedRtb),
            const SizedBox(width: 8),
            _buildProzentDropdown('Toner K', tonerK, onChangedTonerK),
            const SizedBox(width: 8),
            _buildProzentDropdown('Toner C', tonerC, onChangedTonerC),
            const SizedBox(width: 8),
            _buildProzentDropdown('Toner M', tonerM, onChangedTonerM),
            const SizedBox(width: 8),
            _buildProzentDropdown('Toner Y', tonerY, onChangedTonerY),
          ],
        ),
        const SizedBox(height: 22),
        const Text('Laufzeiten Bildeinheit (jeweils %):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Row(
          children: [
            _buildProzentDropdown('K', laufzeitBildeinheitK, onChangedLaufzeitBildeinheitK),
            const SizedBox(width: 8),
            _buildProzentDropdown('C', laufzeitBildeinheitC, onChangedLaufzeitBildeinheitC),
            const SizedBox(width: 8),
            _buildProzentDropdown('M', laufzeitBildeinheitM, onChangedLaufzeitBildeinheitM),
            const SizedBox(width: 8),
            _buildProzentDropdown('Y', laufzeitBildeinheitY, onChangedLaufzeitBildeinheitY),
          ],
        ),
        const SizedBox(height: 22),
        const Text('Laufzeiten Entwickler (jeweils %):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Row(
          children: [
            _buildProzentDropdown('K', laufzeitEntwicklerK, onChangedLaufzeitEntwicklerK),
            const SizedBox(width: 8),
            _buildProzentDropdown('C', laufzeitEntwicklerC, onChangedLaufzeitEntwicklerC),
            const SizedBox(width: 8),
            _buildProzentDropdown('M', laufzeitEntwicklerM, onChangedLaufzeitEntwicklerM),
            const SizedBox(width: 8),
            _buildProzentDropdown('Y', laufzeitEntwicklerY, onChangedLaufzeitEntwicklerY),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            _buildProzentDropdown('Fixiereinheit', laufzeitFixiereinheit, onChangedLaufzeitFixiereinheit),
            const SizedBox(width: 8),
            _buildProzentDropdown('Transferbelt', laufzeitTransferbelt, onChangedLaufzeitTransferbelt),
          ],
        ),
      ],
    );
  }
}
