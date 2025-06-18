import 'package:flutter/material.dart';
import '../models/geraet.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nummerController = TextEditingController();
  final _seriennummerController = TextEditingController();

  final List<Geraet> _geraeteListe = [];
  final List<String> _modellOptionen = ['bizhub C250i', 'bizhub C300i'];
  final List<String> _jaNeinOptionen = ['ja', 'nein'];
  final List<String> _pdfTypen = ['A', 'B'];
  final List<String> _mitarbeiterListe = [
    'Patrick Heidrich',
    'Carsten Sobota',
    'Melanie Toffel',
    'Dirk Kraft'
  ];

  String? _ausgewaehltesModell;
  String? _iOption;
  String? _pdfTyp;
  String? _durchsuchbar;
  String? _mitarbeiter;

  void _hinzufuegen() {
    final neueNummer = _nummerController.text.trim();
    final neueSeriennummer = _seriennummerController.text.trim();

    if (neueNummer.isEmpty ||
        neueSeriennummer.isEmpty ||
        _ausgewaehltesModell == null ||
        _iOption == null ||
        _pdfTyp == null ||
        _durchsuchbar == null ||
        _mitarbeiter == null) {
      return;
    }

    if (_geraeteListe.any((g) => g.nummer == neueNummer)) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Doppelte Nummer'),
          content: Text('Die Gerätenummer "$neueNummer" wurde bereits eingegeben.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
        ),
      );
      return;
    }

    setState(() {
      _geraeteListe.add(Geraet(
        nummer: neueNummer,
        modell: _ausgewaehltesModell!,
        seriennummer: neueSeriennummer,
        iOption: _iOption!,
        pdfTyp: _pdfTyp!,
        durchsuchbar: _durchsuchbar!,
        mitarbeiter: _mitarbeiter!,
      ));
      _nummerController.clear();
      _seriennummerController.clear();
      _ausgewaehltesModell = null;
      _iOption = null;
      _pdfTyp = null;
      _durchsuchbar = null;
      _mitarbeiter = null;
    });
  }

  void _bearbeiten(int index) {
    final g = _geraeteListe[index];
    final nummerController = TextEditingController(text: g.nummer);
    final seriennummerController = TextEditingController(text: g.seriennummer);
    String modell = g.modell;
    String iOpt = g.iOption;
    String pdf = g.pdfTyp;
    String suchbar = g.durchsuchbar;
    String mitarbeiter = g.mitarbeiter;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Gerät bearbeiten'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: mitarbeiter,
                    items: _mitarbeiterListe.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) => setStateDialog(() => mitarbeiter = v!),
                    decoration: InputDecoration(labelText: 'Verantwortlicher Mitarbeiter'),
                  ),
                  TextField(
                    controller: nummerController,
                    decoration: InputDecoration(labelText: 'Gerätenummer'),
                  ),
                  DropdownButtonFormField<String>(
                    value: modell,
                    items: _modellOptionen.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (v) => setStateDialog(() => modell = v!),
                    decoration: InputDecoration(labelText: 'Modell'),
                  ),
                  TextField(
                    controller: seriennummerController,
                    decoration: InputDecoration(labelText: 'Seriennummer'),
                  ),
                  DropdownButtonFormField<String>(
                    value: iOpt,
                    items: _jaNeinOptionen.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) => setStateDialog(() => iOpt = v!),
                    decoration: InputDecoration(labelText: 'iOption'),
                  ),
                  DropdownButtonFormField<String>(
                    value: pdf,
                    items: _pdfTypen.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) => setStateDialog(() => pdf = v!),
                    decoration: InputDecoration(labelText: 'PDF-Typ'),
                  ),
                  DropdownButtonFormField<String>(
                    value: suchbar,
                    items: _jaNeinOptionen.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) => setStateDialog(() => suchbar = v!),
                    decoration: InputDecoration(labelText: 'Durchsuchbar'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Abbrechen')),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _geraeteListe[index] = Geraet(
                      nummer: nummerController.text,
                      modell: modell,
                      seriennummer: seriennummerController.text,
                      iOption: iOpt,
                      pdfTyp: pdf,
                      durchsuchbar: suchbar,
                      mitarbeiter: mitarbeiter,
                    );
                  });
                  Navigator.pop(context);
                },
                child: Text('Speichern'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _loeschen(int index) {
    setState(() {
      _geraeteListe.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gerätemanager')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _mitarbeiter,
              items: _mitarbeiterListe.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => _mitarbeiter = v),
              decoration: InputDecoration(labelText: 'Verantwortlicher Mitarbeiter'),
            ),
            TextField(
              controller: _nummerController,
              decoration: InputDecoration(labelText: 'Gerätenummer'),
            ),
            DropdownButtonFormField<String>(
              value: _ausgewaehltesModell,
              items: _modellOptionen.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (v) => setState(() => _ausgewaehltesModell = v),
              decoration: InputDecoration(labelText: 'Modell'),
            ),
            TextField(
              controller: _seriennummerController,
              decoration: InputDecoration(labelText: 'Seriennummer'),
            ),
            DropdownButtonFormField<String>(
              value: _iOption,
              items: _jaNeinOptionen.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => _iOption = v),
              decoration: InputDecoration(labelText: 'iOption'),
            ),
            DropdownButtonFormField<String>(
              value: _pdfTyp,
              items: _pdfTypen.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => _pdfTyp = v),
              decoration: InputDecoration(labelText: 'PDF-Typ'),
            ),
            DropdownButtonFormField<String>(
              value: _durchsuchbar,
              items: _jaNeinOptionen.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => _durchsuchbar = v),
              decoration: InputDecoration(labelText: 'Durchsuchbar'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _hinzufuegen,
              child: Text('Hinzufügen'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _geraeteListe.length,
                itemBuilder: (context, index) {
                  final g = _geraeteListe[index];
                  return ListTile(
                    title: Text('${g.nummer} – ${g.modell}'),
                    subtitle: Text(
                        'SN: ${g.seriennummer} | iOpt: ${g.iOption} | PDF: ${g.pdfTyp} | Suchbar: ${g.durchsuchbar} | MA: ${g.mitarbeiter}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit), onPressed: () => _bearbeiten(index)),
                        IconButton(icon: Icon(Icons.delete), onPressed: () => _loeschen(index)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
