import 'package:flutter/material.dart';
import '../../models/geraet.dart';

class GeraeteAufnahmeScreen extends StatefulWidget {
  final Geraet? initialGeraet;
  final Future<void> Function(Geraet) onSave;

  const GeraeteAufnahmeScreen({
    Key? key,
    this.initialGeraet,
    required this.onSave,
  }) : super(key: key);

  @override
  State<GeraeteAufnahmeScreen> createState() => _GeraeteAufnahmeScreenState();
}

class _GeraeteAufnahmeScreenState extends State<GeraeteAufnahmeScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- ANFANG DER ÄNDERUNG ---
  // Die Liste der Modelle wurde basierend auf Ihrer Vorlage aktualisiert.
  final List<String> _modellOptionen = [
    'Nichts ausgewählt',
    // A3 Farbsysteme
    'bizhub C250i', 'bizhub C251i', 'bizhub C257i',
    'bizhub C300i', 'bizhub C301i',
    'bizhub C360i', 'bizhub C361i',
    'bizhub C451i', 'bizhub C551i', 'bizhub C651i', 'bizhub C751i',
    'bizhub C258', 'bizhub C308', 'bizhub C368',
    'bizhub C458', 'bizhub C558', 'bizhub C658',
    'bizhub C224e', 'bizhub C284e', 'bizhub C364e',
    'bizhub C454e', 'bizhub C554e',
    // A4 Farbsysteme
    'bizhub C3301i', 'bizhub C3321i',
    'bizhub C3351i',
    'bizhub C4051i',
    'bizhub C3350i', 'bizhub C3851',
    'bizhub C3351', 'bizhub C3851FS',
    // A3 S/W-Systeme
    'bizhub 227', 'bizhub 287', 'bizhub 367',
    'bizhub 301i', 'bizhub 361i',
    'bizhub 451i', 'bizhub 551i', 'bizhub 651i', 'bizhub 751i',
    // A4 S/W-Systeme
    'bizhub 4000i', 'bizhub 4051i', 'bizhub 4701i', 'bizhub 4751i',
    'bizhub 4052', 'bizhub 4702p', 'bizhub 4752',
    'andere' // Option für andere Modelle
  ];
  // --- ENDE DER ÄNDERUNG ---

  // Dropdown-Optionen
  final List<String> _mitarbeiterOptionen = ['Nichts ausgewählt', 'Patrick Heidrich', 'Carsten Sobota', 'Melanie Toffel', 'Dirk Kraft'];
  final List<String> _jaNeinOptionen = ['Nichts ausgewählt', 'Ja', 'Nein'];
  final List<String> _pdfTypen = ['Nichts ausgewählt', 'A', 'B'];
  final List<int> _prozentSchritte = List.generate(11, (i) => i * 10);
  final List<String> _originaleinzugTypOptionen = ['Nichts ausgewählt', 'Kein', 'DF-714', 'DF-715', 'DF-632', 'DF-633', 'Sonstiges'];
  final List<String> _unterschrankTypOptionen = ['Nichts ausgewählt', 'Kein', 'PC-116', 'PC-216', 'PC-416', 'Sonstiges'];
  final List<String> _finisherOptionen = ['Nichts ausgewählt', 'Kein', 'FS-533', 'FS-539', 'FS-532', 'Sonstiges'];

  // Controller und Felder
  final _nummerController = TextEditingController();
  final _seriennummerController = TextEditingController();
  String _selectedMitarbeiter = 'Nichts ausgewählt';
  String _selectedModell = 'Nichts ausgewählt';
  String _selectedIOption = 'Nichts ausgewählt';
  String _selectedPdfTyp = 'Nichts ausgewählt';
  String _selectedDurchsuchbar = 'Nichts ausgewählt';
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
  int _rtb = 0;
  int _tonerK = 0;
  int _tonerC = 0;
  int _tonerM = 0;
  int _tonerY = 0;
  int _laufzeitBildeinheitK = 0;
  int _laufzeitBildeinheitC = 0;
  int _laufzeitBildeinheitM = 0;
  int _laufzeitBildeinheitY = 0;
  int _laufzeitEntwicklerK = 0;
  int _laufzeitEntwicklerC = 0;
  int _laufzeitEntwicklerM = 0;
  int _laufzeitEntwicklerY = 0;
  int _laufzeitFixiereinheit = 0;
  int _laufzeitTransferbelt = 0;
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
      _selectedModell = g.modell.isNotEmpty ? g.modell : 'Nichts ausgewählt';
      _seriennummerController.text = g.seriennummer;
      _selectedMitarbeiter = g.mitarbeiter.isNotEmpty ? g.mitarbeiter : 'Nichts ausgewählt';
      _selectedIOption = g.iOption.isNotEmpty ? g.iOption : 'Nichts ausgewählt';
      _selectedPdfTyp = g.pdfTyp.isNotEmpty ? g.pdfTyp : 'Nichts ausgewählt';
      _selectedDurchsuchbar = g.durchsuchbar.isNotEmpty ? g.durchsuchbar : 'Nichts ausgewählt';
      _selectedOriginaleinzugTyp = g.originaleinzugTyp.isNotEmpty ? g.originaleinzugTyp : 'Nichts ausgewählt';
      _originaleinzugSNController.text = g.originaleinzugSN;
      _selectedUnterschrankTyp = g.unterschrankTyp.isNotEmpty ? g.unterschrankTyp : 'Nichts ausgewählt';
      _unterschrankSNController.text = g.unterschrankSN;
      _selectedFinisher = g.finisher.isNotEmpty ? g.finisher : 'Nichts ausgewählt';
      _finisherSNController.text = g.finisherSN;
      _selectedFax = g.fax.isNotEmpty ? g.fax : 'Nichts ausgewählt';
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
    }
  }

  @override
  void dispose() {
    _nummerController.dispose();
    _seriennummerController.dispose();
    _originaleinzugSNController.dispose();
    _unterschrankSNController.dispose();
    _finisherSNController.dispose();
    _faxSNController.dispose();
    _zaehlerGesamtController.dispose();
    _zaehlerSWController.dispose();
    _zaehlerColorController.dispose();
    _fach1Controller.dispose();
    _fach2Controller.dispose();
    _fach3Controller.dispose();
    _fach4Controller.dispose();
    _bypassController.dispose();
    _dokumenteneinzugController.dispose();
    _duplexController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  void _saveGeraet() async {
    if (_nummerController.text.trim().isEmpty || _selectedModell == 'Nichts ausgewählt') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Gerätenummer und Modell angeben!')),
      );
      return;
    }

    String clean(String val) => val == 'Nichts ausgewählt' ? '' : val;

    final neuesGeraet = Geraet(
      id: widget.initialGeraet?.id ?? '',
      nummer: _nummerController.text.trim(),
      modell: clean(_selectedModell),
      seriennummer: _seriennummerController.text.trim(),
      mitarbeiter: clean(_selectedMitarbeiter),
      iOption: clean(_selectedIOption),
      pdfTyp: clean(_selectedPdfTyp),
      durchsuchbar: clean(_selectedDurchsuchbar),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gerät erfolgreich gespeichert!')),
    );
    Navigator.of(context).pop();
  }

  Widget _buildProzentDropdown(String label, int value, ValueChanged<int?> onChanged) {
    return Expanded(
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: _prozentSchritte.map((v) => DropdownMenuItem(value: v, child: Text('$v%'))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool showFinisherSN = _selectedFinisher != 'Nichts ausgewählt' && _selectedFinisher != 'Kein';
    bool showFaxSN = _selectedFax == 'Ja';

    return Scaffold(
      appBar: AppBar(title: Text(widget.initialGeraet == null ? 'Neues Gerät anlegen' : 'Gerät bearbeiten')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(value: _selectedMitarbeiter, decoration: const InputDecoration(labelText: 'Verantwortlicher Mitarbeiter'), items: _mitarbeiterOptionen.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (val) => setState(() => _selectedMitarbeiter = val ?? 'Nichts ausgewählt')),
              TextFormField(controller: _nummerController, decoration: const InputDecoration(labelText: 'Gerätenummer*')),
              DropdownButtonFormField<String>(
                value: _selectedModell,
                decoration: const InputDecoration(labelText: 'Modell*'),
                items: _modellOptionen.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) => setState(() => _selectedModell = val ?? 'Nichts ausgewählt'),
              ),
              TextFormField(controller: _seriennummerController, decoration: const InputDecoration(labelText: 'Seriennummer')),
              DropdownButtonFormField<String>(value: _selectedIOption, decoration: const InputDecoration(labelText: 'I-Option'), items: _jaNeinOptionen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (val) => setState(() => _selectedIOption = val ?? 'Nichts ausgewählt')),
              DropdownButtonFormField<String>(value: _selectedPdfTyp, decoration: const InputDecoration(labelText: 'PDF Typ'), items: _pdfTypen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (val) => setState(() => _selectedPdfTyp = val ?? 'Nichts ausgewählt')),
              DropdownButtonFormField<String>(value: _selectedDurchsuchbar, decoration: const InputDecoration(labelText: 'Durchsuchbar'), items: _jaNeinOptionen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (val) => setState(() => _selectedDurchsuchbar = val ?? 'Nichts ausgewählt')),
              const SizedBox(height: 22),
              const Text('Zubehör:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(children: [Expanded(child: DropdownButtonFormField<String>(value: _selectedOriginaleinzugTyp, decoration: const InputDecoration(labelText: 'Originaleinzug Typ'), items: _originaleinzugTypOptionen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (val) => setState(() => _selectedOriginaleinzugTyp = val ?? 'Nichts ausgewählt'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _originaleinzugSNController, decoration: const InputDecoration(labelText: 'Seriennummer')))]),
              Row(children: [Expanded(child: DropdownButtonFormField<String>(value: _selectedUnterschrankTyp, decoration: const InputDecoration(labelText: 'Unterschrank Typ'), items: _unterschrankTypOptionen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (val) => setState(() => _selectedUnterschrankTyp = val ?? 'Nichts ausgewählt'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _unterschrankSNController, decoration: const InputDecoration(labelText: 'Seriennummer')))]),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFinisher,
                      decoration: const InputDecoration(labelText: 'Finisher'),
                      items: _finisherOptionen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _selectedFinisher = val ?? 'Nichts ausgewählt'),
                    ),
                  ),
                  if (showFinisherSN) ...[const SizedBox(width: 8), Expanded(child: TextFormField(controller: _finisherSNController, decoration: const InputDecoration(labelText: 'Seriennummer')))]
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFax,
                      decoration: const InputDecoration(labelText: 'Fax'),
                      items: _jaNeinOptionen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _selectedFax = val ?? 'Nichts ausgewählt'),
                    ),
                  ),
                  if (showFaxSN) ...[const SizedBox(width: 8), Expanded(child: TextFormField(controller: _faxSNController, decoration: const InputDecoration(labelText: 'Seriennummer')))]
                ],
              ),
              const SizedBox(height: 22),
              const Text('Zählerstände:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(children: [Expanded(child: TextFormField(controller: _zaehlerSWController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'S/W'), onChanged: (val) => setState(() { final sw = int.tryParse(val) ?? 0; final color = int.tryParse(_zaehlerColorController.text) ?? 0; _zaehlerGesamtController.text = (sw + color).toString(); }))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _zaehlerColorController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Color'), onChanged: (val) => setState(() { final color = int.tryParse(val) ?? 0; final sw = int.tryParse(_zaehlerSWController.text) ?? 0; _zaehlerGesamtController.text = (sw + color).toString(); }))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _zaehlerGesamtController, readOnly: true, decoration: const InputDecoration(labelText: 'Gesamt (Auto)')))]),
              const SizedBox(height: 22),
              const Text('Füllstände (in %):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Row(children: [_buildProzentDropdown('RTB', _rtb, (val) => setState(() => _rtb = val ?? 0)), const SizedBox(width: 8), _buildProzentDropdown('Toner K', _tonerK, (val) => setState(() => _tonerK = val ?? 0)), const SizedBox(width: 8), _buildProzentDropdown('Toner C', _tonerC, (val) => setState(() => _tonerC = val ?? 0)), const SizedBox(width: 8), _buildProzentDropdown('Toner M', _tonerM, (val) => setState(() => _tonerM = val ?? 0)), const SizedBox(width: 8), _buildProzentDropdown('Toner Y', _tonerY, (val) => setState(() => _tonerY = val ?? 0))]),
              const SizedBox(height: 22),
              const Text('Laufzeiten Bildeinheit (jeweils %):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(children: [_buildProzentDropdown('K', _laufzeitBildeinheitK, (val) => setState(() => _laufzeitBildeinheitK = val ?? 0)), const SizedBox(width: 8), _buildProzentDropdown('C', _laufzeitBildeinheitC, (val) => setState(() => _laufzeitBildeinheitC = val ?? 0)), const SizedBox(width: 8), _buildProzentDropdown('M', _laufzeitBildeinheitM, (val) => setState(() => _laufzeitBildeinheitM = val ?? 0)), const SizedBox(width: 8), _buildProzentDropdown('Y', _laufzeitBildeinheitY, (val) => setState(() => _laufzeitBildeinheitY = val ?? 0))]),
              const SizedBox(height: 22),
              const Text('Laufzeiten Entwickler (jeweils %):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(children: [_buildProzentDropdown('K', _laufzeitEntwicklerK, (val) => setState(() => _laufzeitEntwicklerK = val ?? 0)), const SizedBox(width: 8), _buildProzentDropdown('C', _laufzeitEntwicklerC, (val) => setState(() => _laufzeitEntwicklerC = val ?? 0)), const SizedBox(width: 8), _buildProzentDropdown('M', _laufzeitEntwicklerM, (val) => setState(() => _laufzeitEntwicklerM = val ?? 0)), const SizedBox(width: 8), _buildProzentDropdown('Y', _laufzeitEntwicklerY, (val) => setState(() => _laufzeitEntwicklerY = val ?? 0))]),
              const SizedBox(height: 22),
              Row(children: [_buildProzentDropdown('Fixiereinheit', _laufzeitFixiereinheit, (val) => setState(() => _laufzeitFixiereinheit = val ?? 0)), const SizedBox(width: 8), _buildProzentDropdown('Transferbelt', _laufzeitTransferbelt, (val) => setState(() => _laufzeitTransferbelt = val ?? 0))]),
              const SizedBox(height: 22),
              const Text('Testergebnisse und Zustand', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(children: [Expanded(child: TextFormField(controller: _fach1Controller, decoration: const InputDecoration(labelText: 'Fach1'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _fach2Controller, decoration: const InputDecoration(labelText: 'Fach2'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _fach3Controller, decoration: const InputDecoration(labelText: 'Fach3'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _fach4Controller, decoration: const InputDecoration(labelText: 'Fach4')))]),
              const SizedBox(height: 8),
              Row(children: [Expanded(child: TextFormField(controller: _bypassController, decoration: const InputDecoration(labelText: 'Bypass'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _dokumenteneinzugController, decoration: const InputDecoration(labelText: 'Dokumenteneinzug'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _duplexController, decoration: const InputDecoration(labelText: 'Duplex')))]),
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
