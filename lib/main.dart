import 'package:flutter/material.dart';
import 'screens/auswahl_screen.dart';
import 'models/geraet.dart';
import 'models/ersatzteil.dart';
// NEU: Importieren des neuen Modells
import 'models/verbautes_teil.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Geraet> geraete = [];
  List<Ersatzteil> ersatzteile = [];
  // --- GEÄNDERT: Speichert jetzt 'VerbautesTeil'-Objekte ---
  Map<String, List<VerbautesTeil>> _verbauteTeile = {};

  // Geräte-Callbacks
  void addGeraet(Geraet g) => setState(() => geraete.add(g));
  void editGeraet(int i, Geraet g) => setState(() => geraete[i] = g);
  void deleteGeraet(int i) => setState(() => geraete.removeAt(i));

  // Ersatzteile-Callback
  void setErsatzteile(List<Ersatzteil> neueListe) =>
      setState(() => ersatzteile = neueListe);

  // --- GEÄNDERT: Funktion erstellt jetzt ein 'VerbautesTeil' mit aktuellem Datum ---
  void _handleTeilVerbauen(String seriennummer, Ersatzteil teil) {
    // Erstellt ein neues Objekt, das das Teil und das aktuelle Datum kapselt.
    final verbautesTeil = VerbautesTeil(
      ersatzteil: teil,
      installationsDatum: DateTime.now(),
    );

    setState(() {
      if (!_verbauteTeile.containsKey(seriennummer)) {
        _verbauteTeile[seriennummer] = [];
      }
      _verbauteTeile[seriennummer]!.add(verbautesTeil);
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerätemanager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuswahlScreen(
        geraete: geraete,
        ersatzteile: ersatzteile,
        onAdd: addGeraet,
        onEdit: editGeraet,
        onDelete: deleteGeraet,
        onErsatzteileChanged: setErsatzteile,
        // --- GEÄNDERT: Übergibt die neue Datenstruktur ---
        verbauteTeile: _verbauteTeile,
        onTeilVerbauen: _handleTeilVerbauen,
      ),
    );
  }
}
