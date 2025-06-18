import 'package:flutter/material.dart';

class GrunddatenSection extends StatelessWidget {
  final TextEditingController nummerController;
  final String? selectedModell;
  final List<String> modellOptionen;
  final ValueChanged<String?> onModellChanged;
  final TextEditingController seriennummerController;
  final String? selectedMitarbeiter;
  final List<String> mitarbeiterListe;
  final ValueChanged<String?> onMitarbeiterChanged;

  const GrunddatenSection({
    Key? key,
    required this.nummerController,
    required this.selectedModell,
    required this.modellOptionen,
    required this.onModellChanged,
    required this.seriennummerController,
    required this.selectedMitarbeiter,
    required this.mitarbeiterListe,
    required this.onMitarbeiterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nummerController,
          decoration: InputDecoration(labelText: 'Gerätenummer*'),
        ),
        DropdownButtonFormField<String>(
          value: selectedModell,
          decoration: InputDecoration(labelText: 'Modell*'),
          items: modellOptionen
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: onModellChanged,
        ),
        TextFormField(
          controller: seriennummerController,
          decoration: InputDecoration(labelText: 'Seriennummer'),
        ),
        DropdownButtonFormField<String>(
          value: selectedMitarbeiter,
          decoration: InputDecoration(labelText: 'Verantwortlicher Mitarbeiter*'),
          items: mitarbeiterListe
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: onMitarbeiterChanged,
        ),
      ],
    );
  }
}
