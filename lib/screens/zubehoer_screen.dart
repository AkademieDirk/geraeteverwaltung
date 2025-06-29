import 'package:flutter/material.dart';
import '../models/ersatzteil.dart';

class ZubehoerScreen extends StatefulWidget {
  final List<Ersatzteil> ersatzteile;
  // Dieser Parameter ist optional. Ist er gesetzt, wird der Screen
  // zur reinen Ansicht für ein spezifisches Lager.
  final String? angezeigtesLager;
  final Future<void> Function(Ersatzteil) onAdd;
  final Future<void> Function(Ersatzteil) onUpdate;
  final Future<void> Function(String) onDelete;

  const ZubehoerScreen({
    Key? key,
    required this.ersatzteile,
    this.angezeigtesLager,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<ZubehoerScreen> createState() => _ZubehoerScreenState();
}

class _ZubehoerScreenState extends State<ZubehoerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  final List<String> _kategorien = ['Toner', 'Drum', 'Transferbelt', 'Fixierung', 'Entwickler', 'Sonstiges'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _neuesErsatzteilDialog({Ersatzteil? ersatzteil}) {
    final isEdit = ersatzteil != null;

    final artikelController = TextEditingController(text: ersatzteil?.artikelnummer ?? '');
    final bezeichnungController = TextEditingController(text: ersatzteil?.bezeichnung ?? '');
    final lieferantController = TextEditingController(text: ersatzteil?.lieferant ?? '');
    final preisController = TextEditingController(text: isEdit ? ersatzteil.preis.toStringAsFixed(2) : '');
    String ausgewaehlteKategorie = ersatzteil?.kategorie ?? _kategorien.first;

    final hauptlagerController = TextEditingController(text: (ersatzteil?.lagerbestaende['Hauptlager'] ?? 0).toString());
    final patrickController = TextEditingController(text: (ersatzteil?.lagerbestaende['Fahrzeug Patrick'] ?? 0).toString());
    final melanieController = TextEditingController(text: (ersatzteil?.lagerbestaende['Fahrzeug Melanie'] ?? 0).toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Ersatzteil bearbeiten' : 'Neues Ersatzteil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: ausgewaehlteKategorie,
                items: _kategorien.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                decoration: const InputDecoration(labelText: 'Kategorie'),
                onChanged: (val) { if (val != null) ausgewaehlteKategorie = val; },
              ),
              TextField(controller: artikelController, decoration: const InputDecoration(labelText: 'Artikelnummer')),
              TextField(controller: bezeichnungController, decoration: const InputDecoration(labelText: 'Bezeichnung')),
              TextField(controller: lieferantController, decoration: const InputDecoration(labelText: 'Lieferant')),
              TextField(
                controller: preisController,
                decoration: const InputDecoration(labelText: 'Preis (z.B. 99.99)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              const Text("Lagerbestände", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(controller: hauptlagerController, decoration: const InputDecoration(labelText: 'Hauptlager'), keyboardType: TextInputType.number),
              TextField(controller: patrickController, decoration: const InputDecoration(labelText: 'Fahrzeug Patrick'), keyboardType: TextInputType.number),
              TextField(controller: melanieController, decoration: const InputDecoration(labelText: 'Fahrzeug Melanie'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.of(ctx).pop()),
          ElevatedButton(
            child: Text(isEdit ? 'Speichern' : 'Hinzufügen'),
            onPressed: () async {
              final artikel = artikelController.text.trim();
              final bez = bezeichnungController.text.trim();
              final lief = lieferantController.text.trim();
              final preis = double.tryParse(preisController.text.replaceAll(',', '.')) ?? 0.0;

              final lagerbestaende = {
                'Hauptlager': int.tryParse(hauptlagerController.text) ?? 0,
                'Fahrzeug Patrick': int.tryParse(patrickController.text) ?? 0,
                'Fahrzeug Melanie': int.tryParse(melanieController.text) ?? 0,
              };

              if (artikel.isEmpty || bez.isEmpty || lief.isEmpty || preis <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte alle Felder korrekt ausfüllen!')));
                return;
              }

              final neuesTeil = Ersatzteil(
                id: isEdit ? ersatzteil.id : '',
                artikelnummer: artikel,
                bezeichnung: bez,
                lieferant: lief,
                preis: preis,
                kategorie: ausgewaehlteKategorie,
                lagerbestaende: lagerbestaende,
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
    final bool isLagerAnsicht = widget.angezeigtesLager != null;

    List<Ersatzteil> gefilterteListe;

    if (_searchTerm.isEmpty) {
      gefilterteListe = widget.ersatzteile;
    } else {
      gefilterteListe = widget.ersatzteile.where((teil) {
        final suchbegriff = _searchTerm.toLowerCase();
        return teil.bezeichnung.toLowerCase().contains(suchbegriff) ||
            teil.artikelnummer.toLowerCase().contains(suchbegriff);
      }).toList();
    }

    if(isLagerAnsicht) {
      gefilterteListe = gefilterteListe.where((teil) {
        return (teil.lagerbestaende[widget.angezeigtesLager!] ?? 0) > 0;
      }).toList();
    }

    Map<String, List<Ersatzteil>> gruppiert = {};
    for (var et in gefilterteListe) {
      gruppiert.putIfAbsent(et.kategorie, () => []).add(et);
    }
    final sortierteKategorien = gruppiert.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(isLagerAnsicht ? 'Bestand: ${widget.angezeigtesLager}' : 'Stammdaten & Bestand'),
        // Der "Hinzufügen"-Button wird nur im Stammdaten-Modus angezeigt
        actions: isLagerAnsicht ? [] : [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Neues Ersatzteil',
            onPressed: () => _neuesErsatzteilDialog(),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Suche nach Bezeichnung oder Artikelnummer',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchTerm.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear()) : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: gruppiert.isEmpty
                ? const Center(child: Text('Keine passenden Ersatzteile gefunden.'))
                : ListView(
              children: sortierteKategorien.map((kategorie) {
                final teile = gruppiert[kategorie]!;

                final int bestandInDieserKategorie = isLagerAnsicht
                    ? teile.fold(0, (sum, teil) => sum + (teil.lagerbestaende[widget.angezeigtesLager!] ?? 0))
                    : teile.fold(0, (sum, teil) => sum + teil.getGesamtbestand());

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ExpansionTile(
                    title: Text('$kategorie ($bestandInDieserKategorie Stk.)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    children: teile.map((teil) {
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
                        child: ListTile(
                          title: Text('${teil.bezeichnung} (${teil.artikelnummer})'),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isLagerAnsicht)
                                  _buildBestandRow(widget.angezeigtesLager!, teil.lagerbestaende[widget.angezeigtesLager!] ?? 0, isHighlighted: true)
                                else ...[
                                  _buildBestandRow('Hauptlager', teil.lagerbestaende['Hauptlager'] ?? 0),
                                  _buildBestandRow('Fahrzeug Patrick', teil.lagerbestaende['Fahrzeug Patrick'] ?? 0),
                                  _buildBestandRow('Fahrzeug Melanie', teil.lagerbestaende['Fahrzeug Melanie'] ?? 0),
                                ]
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${teil.preis.toStringAsFixed(2)} €'),
                              if(!isLagerAnsicht)
                                IconButton(icon: const Icon(Icons.edit, color: Colors.orange), tooltip: 'Bearbeiten', onPressed: () => _neuesErsatzteilDialog(ersatzteil: teil)),
                              if(!isLagerAnsicht)
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red), tooltip: 'Löschen', onPressed: () => _deleteErsatzteil(teil)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: isLagerAnsicht ? null : FloatingActionButton.extended(
        onPressed: () => _neuesErsatzteilDialog(),
        label: const Text('Hinzufügen'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBestandRow(String lager, int bestand, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text('$lager: ', style: TextStyle(color: Colors.grey.shade700)),
          Text(
            '$bestand Stk.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isHighlighted || bestand > 0 ? Colors.black87 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
