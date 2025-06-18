import 'package:flutter/material.dart';

class ZubehoerSection extends StatelessWidget {
  final List<String> originaleinzugTypen;
  final String? selectedOriginaleinzugTyp;
  final ValueChanged<String?> onOriginaleinzugTypChanged;
  final TextEditingController originaleinzugSNController;

  final List<String> unterschrankTypen;
  final String? selectedUnterschrankTyp;
  final ValueChanged<String?> onUnterschrankTypChanged;
  final TextEditingController unterschrankSNController;

  final List<String> finisherTypen;
  final String? selectedFinisherTyp;
  final ValueChanged<String?> onFinisherTypChanged;
  final TextEditingController finisherSNController;

  final String? selectedFax;
  final ValueChanged<String?> onFaxChanged;

  const ZubehoerSection({
    Key? key,
    required this.originaleinzugTypen,
    required this.selectedOriginaleinzugTyp,
    required this.onOriginaleinzugTypChanged,
    required this.originaleinzugSNController,
    required this.unterschrankTypen,
    required this.selectedUnterschrankTyp,
    required this.onUnterschrankTypChanged,
    required this.unterschrankSNController,
    required this.finisherTypen,
    required this.selectedFinisherTyp,
    required this.onFinisherTypChanged,
    required this.finisherSNController,
    required this.selectedFax,
    required this.onFaxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Zubehör:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedOriginaleinzugTyp,
                decoration: InputDecoration(labelText: 'Originaleinzug Typ'),
                items: originaleinzugTypen
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: onOriginaleinzugTypChanged,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: originaleinzugSNController,
                decoration: InputDecoration(labelText: 'Seriennummer'),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedUnterschrankTyp,
                decoration: InputDecoration(labelText: 'Unterschrank Typ'),
                items: unterschrankTypen
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: onUnterschrankTypChanged,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: unterschrankSNController,
                decoration: InputDecoration(labelText: 'Seriennummer'),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedFinisherTyp,
                decoration: InputDecoration(labelText: 'Finisher'),
                items: finisherTypen
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: onFinisherTypChanged,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: finisherSNController,
                decoration: InputDecoration(labelText: 'Seriennummer'),
              ),
            ),
          ],
        ),
        DropdownButtonFormField<String>(
          value: selectedFax,
          decoration: InputDecoration(labelText: 'Fax'),
          items: ['Ja', 'Nein']
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: onFaxChanged,
        ),
      ],
    );
  }
}
