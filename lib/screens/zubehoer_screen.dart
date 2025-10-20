import 'package:flutter/material.dart';
import 'package:projekte/models/ersatzteil.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import für Timestamp

// --- Globale Liste der verfügbaren Kategorien ---
// Zentralisiert, damit sie leicht in initState und im Dropdown verwendet werden kann.
const List<String> verfuegbareKategorienErsatzteil = [
  'Toner',
  'Drum',
  'Transferbelt',
  'Entwickler',
  'Fixiereinheit',
  'Fixierung', // <-- HIER IST DIE HINZUGEFÜGTE KATEGORIE!
  'Rollen',
  'Sonstiges',
];
// --------------------------------------------------

class ZubehoerScreen extends StatefulWidget {
  final List<Ersatzteil> ersatzteile;
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
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

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

  void _showErsatzteilDialog({Ersatzteil? ersatzteil}) {
    showDialog(
      context: context,
      builder: (ctx) => ErsatzteilDialog(
        ersatzteil: ersatzteil,
        onAdd: widget.onAdd,
        onUpdate: widget.onUpdate,
      ),
    );
  }

  void _deleteErsatzteil(Ersatzteil ersatzteil) async {
    final sicher = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wirklich löschen?'),
        content: Text('Soll das Ersatzteil "${ersatzteil.bezeichnung}" wirklich gelöscht werden?'),
        actions: [
          TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.pop(ctx, false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Löschen'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (sicher == true) {
      await widget.onDelete(ersatzteil.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ersatzteil.bezeichnung} wurde gelöscht.'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Ersatzteil> gefilterteErsatzteile = List.from(widget.ersatzteile);

    if (_searchTerm.isNotEmpty) {
      gefilterteErsatzteile = gefilterteErsatzteile.where((e) {
        final s = _searchTerm.toLowerCase();
        return e.bezeichnung.toLowerCase().contains(s) ||
            e.artikelnummer.toLowerCase().contains(s) ||
            e.hersteller.toLowerCase().contains(s) ||
            e.scancode.toLowerCase().contains(s);
      }).toList();
    }

    final Map<String, List<Ersatzteil>> gruppierteTeile = {};
    for (final teil in gefilterteErsatzteile) {
      // Sicherstellen, dass die Kategorie im Dropdown existiert oder auf 'Sonstiges' fällt.
      final kategorie = verfuegbareKategorienErsatzteil.contains(teil.kategorie)
          ? teil.kategorie
          : 'Sonstiges'; // Fallback für ungültige/alte Kategorien
      (gruppierteTeile[kategorie] ??= []).add(teil);
    }
    final kategorien = gruppierteTeile.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stammdaten pflegen'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Suche nach Bezeichnung, Scancode...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchTerm.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear()) : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _searchTerm.isNotEmpty && gefilterteErsatzteile.length == 1
                ? _buildSingleArticleView(gefilterteErsatzteile.first)
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: kategorien.length,
              itemBuilder: (ctx, index) {
                final kategorie = kategorien[index];
                final teileInKategorie = gruppierteTeile[kategorie]!;

                teileInKategorie.sort((a, b) => a.bezeichnung.toLowerCase().compareTo(b.bezeichnung.toLowerCase()));

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ExpansionTile(
                    title: Text(kategorie, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    children: teileInKategorie.map((teil) {
                      return ListTile(
                        title: Text(teil.bezeichnung),
                        subtitle: Text('Art-Nr: ${teil.artikelnummer} | Hersteller: ${teil.hersteller}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showErsatzteilDialog(ersatzteil: teil)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteErsatzteil(teil)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showErsatzteilDialog(),
        tooltip: 'Neues Ersatzteil',
      ),
    );
  }

  Widget _buildSingleArticleView(Ersatzteil teil) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Eindeutiger Treffer gefunden:", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(teil.bezeichnung, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Art-Nr: ${teil.artikelnummer} | Hersteller: ${teil.hersteller}'),
                    if (teil.scancode.isNotEmpty)
                      Text('Scancode: ${teil.scancode}'),
                  ],
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Bearbeiten'),
                    onPressed: () => _showErsatzteilDialog(ersatzteil: teil),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Löschen'),
                    onPressed: () => _deleteErsatzteil(teil),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErsatzteilDialog extends StatefulWidget {
  final Ersatzteil? ersatzteil;
  final Future<void> Function(Ersatzteil) onAdd;
  final Future<void> Function(Ersatzteil) onUpdate;

  const ErsatzteilDialog({
    Key? key,
    this.ersatzteil,
    required this.onAdd,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ErsatzteilDialogState createState() => _ErsatzteilDialogState();
}

class _ErsatzteilDialogState extends State<ErsatzteilDialog> {
  final _formKey = GlobalKey<FormState>();

  final _artikelnummerController = TextEditingController();
  final _bezeichnungController = TextEditingController();
  final _herstellerController = TextEditingController();
  final _haendlerArtikelnummerController = TextEditingController();
  final _lieferantController = TextEditingController();
  final _preisController = TextEditingController();
  // Standardwert für neue Teile, muss eine gültige Kategorie sein
  String _selectedKategorie = verfuegbareKategorienErsatzteil.first;
  final _scancodeController = TextEditingController();

  final Map<String, TextEditingController> _lagerbestandController = {};

  bool get isEdit => widget.ersatzteil != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final teil = widget.ersatzteil!;
      _artikelnummerController.text = teil.artikelnummer;
      _bezeichnungController.text = teil.bezeichnung;
      _herstellerController.text = teil.hersteller;
      _haendlerArtikelnummerController.text = teil.haendlerArtikelnummer;
      _lieferantController.text = teil.lieferant;
      _preisController.text = teil.preis.toStringAsFixed(2);

      // --- KORREKTUR IM INITSTATE ---
      // Sicherstellen, dass die Kategorie des Ersatzteils in der Liste der verfügbaren Kategorien ist.
      // Falls nicht, wird ein Standardwert ('Sonstiges') oder der erste Wert der Liste verwendet.
      if (verfuegbareKategorienErsatzteil.contains(teil.kategorie)) {
        _selectedKategorie = teil.kategorie;
      } else {
        _selectedKategorie = 'Sonstiges'; // Fallback für unbekannte Kategorien
        // Optional: Debug-Ausgabe, falls eine ungültige Kategorie gefunden wird
        debugPrint('WARNUNG: Ersatzteil "${teil.bezeichnung}" hat unbekannte Kategorie "${teil.kategorie}". Setze auf "${_selectedKategorie}".');
      }
      // ----------------------------

      _scancodeController.text = teil.scancode;

      // Lagerbestände nur für die beim Ersatzteil vorhandenen Lagercontroller initialisieren
      // Für neue Ersatzteile werden die Controller dynamisch erzeugt (siehe build-Methode oder submit)
      teil.lagerbestaende.forEach((lagerName, bestandEintrag) {
        _lagerbestandController[lagerName] = TextEditingController(text: bestandEintrag.menge.toString());
      });

      // Sicherstellen, dass für neue Ersatzteile, die Standard-Lagerbestände initialisiert werden
      if (!isEdit && _lagerbestandController.isEmpty) {
        teil.lagerbestaende.keys.forEach((lagerName) {
          _lagerbestandController[lagerName] = TextEditingController(text: '0');
        });
      }

    } else {
      // Wenn es ein neues Ersatzteil ist, initialisiere alle Standardlager mit '0'
      const defaultLagernamen = ['Hauptlager', 'Fahrzeug Patrick', 'Fahrzeug Melanie'];
      for (var lagerName in defaultLagernamen) {
        _lagerbestandController[lagerName] = TextEditingController(text: '0');
      }
    }
  }


  @override
  void dispose() {
    _artikelnummerController.dispose();
    _bezeichnungController.dispose();
    _herstellerController.dispose();
    _haendlerArtikelnummerController.dispose();
    _lieferantController.dispose();
    _preisController.dispose();
    _scancodeController.dispose();
    _lagerbestandController.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, LagerbestandEintrag> neueLagerbestaende = {};

      // Iteriere über alle Lagerbestand-Controller und erstelle die Lagerbestands-Objekte
      // Egal ob edit oder neu, wir nehmen die Werte aus den Textfeldern
      for (var entry in _lagerbestandController.entries) {
        final lagerName = entry.key;
        final controller = entry.value;
        final neueMenge = int.tryParse(controller.text) ?? 0; // Default auf 0, wenn ungültig

        // Wenn wir im Edit-Modus sind, vergleichen wir mit dem alten Wert für das Änderungsdatum
        Timestamp letzteAenderung = Timestamp.now();
        if (isEdit && widget.ersatzteil!.lagerbestaende.containsKey(lagerName)) {
          final alterEintrag = widget.ersatzteil!.lagerbestaende[lagerName]!;
          if (neueMenge == alterEintrag.menge) {
            letzteAenderung = alterEintrag.letzteAenderung; // Keine Änderung, altes Datum behalten
          }
        }
        neueLagerbestaende[lagerName] = LagerbestandEintrag(
          menge: neueMenge,
          letzteAenderung: letzteAenderung,
        );
      }


      final neuesTeil = Ersatzteil(
        id: isEdit ? widget.ersatzteil!.id : '',
        artikelnummer: _artikelnummerController.text.trim(),
        bezeichnung: _bezeichnungController.text.trim(),
        hersteller: _herstellerController.text.trim(),
        haendlerArtikelnummer: _haendlerArtikelnummerController.text.trim(),
        lieferant: _lieferantController.text.trim(),
        preis: double.tryParse(_preisController.text.replaceAll(',', '.')) ?? 0.0,
        kategorie: _selectedKategorie,
        lagerbestaende: neueLagerbestaende, // <-- Jetzt immer die neu erstellten Lagerbestaende
        scancode: _scancodeController.text.trim(),
      );

      if (isEdit) {
        await widget.onUpdate(neuesTeil);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${neuesTeil.bezeichnung} wurde aktualisiert.'), backgroundColor: Colors.green),
          );
        }
      } else {
        await widget.onAdd(neuesTeil);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${neuesTeil.bezeichnung} wurde hinzugefügt.'), backgroundColor: Colors.green),
          );
        }
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEdit ? 'Ersatzteil bearbeiten' : 'Neues Ersatzteil'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: _bezeichnungController, decoration: const InputDecoration(labelText: 'Bezeichnung*'), validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null),
              TextFormField(controller: _artikelnummerController, decoration: const InputDecoration(labelText: 'Artikelnummer*'), validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null),
              TextFormField(controller: _herstellerController, decoration: const InputDecoration(labelText: 'Hersteller')),
              TextFormField(controller: _haendlerArtikelnummerController, decoration: const InputDecoration(labelText: 'Händler-Artikelnummer')),
              TextFormField(controller: _lieferantController, decoration: const InputDecoration(labelText: 'Lieferant')),
              TextFormField(controller: _preisController, decoration: const InputDecoration(labelText: 'Preis*', suffixText: '€'), keyboardType: TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null),
              DropdownButtonFormField<String>(
                value: _selectedKategorie,
                decoration: const InputDecoration(labelText: 'Kategorie*'),
                items: verfuegbareKategorienErsatzteil.map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(), // <-- VERWENDET DIE GLOBALE LISTE
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedKategorie = value);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextFormField(controller: _scancodeController, decoration: const InputDecoration(labelText: 'Scancode (EAN/GTIN)')),

              if (isEdit || _lagerbestandController.isNotEmpty) ...[ // Zeigt Lagerbestände auch beim Hinzufügen, wenn Controller vorhanden sind
                const Divider(height: 24),
                Text('Lagerbestände', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ..._lagerbestandController.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextFormField(
                      controller: entry.value,
                      decoration: InputDecoration(labelText: entry.key, border: const OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Abbrechen')),
        ElevatedButton(onPressed: _submit, child: Text(isEdit ? 'Speichern' : 'Hinzufügen')),
      ],
    );
  }
}