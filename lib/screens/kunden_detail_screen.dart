import 'package:flutter/material.dart';
import '../models/kunde.dart';
import '../models/standort.dart';

class KundenDetailScreen extends StatefulWidget {
  final Kunde kunde;
  final List<Standort> alleStandorte;
  final Future<void> Function(Kunde) onUpdateKunde;
  final Future<void> Function(Standort) onAddStandort;
  final Future<void> Function(Standort) onUpdateStandort;
  final Future<void> Function(String) onDeleteStandort;

  const KundenDetailScreen({
    Key? key,
    required this.kunde,
    required this.alleStandorte,
    required this.onUpdateKunde,
    required this.onAddStandort,
    required this.onUpdateStandort,
    required this.onDeleteStandort,
  }) : super(key: key);

  @override
  State<KundenDetailScreen> createState() => _KundenDetailScreenState();
}

class _KundenDetailScreenState extends State<KundenDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nummerController;
  late TextEditingController _nameController;
  late TextEditingController _ansprechpartnerController;
  late TextEditingController _telefonController;
  late TextEditingController _emailController;
  // --- NEUE CONTROLLER ---
  late TextEditingController _strasseController;
  late TextEditingController _plzController;
  late TextEditingController _ortController;
  late TextEditingController _bemerkungController;

  late List<Standort> _kundenStandorte;

  @override
  void initState() {
    super.initState();
    _nummerController = TextEditingController(text: widget.kunde.kundennummer);
    _nameController = TextEditingController(text: widget.kunde.name);
    _ansprechpartnerController = TextEditingController(text: widget.kunde.ansprechpartner);
    _telefonController = TextEditingController(text: widget.kunde.telefon);
    _emailController = TextEditingController(text: widget.kunde.email);
    // --- NEUE CONTROLLER INITIALISIEREN ---
    _strasseController = TextEditingController(text: widget.kunde.strasse);
    _plzController = TextEditingController(text: widget.kunde.plz);
    _ortController = TextEditingController(text: widget.kunde.ort);
    _bemerkungController = TextEditingController(text: widget.kunde.bemerkung);

    _kundenStandorte = widget.alleStandorte.where((s) => s.kundeId == widget.kunde.id).toList();
  }

  @override
  void dispose() {
    _nummerController.dispose();
    _nameController.dispose();
    _ansprechpartnerController.dispose();
    _telefonController.dispose();
    _emailController.dispose();
    // --- NEUE CONTROLLER AUFRÄUMEN ---
    _strasseController.dispose();
    _plzController.dispose();
    _ortController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  void _saveKunde() async {
    if (_formKey.currentState!.validate()) {
      final aktualisierterKunde = Kunde(
        id: widget.kunde.id,
        kundennummer: _nummerController.text.trim(),
        name: _nameController.text.trim(),
        ansprechpartner: _ansprechpartnerController.text.trim(),
        telefon: _telefonController.text.trim(),
        email: _emailController.text.trim(),
        // --- NEUE DATEN ZUWEISEN ---
        strasse: _strasseController.text.trim(),
        plz: _plzController.text.trim(),
        ort: _ortController.text.trim(),
        bemerkung: _bemerkungController.text.trim(),
      );
      await widget.onUpdateKunde(aktualisierterKunde);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kundendaten gespeichert!'), backgroundColor: Colors.green));
      }
    }
  }

  void _standortDialog({Standort? standort}) {
    // Diese Funktion bleibt unverändert
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
    // Diese Funktion bleibt unverändert
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kunde.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveKunde,
            tooltip: 'Kundendaten speichern',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                        // --- NEUE FORMULARFELDER ---
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
                  ? const Text('Für diesen Kunden sind keine Standorte hinterlegt.')
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
            ],
          ),
        ),
      ),
    );
  }
}