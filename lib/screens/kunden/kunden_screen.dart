import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../../../models/geraet.dart';
import '../../../models/kunde.dart';
import '../../../models/standort.dart';
import 'kunden_detail_screen.dart';

class KundenScreen extends StatefulWidget {
  final List<Kunde> kunden;
  final List<Standort> standorte;
  final List<Geraet> alleGeraete;
  final Future<void> Function(Kunde, Standort) onAdd;
  final Future<void> Function(Kunde) onUpdate;
  final Future<void> Function(String) onDelete;
  final Future<void> Function(Standort) onAddStandort;
  final Future<void> Function(Standort) onUpdateStandort;
  final Future<void> Function(String) onDeleteStandort;
  final Future<void> Function(List<Kunde>) onImport;
  final Future<void> Function(Geraet, Kunde, Standort) onAddGeraetForKunde;
  // --- NEU ---
  final Future<void> Function(Geraet, Kunde) onAddGeraetForKundeOhneStandort;


  const KundenScreen({
    Key? key,
    required this.kunden,
    required this.standorte,
    required this.alleGeraete,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
    required this.onAddStandort,
    required this.onUpdateStandort,
    required this.onDeleteStandort,
    required this.onImport,
    required this.onAddGeraetForKunde,
    required this.onAddGeraetForKundeOhneStandort, // --- NEU ---
  }) : super(key: key);

  @override
  State<KundenScreen> createState() => _KundenScreenState();
}

class _KundenScreenState extends State<KundenScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String? _selectedLetter;
  bool _isImporting = false;

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

  Future<void> _importKunden() async {
    // Diese Funktion bleibt unverändert
    setState(() => _isImporting = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
      );

      if (result != null && result.files.single.bytes != null) {
        var bytes = result.files.single.bytes!;
        var excel = Excel.decodeBytes(bytes);
        if (excel.tables.keys.isEmpty) throw Exception("Die Excel-Datei enthält keine Tabellen.");

        List<Kunde> kundenToImport = [];
        var sheet = excel.tables[excel.tables.keys.first];
        for (var i = 1; i < sheet!.rows.length; i++) {
          var row = sheet.rows[i];
          if (row.length >= 2 &&
              row[0]?.value != null &&
              row[1]?.value != null &&
              row[0]!.value.toString().trim().isNotEmpty &&
              row[1]!.value.toString().trim().isNotEmpty) {
            kundenToImport.add(Kunde(
              kundennummer: row[0]!.value.toString().trim(),
              name: row[1]!.value.toString().trim(),
              ansprechpartner: row.length > 2 ? row[2]?.value?.toString().trim() ?? '' : '',
              telefon: row.length > 3 ? row[3]?.value?.toString().trim() ?? '' : '',
              email: row.length > 4 ? row[4]?.value?.toString().trim() ?? '' : '',
              strasse: row.length > 5 ? row[5]?.value?.toString().trim() ?? '' : '',
              plz: row.length > 6 ? row[6]?.value?.toString().trim() ?? '' : '',
              ort: row.length > 7 ? row[7]?.value?.toString().trim() ?? '' : '',
            ));
          }
        }

        if (kundenToImport.isNotEmpty) {
          await widget.onImport(kundenToImport);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${kundenToImport.length} Kunden erfolgreich importiert!'), backgroundColor: Colors.green));
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keine gültigen Kunden gefunden.'), backgroundColor: Colors.orange));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler beim Import: ${e.toString()}'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _kundenAnlegenDialog() {
    showDialog(
      context: context,
      builder: (ctx) => KundenAnlegenDialog(
        onAdd: widget.onAdd,
      ),
    );
  }

  void _deleteKunde(Kunde kunde) async {
    final sicher = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wirklich löschen?'),
        content: Text('Soll der Kunde "${kunde.name}" und alle zugehörigen Standorte wirklich gelöscht werden?'),
        actions: [
          TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.pop(ctx, false)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Löschen'),
              onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (sicher == true) {
      await widget.onDelete(kunde.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Kunde> gefilterteKunden = List.from(widget.kunden);

    if (_selectedLetter != null) {
      gefilterteKunden = gefilterteKunden.where((k) => k.name.toUpperCase().startsWith(_selectedLetter!)).toList();
    }
    if (_searchTerm.isNotEmpty) {
      gefilterteKunden = gefilterteKunden.where((k) {
        final s = _searchTerm.toLowerCase();
        return k.name.toLowerCase().contains(s) || k.kundennummer.toLowerCase().contains(s);
      }).toList();
    }

    gefilterteKunden.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kundenverwaltung'),
        actions: [
          _isImporting
              ? const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)))
              : IconButton(icon: const Icon(Icons.upload_file), onPressed: _importKunden, tooltip: 'Kunden importieren'),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Suche nach Name oder Kundennummer',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchTerm.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear()) : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                _buildAlphabetScroller(),
              ],
            ),
          ),
          Expanded(
            child: gefilterteKunden.isEmpty
                ? const Center(child: Text('Keine passenden Kunden gefunden.'))
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: gefilterteKunden.length,
              itemBuilder: (ctx, index) {
                final kunde = gefilterteKunden[index];
                final kundenStandorte = widget.standorte.where((s) => s.kundeId == kunde.id).toList();
                return Card(
                  child: ExpansionTile(
                    title: Text(kunde.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('KNr: ${kunde.kundennummer} | ${kunde.ort.isNotEmpty ? kunde.ort : 'Kein Hauptsitz'}'),
                    leading: CircleAvatar(child: Text(kunde.name.substring(0, 1).toUpperCase())),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => KundenDetailScreen(
                                kunde: kunde,
                                alleStandorte: widget.standorte,
                                alleGeraete: widget.alleGeraete,
                                onUpdateKunde: widget.onUpdate,
                                onAddStandort: widget.onAddStandort,
                                onUpdateStandort: widget.onUpdateStandort,
                                onDeleteStandort: widget.onDeleteStandort,
                                onAddGeraetForKunde: widget.onAddGeraetForKunde,
                                onAddGeraetForKundeOhneStandort: widget.onAddGeraetForKundeOhneStandort, // --- NEU ---
                              ),
                            ),
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteKunde(kunde)),
                      ],
                    ),
                    children: kundenStandorte.map((standort) {
                      return ListTile(
                        leading: const Icon(Icons.location_city, color: Colors.grey),
                        title: Text(standort.name),
                        subtitle: Text('${standort.strasse}, ${standort.plz} ${standort.ort}'),
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
        onPressed: () => _kundenAnlegenDialog(),
        tooltip: 'Neuer Kunde',
      ),
    );
  }

  Widget _buildAlphabetScroller() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split('').map((letter) {
          final isSelected = _selectedLetter == letter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ActionChip(
              label: Text(letter),
              backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
              onPressed: () {
                setState(() {
                  _selectedLetter = isSelected ? null : letter;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class KundenAnlegenDialog extends StatefulWidget {
  final Future<void> Function(Kunde, Standort) onAdd;

  const KundenAnlegenDialog({ Key? key, required this.onAdd,}) : super(key: key);

  @override
  _KundenAnlegenDialogState createState() => _KundenAnlegenDialogState();
}

class _KundenAnlegenDialogState extends State<KundenAnlegenDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nummerController = TextEditingController();
  final _nameController = TextEditingController();
  final _ansprechpartnerController = TextEditingController();
  final _telefonController = TextEditingController();
  final _emailController = TextEditingController();
  final _kundeStrasseController = TextEditingController();
  final _kundePlzController = TextEditingController();
  final _kundeOrtController = TextEditingController();
  final _kundeBemerkungController = TextEditingController();

  final _standortNameController = TextEditingController();
  final _standortStrasseController = TextEditingController();
  final _standortPlzController = TextEditingController();
  final _standortOrtController = TextEditingController();

  @override
  void dispose() {
    _nummerController.dispose();
    _nameController.dispose();
    _ansprechpartnerController.dispose();
    _telefonController.dispose();
    _emailController.dispose();
    _kundeStrasseController.dispose();
    _kundePlzController.dispose();
    _kundeOrtController.dispose();
    _kundeBemerkungController.dispose();
    _standortNameController.dispose();
    _standortStrasseController.dispose();
    _standortPlzController.dispose();
    _standortOrtController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final neuerKunde = Kunde(
        kundennummer: _nummerController.text.trim(),
        name: _nameController.text.trim(),
        ansprechpartner: _ansprechpartnerController.text.trim(),
        telefon: _telefonController.text.trim(),
        email: _emailController.text.trim(),
        strasse: _kundeStrasseController.text.trim(),
        plz: _kundePlzController.text.trim(),
        ort: _kundeOrtController.text.trim(),
        bemerkung: _kundeBemerkungController.text.trim(),
      );

      if (_standortNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte einen Namen für den ersten Standort angeben!')));
        return;
      }

      final neuerStandort = Standort(
        kundeId: '',
        name: _standortNameController.text.trim(),
        strasse: _standortStrasseController.text.trim(),
        plz: _standortPlzController.text.trim(),
        ort: _standortOrtController.text.trim(),
      );

      await widget.onAdd(neuerKunde, neuerStandort);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Neuen Kunden anlegen'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Kundendaten", style: Theme.of(context).textTheme.titleMedium),
              TextFormField(controller: _nummerController, decoration: const InputDecoration(labelText: 'Kundennummer*'), validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name*'), validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null),
              TextFormField(controller: _ansprechpartnerController, decoration: const InputDecoration(labelText: 'Ansprechpartner')),
              TextFormField(controller: _telefonController, decoration: const InputDecoration(labelText: 'Telefon')),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-Mail'), keyboardType: TextInputType.emailAddress),
              TextFormField(controller: _kundeStrasseController, decoration: const InputDecoration(labelText: 'Straße (Hauptsitz)')),
              TextFormField(controller: _kundePlzController, decoration: const InputDecoration(labelText: 'PLZ (Hauptsitz)')),
              TextFormField(controller: _kundeOrtController, decoration: const InputDecoration(labelText: 'Ort (Hauptsitz)')),
              const SizedBox(height: 8),
              TextFormField(controller: _kundeBemerkungController, decoration: const InputDecoration(labelText: 'Bemerkung', border: OutlineInputBorder()), minLines: 2, maxLines: 3),
              const Divider(height: 32),
              Text("Erster Standort", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(controller: _standortNameController, decoration: const InputDecoration(labelText: 'Standort-Name*'), validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null),
              TextFormField(controller: _standortStrasseController, decoration: const InputDecoration(labelText: 'Straße')),
              TextFormField(controller: _standortPlzController, decoration: const InputDecoration(labelText: 'PLZ')),
              TextFormField(controller: _standortOrtController, decoration: const InputDecoration(labelText: 'Ort')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.of(context).pop()),
        ElevatedButton(child: const Text('Hinzufügen'), onPressed: _submit),
      ],
    );
  }
}