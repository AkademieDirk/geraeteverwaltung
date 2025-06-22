import 'package:flutter/material.dart';
import '../../models/geraet.dart';
import 'zubehoer_section.dart';
import 'zaehler_section.dart';
import 'fuellstaende_section.dart';
import 'testergebnisse_section.dart';

class GeraeteForm extends StatefulWidget {
  final List<Geraet> vorhandeneGeraete;
  final Geraet? initialGeraet;

  const GeraeteForm({
    Key? key,
    required this.vorhandeneGeraete,
    this.initialGeraet,
  }) : super(key: key);

  @override
  State<GeraeteForm> createState() => _GeraeteFormState();
}

class _GeraeteFormState extends State<GeraeteForm> {
  final _formKey = GlobalKey<FormState>();

  // Dropdown-Optionen
  final List<String> _mitarbeiterOptionen = [
    'Nichts ausgewählt', 'Patrick Heidrich', 'Carsten Sobota', 'Melanie Toffel', 'Dirk Kraft'
  ];
  final List<String> _modellOptionen = [
    'Nichts ausgewählt', 'bizhub C250i', 'bizhub C300i', 'bizhub C360i', 'andere'
  ];
  final List<String> _jaNeinOptionen = ['Nichts ausgewählt', 'Ja', 'Nein'];
  final List<String> _pdfTypen = ['Nichts ausgewählt', 'A', 'B'];
  final List<int> _prozentSchritte = List.generate(11, (i) => i * 10);

  final List<String> _originaleinzugTypOptionen = [
    'Nichts ausgewählt', 'Kein', 'DF-714', 'DF-715', 'DF-632', 'DF-633', 'Sonstiges'
  ];
  final List<String> _unterschrankTypOptionen = [
    'Nichts ausgewählt', 'Kein', 'PC-116', 'PC-216', 'PC-416', 'Sonstiges'
  ];
  final List<String> _finisherOptionen = [
    'Nichts ausgewählt', 'Kein', 'FS-533', 'FS-539', 'FS-532', 'Sonstiges'
  ];

  // Felder
  String _selectedMitarbeiter = 'Nichts ausgewählt';
  String _selectedModell = 'Nichts ausgewählt';
  final _nummerController = TextEditingController();
  final _seriennummerController = TextEditingController();

  String _selectedIOption = 'Nichts ausgewählt';
  String _selectedPdfTyp = 'Nichts ausgewählt';
  String _selectedDurchsuchbar = 'Nichts ausgewählt';

  // Zubehör
  String _selectedOriginaleinzugTyp = 'Nichts ausgewählt';
  final _originaleinzugSNController = TextEditingController();
  String _selectedUnterschrankTyp = 'Nichts ausgewählt';
  final _unterschrankSNController = TextEditingController();
  String _selectedFinisher = 'Nichts ausgewählt';
  final _finisherSNController = TextEditingController();
  String _selectedFax = 'Nichts ausgewählt';

  // Zähler
  final _zaehlerGesamtController = TextEditingController();
  final _zaehlerSWController = TextEditingController();
  final _zaehlerColorController = TextEditingController();

  // Füllstände/Toner/Laufzeiten
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

  // Testergebnisse/Fächer
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
    _originaleinzugSNController.dispose();
    _unterschrankSNController.dispose();
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
    if (_nummerController.text.trim().isEmpty || _selectedModell == 'Nichts ausgewählt') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Gerätenummer und Modell angeben!')),
      );
      return;
    }
    final doppelt = widget.vorhandeneGeraete.any((g) =>
    g.nummer == _nummerController.text.trim() &&
        (widget.initialGeraet == null || g != widget.initialGeraet)
    );
    if (doppelt) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gerätenummer bereits vorhanden!')),
      );
      return;
    }

    int zaehlerSW = int.tryParse(_zaehlerSWController.text) ?? 0;
    int zaehlerColor = int.tryParse(_zaehlerColorController.text) ?? 0;
    int zaehlerGesamt = zaehlerSW + zaehlerColor;

    String clean(String val) => val == 'Nichts ausgewählt' ? '' : val;

    final neuesGeraet = Geraet(
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
    Navigator.of(context).pop(neuesGeraet);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMitarbeiter,
              decoration: const InputDecoration(labelText: 'Verantwortlicher Mitarbeiter'),
              items: _mitarbeiterOptionen.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _selectedMitarbeiter = val ?? 'Nichts ausgewählt'),
            ),
            TextFormField(
              controller: _nummerController,
              decoration: const InputDecoration(labelText: 'Gerätenummer*'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedModell,
              decoration: const InputDecoration(labelText: 'Modell*'),
              items: _modellOptionen.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _selectedModell = val ?? 'Nichts ausgewählt'),
            ),
            TextFormField(
              controller: _seriennummerController,
              decoration: const InputDecoration(labelText: 'Seriennummer'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedIOption,
              decoration: const InputDecoration(labelText: 'I-Option'),
              items: _jaNeinOptionen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedIOption = val ?? 'Nichts ausgewählt'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedPdfTyp,
              decoration: const InputDecoration(labelText: 'PDF Typ'),
              items: _pdfTypen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedPdfTyp = val ?? 'Nichts ausgewählt'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedDurchsuchbar,
              decoration: const InputDecoration(labelText: 'Durchsuchbar'),
              items: _jaNeinOptionen.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedDurchsuchbar = val ?? 'Nichts ausgewählt'),
            ),
            const SizedBox(height: 22),

            // Die ausgelagerten Sections folgen:
            ZubehoerSection(
              originaleinzugTypOptionen: _originaleinzugTypOptionen,
              selectedOriginaleinzugTyp: _selectedOriginaleinzugTyp,
              onChangedOriginaleinzugTyp: (val) => setState(() => _selectedOriginaleinzugTyp = val ?? 'Nichts ausgewählt'),
              originaleinzugSNController: _originaleinzugSNController,

              unterschrankTypOptionen: _unterschrankTypOptionen,
              selectedUnterschrankTyp: _selectedUnterschrankTyp,
              onChangedUnterschrankTyp: (val) => setState(() => _selectedUnterschrankTyp = val ?? 'Nichts ausgewählt'),
              unterschrankSNController: _unterschrankSNController,

              finisherOptionen: _finisherOptionen,
              selectedFinisher: _selectedFinisher,
              onChangedFinisher: (val) => setState(() => _selectedFinisher = val ?? 'Nichts ausgewählt'),
              finisherSNController: _finisherSNController,

              jaNeinOptionen: _jaNeinOptionen,
              selectedFax: _selectedFax,
              onChangedFax: (val) => setState(() => _selectedFax = val ?? 'Nichts ausgewählt'),
            ),
            const SizedBox(height: 22),

            ZaehlerSection(
              zaehlerSWController: _zaehlerSWController,
              zaehlerColorController: _zaehlerColorController,
              zaehlerGesamtController: _zaehlerGesamtController,
              onChanged: () {
                setState(() {
                  final sw = int.tryParse(_zaehlerSWController.text) ?? 0;
                  final color = int.tryParse(_zaehlerColorController.text) ?? 0;
                  _zaehlerGesamtController.text = (sw + color).toString();
                });
              },
            ),
            const SizedBox(height: 22),

            FuellstaendeSection(
              prozentSchritte: _prozentSchritte,
              rtb: _rtb,
              onChangedRtb: (val) => setState(() => _rtb = val ?? 0),
              tonerK: _tonerK,
              onChangedTonerK: (val) => setState(() => _tonerK = val ?? 0),
              tonerC: _tonerC,
              onChangedTonerC: (val) => setState(() => _tonerC = val ?? 0),
              tonerM: _tonerM,
              onChangedTonerM: (val) => setState(() => _tonerM = val ?? 0),
              tonerY: _tonerY,
              onChangedTonerY: (val) => setState(() => _tonerY = val ?? 0),
              laufzeitBildeinheitK: _laufzeitBildeinheitK,
              onChangedLaufzeitBildeinheitK: (val) => setState(() => _laufzeitBildeinheitK = val ?? 0),
              laufzeitBildeinheitC: _laufzeitBildeinheitC,
              onChangedLaufzeitBildeinheitC: (val) => setState(() => _laufzeitBildeinheitC = val ?? 0),
              laufzeitBildeinheitM: _laufzeitBildeinheitM,
              onChangedLaufzeitBildeinheitM: (val) => setState(() => _laufzeitBildeinheitM = val ?? 0),
              laufzeitBildeinheitY: _laufzeitBildeinheitY,
              onChangedLaufzeitBildeinheitY: (val) => setState(() => _laufzeitBildeinheitY = val ?? 0),
              laufzeitEntwicklerK: _laufzeitEntwicklerK,
              onChangedLaufzeitEntwicklerK: (val) => setState(() => _laufzeitEntwicklerK = val ?? 0),
              laufzeitEntwicklerC: _laufzeitEntwicklerC,
              onChangedLaufzeitEntwicklerC: (val) => setState(() => _laufzeitEntwicklerC = val ?? 0),
              laufzeitEntwicklerM: _laufzeitEntwicklerM,
              onChangedLaufzeitEntwicklerM: (val) => setState(() => _laufzeitEntwicklerM = val ?? 0),
              laufzeitEntwicklerY: _laufzeitEntwicklerY,
              onChangedLaufzeitEntwicklerY: (val) => setState(() => _laufzeitEntwicklerY = val ?? 0),
              laufzeitFixiereinheit: _laufzeitFixiereinheit,
              onChangedLaufzeitFixiereinheit: (val) => setState(() => _laufzeitFixiereinheit = val ?? 0),
              laufzeitTransferbelt: _laufzeitTransferbelt,
              onChangedLaufzeitTransferbelt: (val) => setState(() => _laufzeitTransferbelt = val ?? 0),
            ),
            const SizedBox(height: 22),

            TestergebnisseSection(
              fach1Controller: _fach1Controller,
              fach2Controller: _fach2Controller,
              fach3Controller: _fach3Controller,
              fach4Controller: _fach4Controller,
              bypassController: _bypassController,
              dokumenteneinzugController: _dokumenteneinzugController,
              duplexController: _duplexController,
              bemerkungController: _bemerkungController,
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: _saveGeraet,
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
