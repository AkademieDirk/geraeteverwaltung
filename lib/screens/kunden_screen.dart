import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:developer' as developer; // Für detailliertes Logging
import '../models/kunde.dart';
import '../models/standort.dart';
import 'standort_screen.dart';

class KundenScreen extends StatefulWidget {
  final List<Kunde> kunden;
  final List<Standort> standorte;
  final Future<void> Function(Kunde, Standort) onAdd;
  final Future<void> Function(Kunde) onUpdate;
  final Future<void> Function(String) onDelete;
  final Future<void> Function(Standort) onAddStandort;
  final Future<void> Function(Standort) onUpdateStandort;
  final Future<void> Function(String) onDeleteStandort;
  final Future<void> Function(List<Kunde>) onImport;

  const KundenScreen({
    Key? key,
    required this.kunden,
    required this.standorte,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
    required this.onAddStandort,
    required this.onUpdateStandort,
    required this.onDeleteStandort,
    required this.onImport,
  }) : super(key: key);

  @override
  State<KundenScreen> createState() => _KundenScreenState();
}

class _KundenScreenState extends State<KundenScreen> {
  bool _isImporting = false;

  Future<void> _importKunden() async {
    setState(() => _isImporting = true);
    developer.log("Import gestartet: Dateiauswahl wird geöffnet...", name: 'KundenImport');
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
      );

      if (result != null && result.files.single.bytes != null) {
        developer.log("Datei ausgewählt: ${result.files.single.name}", name: 'KundenImport');
        var bytes = result.files.single.bytes!;

        developer.log("Datei-Bytes werden dekodiert...", name: 'KundenImport');
        var excel = Excel.decodeBytes(bytes);

        if (excel.tables.keys.isEmpty) {
          throw Exception("Die ausgewählte Excel-Datei ist leer oder hat ein ungültiges Format.");
        }

        var sheetName = excel.tables.keys.first;
        var sheet = excel.tables[sheetName];

        if (sheet == null) {
          throw Exception("Konnte das Tabellenblatt '$sheetName' nicht finden.");
        }

        developer.log("Sheet '$sheetName' gefunden, verarbeite ${sheet.maxRows - 1} Zeilen...", name: 'KundenImport');
        List<Kunde> kundenToImport = [];

        for (var i = 1; i < sheet.maxRows; i++) { // Startet bei 1, um Header zu überspringen
          var row = sheet.row(i);

          if (row.length >= 2 && row[0]?.value != null && row[1]?.value != null) {
            final kunde = Kunde(
              kundennummer: row[0]!.value.toString().trim(),
              name: row[1]!.value.toString().trim(),
              ansprechpartner: row.length > 2 ? row[2]?.value.toString().trim() ?? '' : '',
              telefon: row.length > 3 ? row[3]?.value.toString().trim() ?? '' : '',
              email: row.length > 4 ? row[4]?.value.toString().trim() ?? '' : '',
            );
            kundenToImport.add(kunde);
          } else {
            developer.log("Zeile $i übersprungen, da Kundennummer oder Name fehlen.", name: 'KundenImport');
          }
        }

        if (kundenToImport.isNotEmpty) {
          developer.log("${kundenToImport.length} Kunden werden in die Datenbank importiert...", name: 'KundenImport');
          await widget.onImport(kundenToImport);
          developer.log("Import erfolgreich abgeschlossen.", name: 'KundenImport');
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${kundenToImport.length} Kunden erfolgreich importiert!'), backgroundColor: Colors.green),
            );
          }
        } else {
          developer.log("Keine gültigen Kunden in der Datei gefunden.", name: 'KundenImport');
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Keine gültigen Kunden in der Datei gefunden.'), backgroundColor: Colors.orange),
            );
          }
        }
      } else {
        developer.log("Dateiauswahl vom Benutzer abgebrochen.", name: 'KundenImport');
      }
    } catch (e) {
      developer.log("Ein Fehler ist während des Imports aufgetreten: $e", name: 'KundenImport', error: e);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Import: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  void _showKundenDialog({Kunde? kunde}) {
    showDialog(
      context: context,
      builder: (ctx) => KundenDialog(
        kunde: kunde,
        onAdd: widget.onAdd,
        onUpdate: widget.onUpdate,
      ),
    );
  }

  void _deleteKunde(Kunde kunde) async {
    final sicher = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wirklich löschen?'),
        content: Text('Kunde "${kunde.name}" wirklich löschen? Alle zugeordneten Standorte und Geräteverknüpfungen gehen verloren!'),
        actions: [
          TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.pop(ctx, false)),
          TextButton(child: Text('Löschen', style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (sicher == true) {
      await widget.onDelete(kunde.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kundenverwaltung'),
        actions: [
          _isImporting
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)),
          )
              : IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Kunden aus Excel importieren',
            onPressed: _importKunden,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: widget.kunden.length,
        itemBuilder: (context, index) {
          final kunde = widget.kunden[index];
          final kundenStandorte = widget.standorte.where((s) => s.kundeId == kunde.id).toList();

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ExpansionTile(
              leading: CircleAvatar(child: Icon(Icons.business)),
              title: Text(kunde.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('KNr: ${kunde.kundennummer}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.orange), tooltip: 'Stammdaten bearbeiten', onPressed: () => _showKundenDialog(kunde: kunde)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), tooltip: 'Kunden löschen', onPressed: () => _deleteKunde(kunde)),
                ],
              ),
              children: [
                const Divider(height: 1),
                _buildDetailRow(Icons.person_outline, 'Ansprechpartner', kunde.ansprechpartner),
                _buildDetailRow(Icons.phone_outlined, 'Telefon', kunde.telefon),
                _buildDetailRow(Icons.email_outlined, 'E-Mail', kunde.email),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.teal),
                  title: const Text('Standorte', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_location_alt_outlined, color: Colors.teal),
                    tooltip: 'Neuen Standort hinzufügen',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) =>
                          StandortScreen(
                            kunde: kunde,
                            alleStandorte: widget.standorte,
                            onAdd: widget.onAddStandort,
                            onUpdate: widget.onUpdateStandort,
                            onDelete: widget.onDeleteStandort,
                          )
                      ));
                    },
                  ),
                ),
                if (kundenStandorte.isNotEmpty)
                  ...kundenStandorte.map((standort) => Padding(
                    padding: const EdgeInsets.only(left: 72.0, right: 16, bottom: 8),
                    child: Text('${standort.name}: ${standort.strasse}, ${standort.plz} ${standort.ort}'),
                  ))
                else
                  const Padding(
                    padding: EdgeInsets.only(left: 72.0, right: 16, bottom: 8),
                    child: Text('Keine Standorte angelegt.', style: TextStyle(fontStyle: FontStyle.italic)),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showKundenDialog(),
        tooltip: 'Neuer Kunde',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(label),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
    );
  }
}


class KundenDialog extends StatefulWidget {
  final Kunde? kunde;
  final Future<void> Function(Kunde, Standort) onAdd;
  final Future<void> Function(Kunde) onUpdate;

  const KundenDialog({
    Key? key,
    this.kunde,
    required this.onAdd,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _KundenDialogState createState() => _KundenDialogState();
}

class _KundenDialogState extends State<KundenDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nummerController;
  late TextEditingController _nameController;
  late TextEditingController _ansprechpartnerController;
  late TextEditingController _telefonController;
  late TextEditingController _emailController;
  late TextEditingController _standortNameController;
  late TextEditingController _strasseController;
  late TextEditingController _plzController;
  late TextEditingController _ortController;

  bool get isEdit => widget.kunde != null;

  @override
  void initState() {
    super.initState();
    _nummerController = TextEditingController(text: widget.kunde?.kundennummer ?? '');
    _nameController = TextEditingController(text: widget.kunde?.name ?? '');
    _ansprechpartnerController = TextEditingController(text: widget.kunde?.ansprechpartner ?? '');
    _telefonController = TextEditingController(text: widget.kunde?.telefon ?? '');
    _emailController = TextEditingController(text: widget.kunde?.email ?? '');
    _standortNameController = TextEditingController();
    _strasseController = TextEditingController();
    _plzController = TextEditingController();
    _ortController = TextEditingController();
  }

  @override
  void dispose() {
    _nummerController.dispose();
    _nameController.dispose();
    _ansprechpartnerController.dispose();
    _telefonController.dispose();
    _emailController.dispose();
    _standortNameController.dispose();
    _strasseController.dispose();
    _plzController.dispose();
    _ortController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final nummer = _nummerController.text.trim();
      final name = _nameController.text.trim();
      final neuerKunde = Kunde(
        id: isEdit ? widget.kunde!.id : '',
        kundennummer: nummer,
        name: name,
        ansprechpartner: _ansprechpartnerController.text.trim(),
        telefon: _telefonController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (isEdit) {
        await widget.onUpdate(neuerKunde);
      } else {
        final standortName = _standortNameController.text.trim();
        if (standortName.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte einen Namen für den ersten Standort angeben!')));
          return;
        }
        final neuerStandort = Standort(
          kundeId: '',
          name: standortName,
          strasse: _strasseController.text.trim(),
          plz: _plzController.text.trim(),
          ort: _ortController.text.trim(),
        );
        await widget.onAdd(neuerKunde, neuerStandort);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEdit ? 'Kunde bearbeiten' : 'Neuen Kunden anlegen'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: _nummerController, decoration: const InputDecoration(labelText: 'Kundennummer*'), validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name*'), validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null),
              TextFormField(controller: _ansprechpartnerController, decoration: const InputDecoration(labelText: 'Ansprechpartner')),
              TextFormField(controller: _telefonController, decoration: const InputDecoration(labelText: 'Telefon')),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-Mail'), keyboardType: TextInputType.emailAddress),
              if (!isEdit) ...[
                const Divider(height: 32),
                Text("Erster Standort", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(controller: _standortNameController, decoration: const InputDecoration(labelText: 'Standort-Name*'), validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null),
                TextFormField(controller: _strasseController, decoration: const InputDecoration(labelText: 'Straße')),
                TextFormField(controller: _plzController, decoration: const InputDecoration(labelText: 'PLZ')),
                TextFormField(controller: _ortController, decoration: const InputDecoration(labelText: 'Ort')),
              ]
            ],
          ),
        ),
      ),
      actions: [
        TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.of(context).pop()),
        ElevatedButton(child: Text(isEdit ? 'Speichern' : 'Hinzufügen'), onPressed: _submit),
      ],
    );
  }
}
