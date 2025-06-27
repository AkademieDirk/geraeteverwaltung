import 'package:flutter/material.dart';
import 'geraeteaufnahme/geraeteaufnahme_screen.dart';
import 'geraeteliste_screen.dart';
import 'aufbereitung_screen.dart';
import 'lagerverwaltung_screen.dart';
import 'historie_screen.dart';
import '../models/geraet.dart';
import '../models/ersatzteil.dart';
import '../models/verbautes_teil.dart';

class AuswahlScreen extends StatelessWidget {
  final List<Geraet> geraete;
  final List<Ersatzteil> ersatzteile;
  final Map<String, List<VerbautesTeil>> verbauteTeile;

  final Future<void> Function(Geraet) onAddGeraet;
  final Future<void> Function(Geraet) onUpdateGeraet;
  final Future<void> Function(String) onDeleteGeraet;

  final Future<void> Function(Ersatzteil) onAddErsatzteil;
  final Future<void> Function(Ersatzteil) onUpdateErsatzteil;
  final Future<void> Function(String) onDeleteErsatzteil;

  final Future<void> Function(String, Ersatzteil) onTeilVerbauen;
  final Future<void> Function(String, VerbautesTeil) onDeleteVerbautesTeil;
  final Future<void> Function(String, VerbautesTeil) onUpdateVerbautesTeil;

  const AuswahlScreen({
    Key? key,
    required this.geraete,
    required this.ersatzteile,
    required this.verbauteTeile,
    required this.onAddGeraet,
    required this.onUpdateGeraet,
    required this.onDeleteGeraet,
    required this.onAddErsatzteil,
    required this.onUpdateErsatzteil,
    required this.onDeleteErsatzteil,
    required this.onTeilVerbauen,
    required this.onDeleteVerbautesTeil,
    required this.onUpdateVerbautesTeil,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Geräteverwaltung - Auswahl')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
          crossAxisSpacing: 30,
          mainAxisSpacing: 30,
          children: [
            _SelectionBox(
              title: 'Geräteaufnahme', icon: Icons.add_box, color: Colors.blue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GeraeteAufnahmeScreen(onSave: onAddGeraet))),
            ),
            _SelectionBox(
              title: 'Geräteliste', icon: Icons.list_alt, color: Colors.green,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GeraeteListeScreen(geraete: geraete, onUpdate: onUpdateGeraet, onDelete: onDeleteGeraet))),
            ),
            _SelectionBox(
              title: 'Aufbereitung', icon: Icons.build, color: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AufbereitungScreen(
                      alleGeraete: geraete,
                      alleErsatzteile: ersatzteile,
                      verbauteTeile: verbauteTeile,
                      onTeilVerbauen: onTeilVerbauen,
                      onDeleteVerbautesTeil: onDeleteVerbautesTeil,
                      onUpdateVerbautesTeil: onUpdateVerbautesTeil,
                    ),
                  ),
                );
              },
            ),
            _SelectionBox(
              title: 'Lagerverwaltung', icon: Icons.warehouse, color: Colors.brown,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LagerverwaltungScreen(ersatzteile: ersatzteile, onAdd: onAddErsatzteil, onUpdate: onUpdateErsatzteil, onDelete: onDeleteErsatzteil))),
            ),
            _SelectionBox(
              title: 'Historie', icon: Icons.history, color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistorieScreen(
                      verbauteTeile: verbauteTeile,
                      onDelete: onDeleteVerbautesTeil,
                      onUpdate: onUpdateVerbautesTeil,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SelectionBox({Key? key, required this.title, required this.icon, required this.color, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: color, width: 2)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 46),
              const SizedBox(height: 14),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
