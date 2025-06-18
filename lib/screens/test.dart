import 'package:flutter/material.dart';
import '../../models/geraet.dart';

class GeraeteAufnahmeScreen extends StatefulWidget {
  final void Function(Geraet) onSave;
  final List<Geraet> vorhandeneGeraete;
  final Geraet? initialGeraet;

  const GeraeteAufnahmeScreen({
    Key? key,
    required this.onSave,
    required this.vorhandeneGeraete,
    this.initialGeraet,
  }) : super(key: key);

  @override
  State<GeraeteAufnahmeScreen> createState() => _GeraeteAufnahmeScreenState();
}

class _GeraeteAufnahmeScreenState extends State<GeraeteAufnahmeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Auswahloptionen
  final List<String> _mitarbeiterOptionen = [
    'Patrick Heidrich',
    'Carsten Sobota',
    'Melanie Toffel',
    'Dirk Kraft'
  ];
  final List<String> _modellOptionen = [
    'bizhub C250i',
    'bizhub C300i',
    'bizhub C360i',
    'andere'
  ];
  final List<String> _jaNeinOptionen = ['Ja', 'Nein'];
  final List<String> _pdfTypen = ['A', 'B'];
  final List<int> _prozentSchritte = List.generate(11, (i) => i * 10);

  // Grunddaten
  String? _selectedMitarbeiter;
  String? _selectedModell;
  final _nummerController = TextEditingController();
  final _seriennummerController = TextEditingController();

  // Optionen
  String? _selectedIOption;
  String? _selectedPdfTyp;
  String? _selectedDurchsuchbar;

  // Zubehör
  final _originaleinzugTypController = TextEditingController();
  final _originaleinzugSNController = TextEditingController();
  final _unterschrankTypController = TextEditingController();
  final _unterschrankSNController = TextEditingController();
  final _finisherController = TextEditingController();
  final _finisherSNController = TextEditingController();
  String _selectedFax = 'Nein';

  // Zähler
  final _zaehlerGesamtController = TextEditingController();
  final _zaehlerSWController = TextEditingController();
  final _zaehlerColorController = TextEditingController();

  // Füllstände/RTB/Toner
  int _rtb = 0;
  int _tonerK = 0;
  int _tonerC = 0;
  int _tonerM = 0;
  int _tonerY = 0;

  // Laufzeiten - Bildeinheit (pro Farbe)
  int _laufzeitBildeinheitK = 0;
  int _laufzeitBildeinheitC = 0;
  int _laufzeitBildeinheitM = 0;
  int _laufzeitBildeinheitY = 0;
  // Laufzeiten - Entwickler (pro Farbe)
  int _laufzeitEntwicklerK = 0;
  int _laufzeitEntwicklerC = 0;
  int _laufzeitEntwicklerM = 0;
  int _laufzeitEntwicklerY = 0;
  // Fixierer und Transferbelt
  int _laufzeitFixiereinheit = 0;
  int _laufzeitTransferbelt = 0;

  // Testergebnisse und Zustand
  final _fach1Controller = TextEditingController();
  final _fach2Controller = TextEditingController();
  final _fach3Controller = TextEditingController();
  final _fach4Controller = TextEditingController();
  final _bypassController = TextEditingController();
  final _dokumenteneinzugController = TextEditingController();
  final _duplexController = TextEditingController();

  // Bemerkung
  final _bemerkungController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialGeraet != null) {
      final g = widget.initialGeraet!;
      _nummerController.text = g.nummer;
      _selectedModell = g.modell;
      _seriennummerController.text = g.seriennummer;
      _selectedMitarbeiter = g.mitarbeiter;
      _selectedIOption = g.iOption;
      _selectedPdfTyp = g.pdfTyp;
      _selectedDurchsuchbar = g.durchsuchbar;
      _originaleinzugTypController.text = g.originaleinzugTyp;
      _originaleinzugSNController.text = g.originaleinzugSN;
      _unterschrankTypController.text = g.unterschrankTyp;
      _unterschrankSNController.text = g.unterschrankSN;
      _finisherController.text = g.finisher;
      _finisherSNController.text = g.finisherSN;
      _selectedFax = g.fax.isNotEmpty ? g.fax : 'Nein';
      _zaehlerGesamtController.text = g.zaehlerGesamt.toString();
      _zaehlerSWController.text = g.zaehlerSW.toString();
      _zaehlerColorController.text = g.zaehlerColor.toString();
      _rtb = g.rtb;
      _tonerK = g.tonerK;
      _tonerC = g.tonerC;
      _tonerM = g.tonerM;
      _tonerY = g.tonerY;

      _laufzeitBildeinheitK = g.laufzeitBildeinheitK;
      _laufzeitBildeinheitC = g.laufzeitBildeinheitC;
      _laufzeitBildeinheitM = g.laufzeitBildeinheitM;
      _laufzeitBildeinheitY = g.laufzeitBildeinheitY;
      _laufzeitEntwicklerK = g.laufzeitEntwicklerK;
      _laufzeitEntwicklerC = g.laufzeitEntwicklerC;
      _laufzeitEntwicklerM = g.laufzeitEntwicklerM;
      _laufzeitEntwicklerY = g.laufzeitEntwicklerY;
      _laufzeitFixiereinheit = g.laufzeitFixiereinheit;
      _laufzeitTransferbelt = g.laufzeitTransferbelt;

      _fach1Controller.text = g.fach1 ?? '';
      _fach2Controller.text = g.fach2 ?? '';
      _fach3Controller.text = g.fach3 ?? '';
      _fach4Controller.text = g.fach4 ?? '';
      _bypassController.text = g.bypass ?? '';
      _dokumenteneinzugController.text = g.dokumenteneinzug ?? '';
      _duplexController.text = g.duplex ?? '';
      _bemerkungController.text = g.bemerkung ?? '';
    }
  }

  @override
  void dispose() {
    _nummerController.dispose();
    _seriennummerController.dispose();
    _originaleinzugTypController.dispose();
    _originaleinzugSNController.dispose();
    _unterschrankTypController.dispose();
    _unterschrankSNController.dispose();
    _finisherController.dispose();
    _finisherSNController.dispose();
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

  void _saveGeraet() {
    if (_nummerController.text.trim().isEmpty || _selectedModell == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bitte Gerätenummer und Modell angeben!')),
      );
      return;
    }
    final doppelt = widget.vorhandeneGeraete.any((g) =>
    g.nummer == _nummerController.text.trim() &&
        (widget.initialGeraet == null || g != widget.initialGeraet));
    if (doppelt) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gerätenummer bereits vorhanden!')),
      );
      return;
    }

    int zaehlerSW = int.tryParse(_zaehlerSWController.text) ?? 0;
    int zaehlerColor = int.tryParse(_zaehlerColorController.text) ?? 0;
    int zaehlerGesamt = zaehlerSW + zaehlerColor;

    final neuesGeraet = Geraet(
      nummer: _nummerController.text.trim(),
      modell: _selectedModell ?? '',
      seriennummer: _seriennummerController.text.trim(),
      mitarbeiter: _selectedMitarbeiter ?? '',
      iOption: _selectedIOption ?? 'Nein',
      pdfTyp: _selectedPdfTyp ?? 'A',
      durchsuchbar: _selectedDurchsuchbar ?? 'Nein',
      originaleinzugTyp: _originaleinzugTypController.text.trim(),
      originaleinzugSN: _originaleinzugSNController.text.trim(),
      unterschrankTyp: _unterschrankTypController.text.trim(),
      unterschrankSN: _unterschrankSNController.text.trim(),
      finisher: _finisherController.text.trim(),
      finisherSN: _finisherSNController.text.trim(),
      fax: _selectedFax,
      zaehlerGesamt: zaehlerGesamt,
      zaehlerSW: zaehlerSW,
      zaehlerColor: zaehlerColor,
      rtb: _rtb,
      tonerK: _tonerK,
      tonerC: _tonerC,
      tonerM: _tonerM,
      tonerY: _tonerY,
      laufzeitBildeinheitK: _laufzeitBildeinheitK,
      laufzeitBildeinheitC: _laufzeitBildeinheitC,
      laufzeitBildeinheitM: _laufzeitBildeinheitM,
      laufzeitBildeinheitY: _laufzeitBildeinheitY,
      laufzeitEntwicklerK: _laufzeitEntwicklerK,
      laufzeitEntwicklerC: _laufzeitEntwicklerC,
      laufzeitEntwicklerM: _laufzeitEntwicklerM,
      laufzeitEntwicklerY: _laufzeitEntwicklerY,
      laufzeitFixiereinheit: _laufzeitFixiereinheit,
      laufzeitTransferbelt: _laufzeitTransferbelt,
      fach1: _fach1Controller.text.trim(),
      fach2: _fach2Controller.text.trim(),
      fach3: _fach3Controller.text.trim(),
      fach4: _fach4Controller.text.trim(),
      bypass: _bypassController.text.trim(),
      dokumenteneinzug: _dokumenteneinzugController.text.trim(),
      duplex: _duplexController.text.trim(),
      bemerkung: _bemerkungController.text.trim(),
    );
    widget.onSave(neuesGeraet);
    Navigator.of(context).pop();
  }

  Widget _buildProzentDropdown(String label, int value, ValueChanged<int?> onChanged) {
    return Expanded(
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: _prozentSchritte
            .map((v) => DropdownMenuItem(value: v, child: Text('$v%')))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geräteaufnahme'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedMitarbeiter,
                decoration: InputDecoration(labelText: 'Verantwortlicher Mitarbeiter'),
                items: _mitarbeiterOptionen.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) => setState(() => _selectedMitarbeiter = val),
              ),
              TextFormField(
                controller: _nummerController,
                decoration: InputDecoration(labelText: 'Gerätenummer*'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedModell,
                decoration: InputDecoration(labelText: 'Modell*'),
                items: _modellOptionen.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) => setState(() => _selectedModell = val),
              ),
              TextFormField(
                controller: _seriennummerController,
                decoration: InputDecoration(labelText: 'Seriennummer'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedIOption,
                decoration: InputDecoration(labelText: 'I-Option'),
                items: _jaNeinOptionen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedIOption = val),
              ),
              DropdownButtonFormField<String>(
                value: _selectedPdfTyp,
                decoration: InputDecoration(labelText: 'PDF Typ'),
                items: _pdfTypen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedPdfTyp = val),
              ),
              DropdownButtonFormField<String>(
                value: _selectedDurchsuchbar,
                decoration: InputDecoration(labelText: 'Durchsuchbar'),
                items: _jaNeinOptionen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedDurchsuchbar = val),
              ),
              const SizedBox(height: 22),

              // Zubehör
              Text('Zubehör:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _originaleinzugTypController,
                      decoration: InputDecoration(labelText: 'Originaleinzug Typ'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _originaleinzugSNController,
                      decoration: InputDecoration(labelText: 'Seriennummer'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _unterschrankTypController,
                      decoration: InputDecoration(labelText: 'Unterschrank Typ'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _unterschrankSNController,
                      decoration: InputDecoration(labelText: 'Seriennummer'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _finisherController,
                      decoration: InputDecoration(labelText: 'Finisher'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _finisherSNController,
                      decoration: InputDecoration(labelText: 'Seriennummer'),
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: _selectedFax,
                decoration: InputDecoration(labelText: 'Fax'),
                items: _jaNeinOptionen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedFax = val ?? 'Nein'),
              ),
              const SizedBox(height: 22),

              // Zählerstände
              Text('Zählerstände:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _zaehlerSWController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'S/W'),
                      onChanged: (val) => setState(() {
                        final sw = int.tryParse(val) ?? 0;
                        final color = int.tryParse(_zaehlerColorController.text) ?? 0;
                        _zaehlerGesamtController.text = (sw + color).toString();
                      }),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _zaehlerColorController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Color'),
                      onChanged: (val) => setState(() {
                        final color = int.tryParse(val) ?? 0;
                        final sw = int.tryParse(_zaehlerSWController.text) ?? 0;
                        _zaehlerGesamtController.text = (sw + color).toString();
                      }),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _zaehlerGesamtController,
                      readOnly: true,
                      decoration: InputDecoration(labelText: 'Gesamt (Auto)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Füllstände/RTB/Toner
              Text('Füllstände (in %):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildProzentDropdown('RTB', _rtb, (val) => setState(() => _rtb = val ?? 0)),
                  const SizedBox(width: 8),
                  _buildProzentDropdown('Toner K', _tonerK, (val) => setState(() => _tonerK = val ?? 0)),
                  const SizedBox(width: 8),
                  _buildProzentDropdown('Toner C', _tonerC, (val) => setState(() => _tonerC = val ?? 0)),
                  const SizedBox(width: 8),
                  _buildProzentDropdown('Toner M', _tonerM, (val) => setState(() => _tonerM = val ?? 0)),
                  const SizedBox(width: 8),
                  _buildProzentDropdown('Toner Y', _tonerY, (val) => setState(() => _tonerY = val ?? 0)),
                ],
              ),
              const SizedBox(height: 22),

              // Laufzeiten - Bildeinheit (pro Farbe)
              Text('Laufzeiten Bildeinheit (jeweils %):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                children: [
                  _buildProzentDropdown('K', _laufzeitBildeinheitK, (val) => setState(() => _laufzeitBildeinheitK = val ?? 0)),
                  const SizedBox(width: 8),
                  _buildProzentDropdown('C', _laufzeitBildeinheitC, (val) => setState(() => _laufzeitBildeinheitC = val ?? 0)),
                  const SizedBox(width: 8),
                  _buildProzentDropdown('M', _laufzeitBildeinheitM, (val) => setState(() => _laufzeitBildeinheitM = val ?? 0)),
                  const SizedBox(width: 8),
                  _buildProzentDropdown('Y', _laufzeitBildeinheitY, (val) => setState(() => _laufzeitBildeinheitY = val ?? 0)),
                ],
              ),

              const SizedBox(height: 22),
              Text('Laufzeiten Entwickler (jeweils %):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                children: [
                  _buildProzentDropdown('K', _laufzeitEntwicklerK, (val) => setState(() => _laufzeitEntwicklerK = val ?? 0)),
                  const SizedBox(width: 8),
                  _buildProzentDropdown('C', _laufzeitEntwicklerC, (val) => setState(() => _laufzeitEntwicklerC = val ?? 0)),
                  const SizedBox(width: 8),
                  _buildProzentDropdown('M', _laufzeitEntwicklerM, (val) => setState(() => _laufzeitEntwicklerM = val ?? 0)),
                  const SizedBox(width: 8),
                  _buildProzentDropdown('Y', _laufzeitEntwicklerY, (val) => setState(() => _laufzeitEntwicklerY = val ?? 0)),
                ],
              ),

              const SizedBox(height: 22),
              Row(
                children: [
                  _buildProzentDropdown('Fixiereinheit', _laufzeitFixiereinheit, (val) => setState(() => _laufzeitFixiereinheit = val ?? 0)),
                  const SizedBox(width: 8),
                  _buildProzentDropdown('Transferbelt', _laufzeitTransferbelt, (val) => setState(() => _laufzeitTransferbelt = val ?? 0)),
                ],
              ),
              const SizedBox(height: 22),

              // Testergebnisse und Zustand
              Text('Testergebnisse und Zustand', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fach1Controller,
                      decoration: InputDecoration(labelText: 'Fach1'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _fach2Controller,
                      decoration: InputDecoration(labelText: 'Fach2'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _fach3Controller,
                      decoration: InputDecoration(labelText: 'Fach3'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _fach4Controller,
                      decoration: InputDecoration(labelText: 'Fach4'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bypassController,
                      decoration: InputDecoration(labelText: 'Bypass'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _dokumenteneinzugController,
                      decoration: InputDecoration(labelText: 'Dokumenteneinzug'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _duplexController,
                      decoration: InputDecoration(labelText: 'Duplex'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 22),

              // Bemerkung (Freitext)
              TextFormField(
                controller: _bemerkungController,
                decoration: InputDecoration(
                  labelText: 'Bemerkung (frei)',
                  alignLabelWithHint: true,
                ),
                minLines: 2,
                maxLines: 4,
              ),
              SizedBox(height: 22),

              ElevatedButton(
                onPressed: _saveGeraet,
                child: Text('Speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
