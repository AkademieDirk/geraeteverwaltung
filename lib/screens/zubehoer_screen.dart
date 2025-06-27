import 'package:flutter/material.dart';
import '../models/ersatzteil.dart';

class ZubehoerScreen extends StatefulWidget {
  final List<Ersatzteil> ersatzteile;
  // GEÄNDERT: Neue Callbacks für Firestore-Operationen
  final Future<void> Function(Ersatzteil) onAdd;
  final Future<void> Function(Ersatzteil) onUpdate;
  final Future<void> Function(String) onDelete;

  const ZubehoerScreen({
    Key? key,
    required this.ersatzteile,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<ZubehoerScreen> createState() => _ZubehoerScreenState();
}

class _ZubehoerScreenState extends State<ZubehoerScreen> {

  final List<String> _kategorien = ['Toner', 'Drum', 'Fixierung', 'Transferbelt', 'Sonstiges'];

  void _neuesErsatzteilDialog({Ersatzteil? ersatzteil}) {
    final isEdit = ersatzteil != null;

    final _artikelController = TextEditingController(text: ersatzteil?.artikelnummer ?? '');
    final _bezeichnungController = TextEditingController(text: ersatzteil?.bezeichnung ?? '');
    final _lieferantController = TextEditingController(text: ersatzteil?.lieferant ?? '');
    final _preisController = TextEditingController(text: isEdit ? ersatzteil.preis.toStringAsFixed(2) : '');
    String _ausgewaehlteKategorie = ersatzteil?.kategorie ?? _kategorien.first;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Ersatzteil bearbeiten' : 'Neues Ersatzteil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _ausgewaehlteKategorie,
                items: _kategorien.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                decoration: const InputDecoration(labelText: 'Kategorie'),
                onChanged: (val) {
                  if (val != null) _ausgewaehlteKategorie = val;
                },
              ),
              TextField(controller: _artikelController, decoration: const InputDecoration(labelText: 'Artikelnummer')),
              TextField(controller: _bezeichnungController, decoration: const InputDecoration(labelText: 'Bezeichnung')),
              TextField(controller: _lieferantController, decoration: const InputDecoration(labelText: 'Lieferant')),
              TextField(
                controller: _preisController,
                decoration: const InputDecoration(labelText: 'Preis (z.B. 99.99)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.of(ctx).pop()),
          ElevatedButton(
            child: Text(isEdit ? 'Speichern' : 'Hinzufügen'),
            onPressed: () async {
              final artikel = _artikelController.text.trim();
              final bez = _bezeichnungController.text.trim();
              final lief = _lieferantController.text.trim();
              final preis = double.tryParse(_preisController.text.replaceAll(',', '.')) ?? 0.0;

              if (artikel.isEmpty || bez.isEmpty || lief.isEmpty || preis <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte alle Felder korrekt ausfüllen!')));
                return;
              }

              final neuesTeil = Ersatzteil(
                id: isEdit ? ersatzteil.id : '', // Wichtig: ID beim Bearbeiten beibehalten
                artikelnummer: artikel,
                bezeichnung: bez,
                lieferant: lief,
                preis: preis,
                kategorie: _ausgewaehlteKategorie,
              );

              if (isEdit) {
                await widget.onUpdate(neuesTeil);
              } else {
                await widget.onAdd(neuesTeil);
              }

              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _deleteErsatzteil(Ersatzteil ersatzteil) async {
    final sicher = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wirklich löschen?'),
        content: Text('Ersatzteil "${ersatzteil.bezeichnung}" wirklich entfernen?'),
        actions: [
          TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.pop(ctx, false)),
          TextButton(child: Text('Löschen', style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (sicher == true) {
      await widget.onDelete(ersatzteil.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Ersatzteil>> gruppiert = {};
    for (var et in widget.ersatzteile) {
      gruppiert.putIfAbsent(et.kategorie, () => []).add(et);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ersatzteile verwalten'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Neues Ersatzteil',
            onPressed: () => _neuesErsatzteilDialog(),
          )
        ],
      ),
      body: gruppiert.isEmpty
          ? const Center(child: Text('Noch keine Ersatzteile vorhanden. Fügen Sie welche hinzu!'))
          : ListView(
        children: gruppiert.entries.map((eintrag) {
          final kategorie = eintrag.key;
          final teile = eintrag.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ExpansionTile(
              title: Text(kategorie, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              initiallyExpanded: true,
              children: teile.map((teil) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text('${teil.bezeichnung} (${teil.artikelnummer})'),
                  subtitle: Text('Lieferant: ${teil.lieferant}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${teil.preis.toStringAsFixed(2)} €'),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Bearbeiten',
                        onPressed: () => _neuesErsatzteilDialog(ersatzteil: teil),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Löschen',
                        onPressed: () => _deleteErsatzteil(teil),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _neuesErsatzteilDialog(),
        label: const Text('Hinzufügen'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
