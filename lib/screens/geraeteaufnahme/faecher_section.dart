import 'package:flutter/material.dart';

class FaecherSection extends StatelessWidget {
  final TextEditingController fach1Controller;
  final TextEditingController fach2Controller;
  final TextEditingController fach3Controller;
  final TextEditingController fach4Controller;
  final TextEditingController bypassController;
  final TextEditingController dokumenteneinzugController;
  final TextEditingController duplexController;

  const FaecherSection({
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
        Text('Testergebnisse und Zustand', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: fach1Controller,
                decoration: InputDecoration(labelText: 'Fach1'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: fach2Controller,
                decoration: InputDecoration(labelText: 'Fach2'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: fach3Controller,
                decoration: InputDecoration(labelText: 'Fach3'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: fach4Controller,
                decoration: InputDecoration(labelText: 'Fach4'),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: bypassController,
                decoration: InputDecoration(labelText: 'Bypass'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: dokumenteneinzugController,
                decoration: InputDecoration(labelText: 'Dokumenteneinzug'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: duplexController,
                decoration: InputDecoration(labelText: 'Duplex'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
