import 'package:flutter/material.dart';

class ZaehlerstaendeEingabe extends StatelessWidget {
  final TextEditingController swController;
  final TextEditingController colorController;
  final TextEditingController gesamtController;
  final VoidCallback onUpdate;

  const ZaehlerstaendeEingabe({
    Key? key,
    required this.swController,
    required this.colorController,
    required this.gesamtController,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: swController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'S/W'),
            onChanged: (val) => onUpdate(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: colorController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Color'),
            onChanged: (val) => onUpdate(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: gesamtController,
            readOnly: true,
            decoration: const InputDecoration(labelText: 'Gesamt (Auto)'),
          ),
        ),
      ],
    );
  }
}
