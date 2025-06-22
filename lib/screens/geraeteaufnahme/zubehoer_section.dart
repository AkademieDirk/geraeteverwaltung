import 'package:flutter/material.dart';

class ZubehoerSection extends StatelessWidget {
  // Originaleinzug
  final List<String> originaleinzugTypOptionen;
  final String selectedOriginaleinzugTyp;
  final ValueChanged<String?> onChangedOriginaleinzugTyp;
  final TextEditingController originaleinzugSNController;

  // Unterschrank
  final List<String> unterschrankTypOptionen;
  final String selectedUnterschrankTyp;
  final ValueChanged<String?> onChangedUnterschrankTyp;
  final TextEditingController unterschrankSNController;

  // Finisher
  final List<String> finisherOptionen;
  final String selectedFinisher;
  final ValueChanged<String?> onChangedFinisher;
  final TextEditingController finisherSNController;

  // Fax
  final List<String> jaNeinOptionen;
  final String selectedFax;
  final ValueChanged<String?> onChangedFax;

  const ZubehoerSection({
    Key? key,
    required this.originaleinzugTypOptionen,
    required this.selectedOriginaleinzugTyp,
    required this.onChangedOriginaleinzugTyp,
    required this.originaleinzugSNController,
    required this.unterschrankTypOptionen,
    required this.selectedUnterschrankTyp,
    required this.onChangedUnterschrankTyp,
    required this.unterschrankSNController,
    required this.finisherOptionen,
    required this.selectedFinisher,
    required this.onChangedFinisher,
    required this.finisherSNController,
    required this.jaNeinOptionen,
    required this.selectedFax,
    required this.onChangedFax,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Zubehör:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedOriginaleinzugTyp,
                decoration: const InputDecoration(labelText: 'Originaleinzug Typ'),
                items: originaleinzugTypOptionen
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: onChangedOriginaleinzugTyp,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: originaleinzugSNController,
                decoration: const InputDecoration(labelText: 'Seriennummer'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedUnterschrankTyp,
                decoration: const InputDecoration(labelText: 'Unterschrank Typ'),
                items: unterschrankTypOptionen
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: onChangedUnterschrankTyp,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: unterschrankSNController,
                decoration: const InputDecoration(labelText: 'Seriennummer'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedFinisher,
                decoration: const InputDecoration(labelText: 'Finisher'),
                items: finisherOptionen
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: onChangedFinisher,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: finisherSNController,
                decoration: const InputDecoration(labelText: 'Seriennummer'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedFax,
          decoration: const InputDecoration(labelText: 'Fax'),
          items: jaNeinOptionen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: onChangedFax,
        ),
      ],
    );
  }
}
