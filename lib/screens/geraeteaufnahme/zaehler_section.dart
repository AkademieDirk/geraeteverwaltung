import 'package:flutter/material.dart';

class ZaehlerSection extends StatelessWidget {
  final TextEditingController zaehlerSWController;
  final TextEditingController zaehlerColorController;
  final TextEditingController zaehlerGesamtController;
  final VoidCallback onChanged;

  const ZaehlerSection({
    Key? key,
    required this.zaehlerSWController,
    required this.zaehlerColorController,
    required this.zaehlerGesamtController,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Zählerstände:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: zaehlerSWController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'S/W'),
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: zaehlerColorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Color'),
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: zaehlerGesamtController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Gesamt (Auto)'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
