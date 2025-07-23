import 'package:flutter/material.dart';
import '../models/ersatzteil.dart';

class ZubehoerScreen extends StatefulWidget {
  final List<Ersatzteil> ersatzteile;
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
  final List<String> _lieferanten = ['Nichts ausgewählt', 'Katun', 'Biuromax'];

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

  // --- NEU: Funktion, um alle Bestände auf 5 zu setzen ---
  Future<void> _setAllStockToFive() async {
    final sicher = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bestände zurücksetzen?'),
        content: const Text('Sollen wirklich die Bestände ALLER Artikel in ALLEN Lagern auf 5 gesetzt werden? Diese Aktion kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.pop(ctx, false)),
          TextButton(child: Text('Ja, zurücksetzen', style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );

    if (sicher == true && mounted) {
      // Zeigt einen Lade-Indikator an
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Bestände werden aktualisiert..."),
                ],
              ),
            ),
          );
        },
      );

      try {
        for (final teil in widget.ersatzteile) {
          final updatedTeil = Ersatzteil(
            id: teil.id,
            artikelnummer: teil.artikelnummer,
            bezeichnung: teil.bezeichnung,
            hersteller: teil.hersteller,
            haendlerArtikelnummer: teil.haendlerArtikelnummer,
            lieferant: teil.lieferant,
            preis: teil.preis,
            kategorie: teil.kategorie,
            lagerbestaende: {
              'Hauptlager': 5,
              'Fahrzeug Patrick': 5,
              'Fahrzeug Melanie': 5,
            },
          );
          await widget.onUpdate(updatedTeil);
        }
        Navigator.of(context).pop(); // Schließt den Lade-Dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alle Bestände wurden auf 5 gesetzt.'), backgroundColor: Colors.green),
        );
      } catch (e) {
        Navigator.of(context).pop(); // Schließt den Lade-Dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Aktualisieren: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _stammDatenDialog({Ersatzteil? ersatzteil, bool isCopy = false}) {
    final isEdit = ersatzteil != null && !isCopy;

    final artikelController = TextEditingController(text: isCopy ? '' : ersatzteil?.artikelnummer ?? '');
    final bezeichnungController = TextEditingController(text: ersatzteil?.bezeichnung ?? '');
    final herstellerController = TextEditingController(text: ersatzteil?.hersteller ?? '');
    final haendlerArtikelController = TextEditingController(text: ersatzteil?.haendlerArtikelnummer ?? '');
    final preisController = TextEditingController(text: isEdit || isCopy ? ersatzteil!.preis.toStringAsFixed(2) : '');
    String ausgewaehlteKategorie = ersatzteil?.kategorie ?? _kategorien.first;
    String ausgewaehlterLieferant = (isEdit || isCopy) && _lieferanten.contains(ersatzteil!.lieferant) ? ersatzteil.lieferant : 'Nichts ausgewählt';

    final hauptlagerController = TextEditingController(text: (isEdit ? ersatzteil.lagerbestaende['Hauptlager'] ?? 0 : 5).toString());
    final patrickController = TextEditingController(text: (isEdit ? ersatzteil.lagerbestaende['Fahrzeug Patrick'] ?? 0 : 5).toString());
    final melanieController = TextEditingController(text: (isEdit ? ersatzteil.lagerbestaende['Fahrzeug Melanie'] ?? 0 : 5).toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Stammdaten bearbeiten' : 'Neues Ersatzteil anlegen'),
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
              TextField(controller: herstellerController, decoration: const InputDecoration(labelText: 'Hersteller')),
              TextField(controller: haendlerArtikelController, decoration: const InputDecoration(labelText: 'Händler-Art.-Nr.')),
              DropdownButtonFormField<String>(
                value: ausgewaehlterLieferant,
                items: _lieferanten.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                decoration: const InputDecoration(labelText: 'Lieferant'),
                onChanged: (val) { if (val != null) ausgewaehlterLieferant = val; },
              ),
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
              final preis = double.tryParse(preisController.text.replaceAll(',', '.')) ?? 0.0;

              if (preis <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte einen gültigen Preis angeben!')));
                return;
              }

              final lagerbestaende = {
                'Hauptlager': int.tryParse(hauptlagerController.text) ?? 0,
                'Fahrzeug Patrick': int.tryParse(patrickController.text) ?? 0,
                'Fahrzeug Melanie': int.tryParse(melanieController.text) ?? 0,
              };

              final neuesTeil = Ersatzteil(
                id: isEdit ? ersatzteil.id : '',
                artikelnummer: artikelController.text.trim(),
                bezeichnung: bezeichnungController.text.trim(),
                hersteller: herstellerController.text.trim(),
                haendlerArtikelnummer: haendlerArtikelController.text.trim(),
                lieferant: ausgewaehlterLieferant == 'Nichts ausgewählt' ? '' : ausgewaehlterLieferant,
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
            teil.artikelnummer.toLowerCase().contains(suchbegriff) ||
            teil.hersteller.toLowerCase().contains(suchbegriff);
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
        title: Text(isLagerAnsicht ? 'Bestand: ${widget.angezeigtesLager}' : 'Stammdaten'),
        actions: isLagerAnsicht ? [] : [
          // --- NEU: Button zum Zurücksetzen der Bestände ---
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Alle Bestände auf 5 setzen',
            onPressed: _setAllStockToFive,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Neues Ersatzteil',
            onPressed: () => _stammDatenDialog(),
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
                labelText: 'Suche nach Bezeichnung, Artikel-Nr. oder Hersteller',
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

                final int anzahl = isLagerAnsicht
                    ? teile.fold(0, (sum, teil) => sum + (teil.lagerbestaende[widget.angezeigtesLager!] ?? 0))
                    : teile.length;

                final String einheit = isLagerAnsicht ? 'Stk.' : 'Artikel';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ExpansionTile(
                    title: Text('$kategorie ($anzahl $einheit)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                                Text("Hersteller: ${teil.hersteller}"),
                                Text("Lieferant: ${teil.lieferant}"),
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
                                IconButton(icon: const Icon(Icons.edit, color: Colors.orange), tooltip: 'Bearbeiten', onPressed: () => _stammDatenDialog(ersatzteil: teil)),
                              if(!isLagerAnsicht)
                                IconButton(icon: const Icon(Icons.copy, color: Colors.blue), tooltip: 'Kopieren', onPressed: () => _stammDatenDialog(ersatzteil: teil, isCopy: true)),
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
        onPressed: () => _stammDatenDialog(),
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
