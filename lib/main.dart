import 'package:flutter/material.dart';
import 'screens/auswahl_screen.dart';
import 'models/geraet.dart';
import 'models/ersatzteil.dart';

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

  // Geräte-Callbacks
  void addGeraet(Geraet g) => setState(() => geraete.add(g));
  void editGeraet(int i, Geraet g) => setState(() => geraete[i] = g);
  void deleteGeraet(int i) => setState(() => geraete.removeAt(i));

  // Ersatzteile-Callback
  void setErsatzteile(List<Ersatzteil> neueListe) =>
      setState(() => ersatzteile = neueListe);

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
      ),
    );
  }
}
