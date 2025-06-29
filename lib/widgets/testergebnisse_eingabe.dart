import 'package:flutter/material.dart';

class TestergebnisseEingabe extends StatelessWidget {
  final TextEditingController fach1Controller;
  final TextEditingController fach2Controller;
  final TextEditingController fach3Controller;
  final TextEditingController fach4Controller;
  final TextEditingController bypassController;
  final TextEditingController dokumenteneinzugController;
  final TextEditingController duplexController;

  const TestergebnisseEingabe({
    Key? key,
    required this.fach1Controller,
    required this.fach2Controller,
    required this.fach3Controller,
    required this.fach4Controller,
    required this.bypassController,
    required this.dokumenteneinzugController,
    required this.duplexController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: TextFormField(controller: fach1Controller, decoration: const InputDecoration(labelText: 'Fach1'))),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: fach2Controller, decoration: const InputDecoration(labelText: 'Fach2'))),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: fach3Controller, decoration: const InputDecoration(labelText: 'Fach3'))),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: fach4Controller, decoration: const InputDecoration(labelText: 'Fach4'))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: TextFormField(controller: bypassController, decoration: const InputDecoration(labelText: 'Bypass'))),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: dokumenteneinzugController, decoration: const InputDecoration(labelText: 'Dokumenteneinzug'))),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: duplexController, decoration: const InputDecoration(labelText: 'Duplex'))),
          ],
        ),
      ],
    );
  }
}
