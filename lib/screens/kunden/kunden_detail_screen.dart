import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;
import '../../models/geraet.dart';
import '../../models/kunde.dart';
import '../../models/standort.dart';
import '../geraeteaufnahme/geraeteaufnahme_screen.dart';

class KundenDetailScreen extends StatefulWidget {
  final Kunde kunde;
  final List<Standort> alleStandorte;
  final List<Geraet> alleGeraete;
  final Future<void> Function(Kunde) onUpdateKunde;
  final Future<void> Function(Standort) onAddStandort;
  final Future<void> Function(Standort) onUpdateStandort;
  final Future<void> Function(String) onDeleteStandort;
  final Future<void> Function(Geraet, Kunde, Standort) onAddGeraetForKunde;
  final Future<void> Function(Geraet, Kunde) onAddGeraetForKundeOhneStandort;
  final Future<void> Function(Geraet, Standort) assignStandortToGeraet;

  const KundenDetailScreen({
    Key? key,
    required this.kunde,
    required this.alleStandorte,
    required this.alleGeraete,
    required this.onUpdateKunde,
    required this.onAddStandort,
    required this.onUpdateStandort,
    required this.onDeleteStandort,
    required this.onAddGeraetForKunde,
    required this.onAddGeraetForKundeOhneStandort,
    required this.assignStandortToGeraet,
  }) : super(key: key);

  @override
  State<KundenDetailScreen> createState() => _KundenDetailScreenState();
}

class _KundenDetailScreenState extends State<KundenDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late Kunde _aktuellerKunde;
  late TextEditingController _nummerController;
  late TextEditingController _nameController;
  late TextEditingController _ansprechpartnerController;
  late TextEditingController _telefonController;
  late TextEditingController _emailController;
  late TextEditingController _strasseController;
  late TextEditingController _plzController;
  late TextEditingController _ortController;
  late TextEditingController _bemerkungController;
  late List<Standort> _kundenStandorte;

  bool _isUploading = false;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _aktuellerKunde = widget.kunde;

    _nummerController = TextEditingController(text: _aktuellerKunde.kundennummer);
    _nameController = TextEditingController(text: _aktuellerKunde.name);
    _ansprechpartnerController = TextEditingController(text: _aktuellerKunde.ansprechpartner);
    _telefonController = TextEditingController(text: _aktuellerKunde.telefon);
    _emailController = TextEditingController(text: _aktuellerKunde.email);
    _strasseController = TextEditingController(text: _aktuellerKunde.strasse);
    _plzController = TextEditingController(text: _aktuellerKunde.plz);
    _ortController = TextEditingController(text: _aktuellerKunde.ort);
    _bemerkungController = TextEditingController(text: _aktuellerKunde.bemerkung);
    _kundenStandorte = widget.alleStandorte.where((s) => s.kundeId == _aktuellerKunde.id).toList();
  }

  @override
  void dispose() {
    _nummerController.dispose();
    _nameController.dispose();
    _ansprechpartnerController.dispose();
    _telefonController.dispose();
    _emailController.dispose();
    _strasseController.dispose();
    _plzController.dispose();
    _ortController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFileForKunde() async {
    // Implementierung...
  }

  void _openInNewTab(String url) {
    html.window.open(url, '_blank');
  }

  void _saveKunde() async {
    if (_formKey.currentState!.validate()) {
      final aktualisierterKunde = _aktuellerKunde.copyWith(
        kundennummer: _nummerController.text.trim(),
        name: _nameController.text.trim(),
        ansprechpartner: _ansprechpartnerController.text.trim(),
        telefon: _telefonController.text.trim(),
        email: _emailController.text.trim(),
        strasse: _strasseController.text.trim(),
        plz: _plzController.text.trim(),
        ort: _ortController.text.trim(),
        bemerkung: _bemerkungController.text.trim(),
      );
      await widget.onUpdateKunde(aktualisierterKunde);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kundendaten gespeichert!'), backgroundColor: Colors.green));
    }
  }

  // --- ANFANG DER KORREKTUR ---
  void _standortDialog({Standort? standort}) {
    final isEdit = standort != null;
    final nameController = TextEditingController(text: isEdit ? standort.name : '');
    final strasseController = TextEditingController(text: isEdit ? standort.strasse : '');
    final plzController = TextEditingController(text: isEdit ? standort.plz : '');
    final ortController = TextEditingController(text: isEdit ? standort.ort : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Standort bearbeiten' : 'Neuer Standort'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name*')),
              TextField(controller: strasseController, decoration: const InputDecoration(labelText: 'Straße')),
              TextField(controller: plzController, decoration: const InputDecoration(labelText: 'PLZ')),
              TextField(controller: ortController, decoration: const InputDecoration(labelText: 'Ort')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final neuerStandort = Standort(
                id: isEdit ? standort.id : '',
                kundeId: widget.kunde.id,
                name: nameController.text.trim(),
                strasse: strasseController.text.trim(),
                plz: plzController.text.trim(),
                ort: ortController.text.trim(),
              );

              if (isEdit) {
                await widget.onUpdateStandort(neuerStandort);
              } else {
                await widget.onAddStandort(neuerStandort);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _deleteStandort(Standort standort) async {
    final sicher = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wirklich löschen?'),
        content: Text('Standort "${standort.name}" wirklich löschen?'),
        actions: [
          TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.pop(ctx, false)),
          TextButton(child: Text('Löschen', style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (sicher == true) {
      await widget.onDeleteStandort(standort.id);
    }
  }
  // --- ENDE DER KORREKTUR ---

  void _addGeraetOhneStandort() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => GeraeteAufnahmeScreen(
          alleGeraete: widget.alleGeraete,
          isBestandsgeraet: true,
          onSave: (neuesGeraet) async {
            await widget.onAddGeraetForKundeOhneStandort(neuesGeraet, widget.kunde);
          },
          onImport: (_) async {},
        ),
      ),
    );
  }

  void _showStandortZuweisungsDialog(Geraet geraet) {
    if (_kundenStandorte.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dieser Kunde hat keine Standorte. Bitte legen Sie zuerst einen an.'), backgroundColor: Colors.orange),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Standort auswählen'),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _kundenStandorte.length,
              itemBuilder: (context, index) {
                final standort = _kundenStandorte[index];
                return ListTile(
                  title: Text(standort.name),
                  onTap: () async {
                    await widget.assignStandortToGeraet(geraet, standort);
                    Navigator.of(ctx).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Abbrechen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final unzugeordneteGeraete = widget.alleGeraete
        .where((g) => g.kundeId == widget.kunde.id && (g.standortId == null || g.standortId!.isEmpty))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_aktuellerKunde.name),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveKunde,
        label: const Text('Änderungen speichern'),
        icon: const Icon(Icons.save),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kundendaten', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(controller: _nummerController, decoration: const InputDecoration(labelText: 'Kundennummer*'), validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null),
                        TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name*'), validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null),
                        TextFormField(controller: _ansprechpartnerController, decoration: const InputDecoration(labelText: 'Ansprechpartner')),
                        TextFormField(controller: _telefonController, decoration: const InputDecoration(labelText: 'Telefon')),
                        TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-Mail'), keyboardType: TextInputType.emailAddress),
                        const Divider(height: 20),
                        TextFormField(controller: _strasseController, decoration: const InputDecoration(labelText: 'Straße (Hauptsitz)')),
                        TextFormField(controller: _plzController, decoration: const InputDecoration(labelText: 'PLZ (Hauptsitz)')),
                        TextFormField(controller: _ortController, decoration: const InputDecoration(labelText: 'Ort (Hauptsitz)')),
                        const Divider(height: 20),
                        TextFormField(
                          controller: _bemerkungController,
                          decoration: const InputDecoration(labelText: 'Bemerkung', alignLabelWithHint: true, border: OutlineInputBorder()),
                          minLines: 3,
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Zugeordnete Geräte', style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 8),
              if (unzugeordneteGeraete.isEmpty)
                const Card(child: ListTile(title: Text('Alle Geräte sind einem Standort zugewiesen.')))
              else
                ...unzugeordneteGeraete.map((geraet) {
                  return Card(
                    color: Colors.amber.shade50,
                    child: ListTile(
                      leading: const Icon(Icons.print, color: Colors.orange),
                      title: Text(geraet.modell),
                      subtitle: Text('SN: ${geraet.seriennummer}'),
                      trailing: ElevatedButton(
                        child: const Text('Zuweisen'),
                        onPressed: () => _showStandortZuweisungsDialog(geraet),
                      ),
                    ),
                  );
                }),

              const Divider(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Standorte', style: Theme.of(context).textTheme.headlineSmall),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('Hinzufügen'),
                    onPressed: () => _standortDialog(),
                  )
                ],
              ),
              const SizedBox(height: 8),
              _kundenStandorte.isEmpty
                  ? const Card(child: ListTile(title: Text('Für diesen Kunden sind keine Standorte hinterlegt.')))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _kundenStandorte.length,
                itemBuilder: (ctx, index) {
                  final standort = _kundenStandorte[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(standort.name),
                      subtitle: Text('${standort.strasse}, ${standort.plz} ${standort.ort}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _standortDialog(standort: standort)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteStandort(standort)),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const Divider(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Anhänge', style: Theme.of(context).textTheme.headlineSmall),
                  ElevatedButton.icon(
                    icon: _isUploading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))
                        : const Icon(Icons.attach_file),
                    label: const Text('Hochladen'),
                    onPressed: _isUploading ? null : _pickAndUploadFileForKunde,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _aktuellerKunde.anhaenge.isEmpty
                  ? const Card(child: ListTile(title: Text('Für diesen Kunden sind keine Anhänge hinterlegt.')))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _aktuellerKunde.anhaenge.length,
                itemBuilder: (ctx, index) {
                  final anhang = _aktuellerKunde.anhaenge[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.description, color: Colors.blue),
                      title: Text(anhang['name']!, overflow: TextOverflow.ellipsis, style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
                      onTap: () => _openInNewTab(anhang['url']!),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            final anhaenge = List<Map<String, String>>.from(_aktuellerKunde.anhaenge);
                            anhaenge.removeAt(index);
                            _aktuellerKunde = _aktuellerKunde.copyWith(anhaenge: anhaenge);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),

              const Divider(height: 40),

              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.add_box),
                  label: const Text('Bestandsgerät für Kunde hinzufügen'),
                  onPressed: _addGeraetOhneStandort,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}