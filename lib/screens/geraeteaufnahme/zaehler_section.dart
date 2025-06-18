import 'package:flutter/material.dart';

class ZaehlerSection extends StatelessWidget {
  final TextEditingController zaehlerSWController;
  final TextEditingController zaehlerColorController;
  final int zaehlerGesamt;

  const ZaehlerSection({
    Key? key,
    required this.zaehlerSWController,
    required this.zaehlerColorController,
    required this.zaehlerGesamt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Zählerstände:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: zaehlerSWController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'S/W'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: zaehlerColorController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Color'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                readOnly: true,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Gesamt (Auto)',
                  hintText: zaehlerGesamt.toString(),
                ),
                controller: TextEditingController(text: zaehlerGesamt.toString()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
