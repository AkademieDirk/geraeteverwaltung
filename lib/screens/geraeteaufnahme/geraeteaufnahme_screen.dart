import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../../models/geraet.dart';
import '../../widgets/prozent_dropdown.dart';
import '../../widgets/zubehoer_eingabe_zeile.dart';
import '../../widgets/zaehlerstaende_eingabe.dart';
import '../../widgets/testergebnisse_eingabe.dart';

class GeraeteAufnahmeScreen extends StatefulWidget {
  final Geraet? initialGeraet;
  final Future<void> Function(Geraet) onSave;
  final Future<void> Function(List<Geraet>) onImport;

  const GeraeteAufnahmeScreen({
    Key? key,
    this.initialGeraet,
    required this.onSave,
    required this.onImport,
  }) : super(key: key);

  @override
  State<GeraeteAufnahmeScreen> createState() => _GeraeteAufnahmeScreenState();
}

class _GeraeteAufnahmeScreenState extends State<GeraeteAufnahmeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isImporting = false;

  // Dropdown-Optionen
  final List<String> _modellOptionen = [
    'Nichts ausgewählt', 'bizhub C250i', 'bizhub C251i', 'bizhub C257i', 'bizhub C300i', 'bizhub C301i', 'bizhub C360i', 'bizhub C361i', 'bizhub C451i', 'bizhub C551i', 'bizhub C651i', 'bizhub C751i', 'bizhub C258', 'bizhub C308', 'bizhub C368', 'bizhub C458', 'bizhub C558', 'bizhub C658', 'bizhub C224e', 'bizhub C284e', 'bizhub C364e', 'bizhub C454e', 'bizhub C554e', 'bizhub C3301i', 'bizhub C3321i', 'bizhub C3351i', 'bizhub C4051i', 'bizhub C3350i', 'bizhub C3851', 'bizhub C3351', 'bizhub C3851FS', 'bizhub 227', 'bizhub 287', 'bizhub 367', 'bizhub 301i', 'bizhub 361i', 'bizhub 451i', 'bizhub 551i', 'bizhub 651i', 'bizhub 751i', 'bizhub 4000i', 'bizhub 4051i', 'bizhub 4701i', 'bizhub 4751i', 'bizhub 4052', 'bizhub 4702p', 'bizhub 4752', 'andere'
  ];
  final List<String> _mitarbeiterOptionen = ['Nichts ausgewählt', 'Patrick Heidrich', 'Carsten Sobota', 'Melanie Toffel', 'Dirk Kraft'];
  final List<String> _jaNeinOptionen = ['Nichts ausgewählt', 'Ja', 'Nein'];
  final List<String> _pdfTypen = ['Nichts ausgewählt', 'A / B'];
  final List<String> _originaleinzugTypOptionen = ['Nichts ausgewählt', 'Kein', 'DF-714', 'DF-715', 'DF-632', 'DF-633', 'Sonstiges'];
  final List<String> _unterschrankTypOptionen = ['Nichts ausgewählt', 'Kein', 'PC-116', 'PC-216', 'PC-416', 'Sonstiges'];
  final List<String> _finisherOptionen = ['Nichts ausgewählt', 'Kein', 'FS-533', 'FS-539', 'FS-532', 'Sonstiges'];

  // Controller und Felder
  final _nummerController = TextEditingController();
  final _seriennummerController = TextEditingController();
  String _selectedMitarbeiter = 'Nichts ausgewählt';
  String _selectedModell = 'Nichts ausgewählt';
  DateTime? _selectedAufnahmeDatum;
  final _lieferantController = TextEditingController();
  String _selectedIOption = 'Nichts ausgewählt';
  String _selectedPdfTyp = 'Nichts ausgewählt';
  String _selectedDurchsuchbar = 'Nichts ausgewählt';
  String _selectedOcr = 'Nichts ausgewählt';
  String _selectedOriginaleinzugTyp = 'Nichts ausgewählt';
  final _originaleinzugSNController = TextEditingController();
  String _selectedUnterschrankTyp = 'Nichts ausgewählt';
  final _unterschrankSNController = TextEditingController();
  String _selectedFinisher = 'Nichts ausgewählt';
  final _finisherSNController = TextEditingController();
  String _selectedFax = 'Nichts ausgewählt';
  final _faxSNController = TextEditingController();
  final _zaehlerGesamtController = TextEditingController();
  final _zaehlerSWController = TextEditingController();
  final _zaehlerColorController = TextEditingController();
  int _rtb = 0, _tonerK = 0, _tonerC = 0, _tonerM = 0, _tonerY = 0;
  int _laufzeitBildeinheitK = 0, _laufzeitBildeinheitC = 0, _laufzeitBildeinheitM = 0, _laufzeitBildeinheitY = 0;
  int _laufzeitEntwicklerK = 0, _laufzeitEntwicklerC = 0, _laufzeitEntwicklerM = 0, _laufzeitEntwicklerY = 0;
  int _laufzeitFixiereinheit = 0, _laufzeitTransferbelt = 0;
  final _fach1Controller = TextEditingController();
  final _fach2Controller = TextEditingController();
  final _fach3Controller = TextEditingController();
  final _fach4Controller = TextEditingController();
  final _bypassController = TextEditingController();
  final _dokumenteneinzugController = TextEditingController();
  final _duplexController = TextEditingController();
  final _bemerkungController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialGeraet != null) {
      final g = widget.initialGeraet!;
      _nummerController.text = g.nummer;
      _selectedMitarbeiter = _mitarbeiterOptionen.contains(g.mitarbeiter) ? g.mitarbeiter : 'Nichts ausgewählt';
      _selectedAufnahmeDatum = g.aufnahmeDatum?.toDate();
      _lieferantController.text = g.lieferant;
      _selectedModell = _modellOptionen.contains(g.modell) ? g.modell : 'Nichts ausgewählt';
      _seriennummerController.text = g.seriennummer;
      _selectedIOption = _jaNeinOptionen.contains(g.iOption) ? g.iOption : 'Nichts ausgewählt';
      _selectedPdfTyp = _pdfTypen.contains(g.pdfTyp) ? g.pdfTyp : 'Nichts ausgewählt';
      _selectedDurchsuchbar = _jaNeinOptionen.contains(g.durchsuchbar) ? g.durchsuchbar : 'Nichts ausgewählt';
      _selectedOcr = _jaNeinOptionen.contains(g.ocr) ? g.ocr : 'Nichts ausgewählt';
      _selectedOriginaleinzugTyp = _originaleinzugTypOptionen.contains(g.originaleinzugTyp) ? g.originaleinzugTyp : 'Nichts ausgewählt';
      _originaleinzugSNController.text = g.originaleinzugSN;
      _selectedUnterschrankTyp = _unterschrankTypOptionen.contains(g.unterschrankTyp) ? g.unterschrankTyp : 'Nichts ausgewählt';
      _unterschrankSNController.text = g.unterschrankSN;
      _selectedFinisher = _finisherOptionen.contains(g.finisher) ? g.finisher : 'Nichts ausgewählt';
      _finisherSNController.text = g.finisherSN;
      _selectedFax = _jaNeinOptionen.contains(g.fax) ? g.fax : 'Nichts ausgewählt';
      _faxSNController.text = g.faxSN;
      _zaehlerGesamtController.text = g.zaehlerGesamt;
      _zaehlerSWController.text = g.zaehlerSW;
      _zaehlerColorController.text = g.zaehlerColor;
      _rtb = int.tryParse(g.rtb) ?? 0;
      _tonerK = int.tryParse(g.tonerK) ?? 0;
      _tonerC = int.tryParse(g.tonerC) ?? 0;
      _tonerM = int.tryParse(g.tonerM) ?? 0;
      _tonerY = int.tryParse(g.tonerY) ?? 0;
      _laufzeitBildeinheitK = int.tryParse(g.laufzeitBildeinheitK) ?? 0;
      _laufzeitBildeinheitC = int.tryParse(g.laufzeitBildeinheitC) ?? 0;
      _laufzeitBildeinheitM = int.tryParse(g.laufzeitBildeinheitM) ?? 0;
      _laufzeitBildeinheitY = int.tryParse(g.laufzeitBildeinheitY) ?? 0;
      _laufzeitEntwicklerK = int.tryParse(g.laufzeitEntwicklerK) ?? 0;
      _laufzeitEntwicklerC = int.tryParse(g.laufzeitEntwicklerC) ?? 0;
      _laufzeitEntwicklerM = int.tryParse(g.laufzeitEntwicklerM) ?? 0;
      _laufzeitEntwicklerY = int.tryParse(g.laufzeitEntwicklerY) ?? 0;
      _laufzeitFixiereinheit = int.tryParse(g.laufzeitFixiereinheit) ?? 0;
      _laufzeitTransferbelt = int.tryParse(g.laufzeitTransferbelt) ?? 0;
      _fach1Controller.text = g.fach1;
      _fach2Controller.text = g.fach2;
      _fach3Controller.text = g.fach3;
      _fach4Controller.text = g.fach4;
      _bypassController.text = g.bypass;
      _dokumenteneinzugController.text = g.dokumenteneinzug;
      _duplexController.text = g.duplex;
      _bemerkungController.text = g.bemerkung;
    } else {
      _selectedAufnahmeDatum = DateTime.now();
    }
  }

  @override
  void dispose() {
    // ... dispose all controllers ...
    super.dispose();
  }

  Future<void> _importGeraete() async {
    // ... import logic ...
  }

  void _updateZaehlerGesamt() {
    setState(() {
      final sw = int.tryParse(_zaehlerSWController.text) ?? 0;
      final color = int.tryParse(_zaehlerColorController.text) ?? 0;
      _zaehlerGesamtController.text = (sw + color).toString();
    });
  }

  void _saveGeraet() async {
    if (_nummerController.text.trim().isEmpty || _selectedModell == 'Nichts ausgewählt') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte Gerätenummer und Modell angeben!')));
      return;
    }

    String clean(String val) => val == 'Nichts ausgewählt' ? '' : val;

    final neuesGeraet = Geraet(
      id: widget.initialGeraet?.id ?? '',
      nummer: _nummerController.text.trim(),
      modell: clean(_selectedModell),
      seriennummer: _seriennummerController.text.trim(),
      mitarbeiter: clean(_selectedMitarbeiter),
      aufnahmeDatum: _selectedAufnahmeDatum != null ? Timestamp.fromDate(_selectedAufnahmeDatum!) : null,
      lieferant: _lieferantController.text.trim(),
      iOption: clean(_selectedIOption),
      pdfTyp: clean(_selectedPdfTyp),
      durchsuchbar: clean(_selectedDurchsuchbar),
      ocr: clean(_selectedOcr),
      originaleinzugTyp: clean(_selectedOriginaleinzugTyp),
      originaleinzugSN: _originaleinzugSNController.text.trim(),
      unterschrankTyp: clean(_selectedUnterschrankTyp),
      unterschrankSN: _unterschrankSNController.text.trim(),
      finisher: clean(_selectedFinisher),
      finisherSN: _finisherSNController.text.trim(),
      fax: clean(_selectedFax),
      faxSN: _faxSNController.text.trim(),
      zaehlerGesamt: _zaehlerGesamtController.text,
      zaehlerSW: _zaehlerSWController.text,
      zaehlerColor: _zaehlerColorController.text,
      rtb: _rtb.toString(),
      tonerK: _tonerK.toString(),
      tonerC: _tonerC.toString(),
      tonerM: _tonerM.toString(),
      tonerY: _tonerY.toString(),
      laufzeitBildeinheitK: _laufzeitBildeinheitK.toString(),
      laufzeitBildeinheitC: _laufzeitBildeinheitC.toString(),
      laufzeitBildeinheitM: _laufzeitBildeinheitM.toString(),
      laufzeitBildeinheitY: _laufzeitBildeinheitY.toString(),
      laufzeitEntwicklerK: _laufzeitEntwicklerK.toString(),
      laufzeitEntwicklerC: _laufzeitEntwicklerC.toString(),
      laufzeitEntwicklerM: _laufzeitEntwicklerM.toString(),
      laufzeitEntwicklerY: _laufzeitEntwicklerY.toString(),
      laufzeitFixiereinheit: _laufzeitFixiereinheit.toString(),
      laufzeitTransferbelt: _laufzeitTransferbelt.toString(),
      fach1: _fach1Controller.text.trim(),
      fach2: _fach2Controller.text.trim(),
      fach3: _fach3Controller.text.trim(),
      fach4: _fach4Controller.text.trim(),
      bypass: _bypassController.text.trim(),
      dokumenteneinzug: _dokumenteneinzugController.text.trim(),
      duplex: _duplexController.text.trim(),
      bemerkung: _bemerkungController.text.trim(),
    );

    await widget.onSave(neuesGeraet);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gerät erfolgreich gespeichert!')));
    Navigator.of(context).pop();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedAufnahmeDatum ?? DateTime.now(), firstDate: DateTime(2010), lastDate: DateTime(2100));
    if (picked != null && picked != _selectedAufnahmeDatum) {
      setState(() {
        _selectedAufnahmeDatum = picked;
      });
    }
  }

  // --- NEU: Hilfs-Widget für die Auswahl-Chips ---
  Widget _buildChoiceChipRow(String label, String groupValue, ValueChanged<String> onSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          Row(
            children: [
              ChoiceChip(
                label: Text('Ja'),
                selected: groupValue == 'Ja',
                onSelected: (selected) { if(selected) onSelected('Ja'); },
                selectedColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(color: groupValue == 'Ja' ? Colors.white : Colors.black),
              ),
              SizedBox(width: 8),
              ChoiceChip(
                label: Text('Nein'),
                selected: groupValue == 'Nein',
                onSelected: (selected) { if(selected) onSelected('Nein'); },
                selectedColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(color: groupValue == 'Nein' ? Colors.white : Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool showFinisherSN = _selectedFinisher != 'Nichts ausgewählt' && _selectedFinisher != 'Kein';
    bool showFaxSN = _selectedFax == 'Ja';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialGeraet == null ? 'Neues Gerät anlegen' : 'Gerät bearbeiten'),
        actions: [
          _isImporting
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)),
          )
              : IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Geräte aus Excel importieren',
            onPressed: _importGeraete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nummerController, decoration: const InputDecoration(labelText: 'Gerätenummer*')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(value: _selectedMitarbeiter, decoration: const InputDecoration(labelText: 'Verantwortlicher Mitarbeiter'), items: _mitarbeiterOptionen.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (val) => setState(() => _selectedMitarbeiter = val ?? 'Nichts ausgewählt')),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Aufnahmedatum: ${DateFormat('dd.MM.yyyy').format(_selectedAufnahmeDatum ?? DateTime.now())}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              TextFormField(controller: _lieferantController, decoration: const InputDecoration(labelText: 'Lieferant')),
              const Divider(height: 32),

              DropdownButtonFormField<String>(value: _selectedModell, decoration: const InputDecoration(labelText: 'Modell*'), items: _modellOptionen.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (val) => setState(() => _selectedModell = val ?? 'Nichts ausgewählt')),
              TextFormField(controller: _seriennummerController, decoration: const InputDecoration(labelText: 'Seriennummer')),

              // --- ANFANG DER ÄNDERUNG: Dropdowns durch ChoiceChips ersetzt ---
              _buildChoiceChipRow('I-Option', _selectedIOption, (val) => setState(() => _selectedIOption = val)),
              DropdownButtonFormField<String>(value: _selectedPdfTyp, decoration: const InputDecoration(labelText: 'PDF Typ'), items: _pdfTypen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (val) => setState(() => _selectedPdfTyp = val ?? 'Nichts ausgewählt')),
              _buildChoiceChipRow('Durchsuchbar', _selectedDurchsuchbar, (val) => setState(() => _selectedDurchsuchbar = val)),
              _buildChoiceChipRow('OCR', _selectedOcr, (val) => setState(() => _selectedOcr = val)),
              // --- ENDE DER ÄNDERUNG ---

              const SizedBox(height: 22),

              const Text('Zubehör:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ZubehoerEingabeZeile(label: 'Originaleinzug Typ', selectedValue: _selectedOriginaleinzugTyp, options: _originaleinzugTypOptionen, snController: _originaleinzugSNController, onChanged: (val) => setState(() => _selectedOriginaleinzugTyp = val ?? 'Nichts ausgewählt')),
              ZubehoerEingabeZeile(label: 'Unterschrank Typ', selectedValue: _selectedUnterschrankTyp, options: _unterschrankTypOptionen, snController: _unterschrankSNController, onChanged: (val) => setState(() => _selectedUnterschrankTyp = val ?? 'Nichts ausgewählt')),
              ZubehoerEingabeZeile(label: 'Finisher', selectedValue: _selectedFinisher, options: _finisherOptionen, snController: _finisherSNController, onChanged: (val) => setState(() => _selectedFinisher = val ?? 'Nichts ausgewählt'), showSnField: showFinisherSN),
              ZubehoerEingabeZeile(label: 'Fax', selectedValue: _selectedFax, options: _jaNeinOptionen, snController: _faxSNController, onChanged: (val) => setState(() => _selectedFax = val ?? 'Nichts ausgewählt'), showSnField: showFaxSN),

              const SizedBox(height: 22),
              const Text('Zählerstände:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ZaehlerstaendeEingabe(swController: _zaehlerSWController, colorController: _zaehlerColorController, gesamtController: _zaehlerGesamtController, onUpdate: _updateZaehlerGesamt),

              const SizedBox(height: 22),

              const Text('Füllstände (in %):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Row(children: [ProzentDropdown(label: 'RTB', value: _rtb, onChanged: (val) => setState(() => _rtb = val ?? 0)), const SizedBox(width: 8), ProzentDropdown(label: 'Toner K', value: _tonerK, onChanged: (val) => setState(() => _tonerK = val ?? 0)), const SizedBox(width: 8), ProzentDropdown(label: 'Toner C', value: _tonerC, onChanged: (val) => setState(() => _tonerC = val ?? 0)), const SizedBox(width: 8), ProzentDropdown(label: 'Toner M', value: _tonerM, onChanged: (val) => setState(() => _tonerM = val ?? 0)), const SizedBox(width: 8), ProzentDropdown(label: 'Toner Y', value: _tonerY, onChanged: (val) => setState(() => _tonerY = val ?? 0))]),

              const SizedBox(height: 22),
              const Text('Laufzeiten Bildeinheit (jeweils %):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(children: [ProzentDropdown(label: 'K', value: _laufzeitBildeinheitK, onChanged: (val) => setState(() => _laufzeitBildeinheitK = val ?? 0)), const SizedBox(width: 8), ProzentDropdown(label: 'C', value: _laufzeitBildeinheitC, onChanged: (val) => setState(() => _laufzeitBildeinheitC = val ?? 0)), const SizedBox(width: 8), ProzentDropdown(label: 'M', value: _laufzeitBildeinheitM, onChanged: (val) => setState(() => _laufzeitBildeinheitM = val ?? 0)), const SizedBox(width: 8), ProzentDropdown(label: 'Y', value: _laufzeitBildeinheitY, onChanged: (val) => setState(() => _laufzeitBildeinheitY = val ?? 0))]),

              const SizedBox(height: 22),
              const Text('Laufzeiten Entwickler (jeweils %):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(children: [ProzentDropdown(label: 'K', value: _laufzeitEntwicklerK, onChanged: (val) => setState(() => _laufzeitEntwicklerK = val ?? 0)), const SizedBox(width: 8), ProzentDropdown(label: 'C', value: _laufzeitEntwicklerC, onChanged: (val) => setState(() => _laufzeitEntwicklerC = val ?? 0)), const SizedBox(width: 8), ProzentDropdown(label: 'M', value: _laufzeitEntwicklerM, onChanged: (val) => setState(() => _laufzeitEntwicklerM = val ?? 0)), const SizedBox(width: 8), ProzentDropdown(label: 'Y', value: _laufzeitEntwicklerY, onChanged: (val) => setState(() => _laufzeitEntwicklerY = val ?? 0))]),

              const SizedBox(height: 22),
              Row(children: [ProzentDropdown(label: 'Fixiereinheit', value: _laufzeitFixiereinheit, onChanged: (val) => setState(() => _laufzeitFixiereinheit = val ?? 0)), const SizedBox(width: 8), ProzentDropdown(label: 'Transferbelt', value: _laufzeitTransferbelt, onChanged: (val) => setState(() => _laufzeitTransferbelt = val ?? 0))]),

              const SizedBox(height: 22),
              const Text('Testergebnisse und Zustand', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TestergebnisseEingabe(
                fach1Controller: _fach1Controller,
                fach2Controller: _fach2Controller,
                fach3Controller: _fach3Controller,
                fach4Controller: _fach4Controller,
                bypassController: _bypassController,
                dokumenteneinzugController: _dokumenteneinzugController,
                duplexController: _duplexController,
              ),

              const SizedBox(height: 22),
              TextFormField(controller: _bemerkungController, decoration: const InputDecoration(labelText: 'Bemerkung (frei)', alignLabelWithHint: true), minLines: 2, maxLines: 4),
              const SizedBox(height: 22),
              ElevatedButton(onPressed: _saveGeraet, child: const Text('Speichern')),
            ],
          ),
        ),
      ),
    );
  }
}
