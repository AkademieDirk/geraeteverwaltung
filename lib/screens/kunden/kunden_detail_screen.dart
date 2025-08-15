import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
// --- ANFANG DER KORREKTUR 1 ---
// Wir verwenden jetzt wieder den url_launcher, da er die zuverlässigste Methode bietet.
import 'package:url_launcher/url_launcher.dart';
// --- ENDE DER KORREKTUR 1 ---
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
    setState(() => _isUploading = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null && result.files.single.bytes != null) {
        final fileBytes = result.files.single.bytes!;
        final fileName = result.files.single.name;

        final storagePath = 'kunden_anhaenge/${widget.kunde.id}/${_uuid.v4()}-$fileName';
        final storageRef = FirebaseStorage.instance.ref().child(storagePath);

        await storageRef.putData(fileBytes);
        final downloadUrl = await storageRef.getDownloadURL();

        setState(() {
          final neueAnhaenge = List<Map<String, String>>.from(_aktuellerKunde.anhaenge);
          neueAnhaenge.add({
            'name': fileName,
            'url': downloadUrl,
          });
          _aktuellerKunde = _aktuellerKunde.copyWith(anhaenge: neueAnhaenge);
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler beim Upload: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // --- ANFANG DER KORREKTUR 2 ---
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konnte den Link nicht öffnen: $urlString'), backgroundColor: Colors.red),
        );
      }
    }
  }
  // --- ENDE DER KORREKTUR 2 ---

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

  void _standortDialog({Standort? standort}) { /* ... */ }
  void _deleteStandort(Standort standort) async { /* ... */ }
  void _addGeraetOhneStandort() { /* ... */ }

  @override
  Widget build(BuildContext context) {
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
              // ... Kundendaten Formular (unverändert)

              const Divider(height: 40),

              // ... Standorte Sektion (unverändert)

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
                      onTap: () => _launchURL(anhang['url']!),
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