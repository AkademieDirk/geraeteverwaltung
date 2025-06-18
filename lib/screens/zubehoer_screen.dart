import 'package:flutter/material.dart';
import '../models/ersatzteil.dart';

class ZubehoerScreen extends StatefulWidget {
  final List<Ersatzteil> ersatzteile;
  final ValueChanged<List<Ersatzteil>> onErsatzteileChanged;

  const ZubehoerScreen({
    Key? key,
    required this.ersatzteile,
    required this.onErsatzteileChanged,
  }) : super(key: key);

  @override
  State<ZubehoerScreen> createState() => _ZubehoerScreenState();
}

class _ZubehoerScreenState extends State<ZubehoerScreen> {
  late List<Ersatzteil> _artikelListe;

  final List<String> _kategorien = [
    'Toner',
    'Drum',
    'Fixierung',
    'Transferbelt',
    'Sonstiges',
  ];

  @override
  void initState() {
    super.initState();
    _artikelListe = List.from(widget.ersatzteile);
  }

  void _neuesErsatzteilDialog({int? editIndex}) {
    final isEdit = editIndex != null;
    final et = isEdit ? _artikelListe[editIndex!] : null;

    final _artikelController = TextEditingController(text: et?.artikelnummer ?? '');
    final _bezeichnungController = TextEditingController(text: et?.bezeichnung ?? '');
    final _lieferantController = TextEditingController(text: et?.lieferant ?? '');
    final _preisController = TextEditingController(text: et != null ? et.preis.toStringAsFixed(2) : '');
    String _ausgewaehlteKategorie = et?.kategorie ?? _kategorien.first;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Ersatzteil bearbeiten' : 'Neues Ersatzteil hinzufügen'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _ausgewaehlteKategorie,
                items: _kategorien
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                decoration: InputDecoration(labelText: 'Kategorie'),
                onChanged: (val) {
                  if (val != null) _ausgewaehlteKategorie = val;
                },
              ),
              TextField(
                controller: _artikelController,
                decoration: InputDecoration(labelText: 'Artikelnummer'),
              ),
              TextField(
                controller: _bezeichnungController,
                decoration: InputDecoration(labelText: 'Bezeichnung'),
              ),
              TextField(
                controller: _lieferantController,
                decoration: InputDecoration(labelText: 'Lieferant'),
              ),
              TextField(
                controller: _preisController,
                decoration: InputDecoration(labelText: 'Preis (z.B. 99.99)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Abbrechen'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: Text(isEdit ? 'Speichern' : 'Hinzufügen'),
            onPressed: () {
              final artikel = _artikelController.text.trim();
              final bez = _bezeichnungController.text.trim();
              final lief = _lieferantController.text.trim();
              final preis = double.tryParse(_preisController.text.replaceAll(',', '.')) ?? 0.0;
              final kat = _ausgewaehlteKategorie;

              if (artikel.isEmpty || bez.isEmpty || lief.isEmpty || preis <= 0 || kat.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bitte alle Felder korrekt ausfüllen!')),
                );
                return;
              }

              setState(() {
                if (isEdit) {
                  _artikelListe[editIndex!] = Ersatzteil(
                    artikelnummer: artikel,
                    bezeichnung: bez,
                    lieferant: lief,
                    preis: preis,
                    kategorie: kat,
                  );
                } else {
                  _artikelListe.add(
                    Ersatzteil(
                      artikelnummer: artikel,
                      bezeichnung: bez,
                      lieferant: lief,
                      preis: preis,
                      kategorie: kat,
                    ),
                  );
                }
              });
              widget.onErsatzteileChanged(_artikelListe);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _deleteErsatzteil(int index) async {
    final sicher = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Wirklich löschen?'),
        content: Text('Ersatzteil "${_artikelListe[index].bezeichnung}" wirklich entfernen?'),
        actions: [
          TextButton(
            child: Text('Abbrechen'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            child: Text('Löschen', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (sicher == true) {
      setState(() {
        _artikelListe.removeAt(index);
      });
      widget.onErsatzteileChanged(_artikelListe);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nach Kategorie gruppieren
    Map<String, List<Ersatzteil>> gruppiert = {};
    for (var et in _artikelListe) {
      gruppiert.putIfAbsent(et.kategorie, () => []).add(et);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Zubehör-Übersicht'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Neues Ersatzteil hinzufügen',
            onPressed: () => _neuesErsatzteilDialog(),
          )
        ],
      ),
      body: gruppiert.isEmpty
          ? Center(child: Text('Noch keine Ersatzteile vorhanden.'))
          : ListView(
        children: gruppiert.entries.map((eintrag) {
          final kategorie = eintrag.key;
          final teile = eintrag.value;
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ExpansionTile(
              title: Text(
                kategorie,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              initiallyExpanded: true,
              children: teile
                  .asMap()
                  .entries
                  .map((e) => Card(
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text('${e.value.bezeichnung} (${e.value.artikelnummer})'),
                  subtitle: Text('Lieferant: ${e.value.lieferant}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${e.value.preis.toStringAsFixed(2)} €'),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Bearbeiten',
                        onPressed: () => _neuesErsatzteilDialog(editIndex: _artikelListe.indexOf(e.value)),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Löschen',
                        onPressed: () => _deleteErsatzteil(_artikelListe.indexOf(e.value)),
                      ),
                    ],
                  ),
                ),
              ))
                  .toList(),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _neuesErsatzteilDialog(),
        label: Text('Hinzufügen'),
        icon: Icon(Icons.add),
      ),
    );
  }
}
