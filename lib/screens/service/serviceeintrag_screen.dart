import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/geraet.dart';
import '../../models/ersatzteil.dart';
import '../../models/verbautes_teil.dart';
import '../../models/serviceeintrag.dart';

class ServiceeintragScreen extends StatefulWidget {
  final Geraet geraet;
  final Serviceeintrag? initialEintrag;
  final List<Ersatzteil> alleErsatzteile;
  final Future<void> Function(Serviceeintrag) onSave;
  // --- KORRIGIERTE SIGNATUR ---
  final Future<void> Function(String, Ersatzteil, String) onTeilVerbauen;

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

  // --- WIEDERHERGESTELLT: Diese Liste speichert jetzt 'VerbautesTeil'-Objekte ---
  final List<VerbautesTeil> _verbauteTeile = [];
  final Uuid _uuid = const Uuid();

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
      // Lädt die Teile aus dem bestehenden Eintrag, um sie anzuzeigen
      setState(() {
        _verbauteTeile.addAll(eintrag.verbauteTeile);
      });
    }
  }

  @override
  void dispose() {
    _arbeitenController.dispose();
    super.dispose();
  }

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
        // Speichert die Liste der in diesem Service verbauten Teile
        verbauteTeile: _verbauteTeile,
      );

      await widget.onSave(neuerEintrag);
      Navigator.of(context).pop();
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
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                              final lager = await _showLagerAuswahlDialog(teil);
                              if (lager != null) {
                                try {
                                  // --- ANFANG DER KORREKTUR ---
                                  // Ruft die globale Funktion direkt mit dem Ersatzteil auf
                                  await widget.onTeilVerbauen(widget.geraet.seriennummer, teil, lager);

                                  // Fügt das Teil zur lokalen Liste für diesen Serviceeintrag hinzu
                                  setState(() {
                                    _verbauteTeile.add(VerbautesTeil(
                                      id: _uuid.v4(), // Wichtig für die spätere Identifizierung
                                      ersatzteil: teil,
                                      installationsDatum: DateTime.now(),
                                      tatsaechlicherPreis: teil.preis,
                                      herkunftslager: lager,
                                    ));
                                  });
                                  // --- ENDE DER KORREKTUR ---

                                  Navigator.of(ctx).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${teil.bezeichnung} wurde hinzugefügt.'), backgroundColor: Colors.green));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: ${e.toString()}'), backgroundColor: Colors.red));
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
                      title: Text(teil.ersatzteil.bezeichnung),
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