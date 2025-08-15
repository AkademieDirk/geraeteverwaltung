import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:projekte/models/geraet.dart';
import 'package:projekte/models/ersatzteil.dart';
import 'package:projekte/models/verbautes_teil.dart';
import 'package:projekte/models/serviceeintrag.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceeintragScreen extends StatefulWidget {
  final Geraet geraet;
  final Serviceeintrag? initialEintrag;
  final List<Ersatzteil> alleErsatzteile;
  final Future<void> Function(Serviceeintrag) onSave;
  final Future<void> Function(String, Ersatzteil, String, int) onTeilVerbauen;

  const ServiceeintragScreen({
    Key? key,
    required this.geraet,
    this.initialEintrag,
    required this.alleErsatzteile,
    required this.onSave,
    required this.onTeilVerbauen,
  }) : super(key: key);

  @override
  _ServiceeintragScreenState createState() => _ServiceeintragScreenState();
}

class _ServiceeintragScreenState extends State<ServiceeintragScreen> {
  final _formKey = GlobalKey<FormState>();
  final _arbeitenController = TextEditingController();

  final List<String> _mitarbeiterOptionen = ['Nichts ausgewählt', 'Patrick Heidrich', 'Carsten Sobota', 'Melanie Toffel', 'Dirk Kraft'];
  String _selectedMitarbeiter = 'Nichts ausgewählt';
  DateTime _selectedDatum = DateTime.now();

  // --- KORRIGIERTE INITIALISIERUNG ---
  List<VerbautesTeil> _verbauteTeile = [];
  List<Map<String, String>> _anhaenge = [];

  final Uuid _uuid = const Uuid();
  bool _isUploading = false;

  bool get isEditMode => widget.initialEintrag != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final eintrag = widget.initialEintrag!;
      _arbeitenController.text = eintrag.ausgefuehrteArbeiten;
      _selectedMitarbeiter = _mitarbeiterOptionen.contains(eintrag.verantwortlicherMitarbeiter)
          ? eintrag.verantwortlicherMitarbeiter
          : 'Nichts ausgewählt';
      _selectedDatum = eintrag.datum.toDate();
      _verbauteTeile = List.from(eintrag.verbauteTeile);
      _anhaenge = List.from(eintrag.anhaenge);
    }
  }

  @override
  void dispose() {
    _arbeitenController.dispose();
    super.dispose();
  }

  // --- ANFANG DER NEUEN, ROBUSTEN UPLOAD-FUNKTION (DEIN VORSCHLAG) ---
  Future<void> _pickAndUploadFile() async {
    if (!mounted) return;
    setState(() => _isUploading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true, // <- WICHTIG: sorgt dafür, dass .bytes befüllt ist
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result == null) {
        if (mounted) setState(() => _isUploading = false);
        return; // User hat den Dialog abgebrochen
      }

      final platformFile = result.files.single;
      final Uint8List? fileBytes = platformFile.bytes;

      if (fileBytes == null) {
        throw StateError('Keine Datei-Bytes verfügbar. Der Upload wurde abgebrochen.');
      }

      final String fileName = platformFile.name;
      final String deviceId = widget.geraet.id.isNotEmpty ? widget.geraet.id : _uuid.v4();

      final storagePath = 'service_anhaenge/$deviceId/${_uuid.v4()}-$fileName';
      final storageRef = FirebaseStorage.instance.ref(storagePath);

      String? contentType;
      final lowerFileName = fileName.toLowerCase();
      if (lowerFileName.endsWith('.pdf')) contentType = 'application/pdf';
      if (lowerFileName.endsWith('.jpg') || lowerFileName.endsWith('.jpeg')) contentType = 'image/jpeg';
      if (lowerFileName.endsWith('.png')) contentType = 'image/png';

      await storageRef.putData(
        fileBytes,
        contentType != null ? SettableMetadata(contentType: contentType) : null,
      );
      final downloadUrl = await storageRef.getDownloadURL();

      if (!mounted) return;
      setState(() {
        _anhaenge.add({'name': fileName, 'url': downloadUrl});
      });

    } catch (e) {
      if (!mounted) return;
      debugPrint('Upload-Fehler: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Upload: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
  // --- ENDE DER NEUEN, ROBUSTEN UPLOAD-FUNKTION ---

  void _saveEintrag() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMitarbeiter == 'Nichts ausgewählt') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte einen Mitarbeiter auswählen.'), backgroundColor: Colors.red));
        return;
      }

      final neuerEintrag = Serviceeintrag(
        id: isEditMode ? widget.initialEintrag!.id : _uuid.v4(),
        geraeteId: widget.geraet.id,
        verantwortlicherMitarbeiter: _selectedMitarbeiter,
        datum: Timestamp.fromDate(_selectedDatum),
        ausgefuehrteArbeiten: _arbeitenController.text.trim(),
        verbauteTeile: _verbauteTeile,
        anhaenge: _anhaenge,
      );

      await widget.onSave(neuerEintrag);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDatum,
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDatum) {
      setState(() {
        _selectedDatum = picked;
      });
    }
  }

  void _showAddTeilDialog() {
    final Map<String, List<Ersatzteil>> groupedTeile = {};
    for (final teil in widget.alleErsatzteile) {
      final kategorie = teil.kategorie.isNotEmpty ? teil.kategorie : 'Sonstiges';
      (groupedTeile[kategorie] ??= []).add(teil);
    }
    final kategorien = groupedTeile.keys.toList()..sort();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Ersatzteil verbauen'),
          content: SizedBox(
            width: 500,
            height: 600,
            child: ListView.builder(
              itemCount: kategorien.length,
              itemBuilder: (context, index) {
                final kategorie = kategorien[index];
                final teileInKategorie = groupedTeile[kategorie]!;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ExpansionTile(
                    title: Text(kategorie, style: const TextStyle(fontWeight: FontWeight.bold)),
                    children: teileInKategorie.map((teil) {
                      return ListTile(
                        title: Text(teil.bezeichnung),
                        subtitle: Text('ArtNr: ${teil.artikelnummer} | Preis: ${teil.preis}€'),
                        onTap: () async {
                          Navigator.of(ctx).pop();
                          final lager = await _showLagerAuswahlDialog(teil);
                          if (lager != null) {
                            final menge = await _showMengenEingabeDialog(teil.lagerbestaende[lager] ?? 0);
                            if (menge != null && menge > 0) {
                              try {
                                await widget.onTeilVerbauen(widget.geraet.seriennummer, teil, lager, menge);

                                final verbautesTeil = VerbautesTeil(
                                  id: _uuid.v4(),
                                  ersatzteil: teil,
                                  installationsDatum: DateTime.now(),
                                  tatsaechlicherPreis: teil.preis * menge,
                                  herkunftslager: lager,
                                  menge: menge,
                                );

                                setState(() {
                                  _verbauteTeile.add(verbautesTeil);
                                });

                                if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$menge x ${teil.bezeichnung} wurde(n) hinzugefügt.'), backgroundColor: Colors.green));
                              } catch (e) {
                                if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: ${e.toString()}'), backgroundColor: Colors.red));
                              }
                            }
                          }
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Abbrechen')),
          ],
        );
      },
    );
  }

  Future<String?> _showLagerAuswahlDialog(Ersatzteil teil) {
    return showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Aus welchem Lager entnehmen?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: teil.lagerbestaende.keys.map((lager) {
                final bestand = teil.lagerbestaende[lager] ?? 0;
                return ListTile(
                  title: Text('$lager ($bestand Stk.)'),
                  onTap: () {
                    Navigator.of(context).pop(lager);
                  },
                  enabled: bestand > 0,
                );
              }).toList(),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Abbrechen')),
            ],
          );
        }
    );
  }

  Future<int?> _showMengenEingabeDialog(int maxMenge) {
    final controller = TextEditingController(text: '1');
    return showDialog<int>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Menge eingeben'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Anzahl',
                hintText: 'Maximal verfügbar: $maxMenge',
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Abbrechen')),
              ElevatedButton(
                onPressed: () {
                  final menge = int.tryParse(controller.text) ?? 0;
                  if (menge > 0 && menge <= maxMenge) {
                    Navigator.of(context).pop(menge);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ungültige Menge. Bitte eine Zahl zwischen 1 und $maxMenge eingeben.'), backgroundColor: Colors.red),
                    );
                  }
                },
                child: Text('Bestätigen'),
              ),
            ],
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Serviceeintrag bearbeiten' : 'Neuer Serviceeintrag'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEintrag,
            tooltip: 'Eintrag speichern',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Für Gerät: ${widget.geraet.modell} (SN: ${widget.geraet.seriennummer})', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedMitarbeiter,
                      decoration: const InputDecoration(labelText: 'Verantwortlicher Mitarbeiter*', border: OutlineInputBorder()),
                      items: _mitarbeiterOptionen.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) => setState(() => _selectedMitarbeiter = val ?? 'Nichts ausgewählt'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Colors.grey.shade400)),
                      title: Text("Datum: ${DateFormat('dd.MM.yyyy').format(_selectedDatum)}"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _arbeitenController,
                decoration: const InputDecoration(
                  labelText: 'Ausgeführte Arbeiten*',
                  hintText: 'Beschreiben Sie hier die durchgeführten Tätigkeiten...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                minLines: 5,
                maxLines: 10,
                validator: (value) => (value == null || value.isEmpty) ? 'Dieses Feld darf nicht leer sein.' : null,
              ),

              const Divider(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Anhänge', style: Theme.of(context).textTheme.titleLarge),
                  ElevatedButton.icon(
                    icon: _isUploading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))
                        : const Icon(Icons.attach_file),
                    label: const Text('Hochladen'),
                    onPressed: _isUploading ? null : _pickAndUploadFile,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _anhaenge.isEmpty
                  ? const Text('Noch keine Anhänge für diesen Eintrag hochgeladen.')
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _anhaenge.length,
                itemBuilder: (ctx, index) {
                  final anhang = _anhaenge[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                      title: Text(anhang['name']!, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _anhaenge.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),

              const Divider(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Verbaute Teile', style: Theme.of(context).textTheme.titleLarge),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Hinzufügen'),
                    onPressed: _showAddTeilDialog,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _verbauteTeile.isEmpty
                  ? const Text('Noch keine Teile für diesen Eintrag hinzugefügt.')
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _verbauteTeile.length,
                itemBuilder: (ctx, index) {
                  final teil = _verbauteTeile[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.settings),
                      title: Text('${teil.menge}x ${teil.ersatzteil.bezeichnung}'),
                      subtitle: Text('ArtNr: ${teil.ersatzteil.artikelnummer}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _verbauteTeile.removeAt(index);
                          });
                        },
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