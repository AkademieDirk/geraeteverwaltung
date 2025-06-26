import 'package:flutter/material.dart';
import 'geraeteaufnahme/geraeteaufnahme_screen.dart';
import 'geraeteliste_screen.dart';
import 'zubehoer_screen.dart';
import 'aufbereitung_screen.dart';
import 'historie_screen.dart';
import '../models/geraet.dart';
import '../models/ersatzteil.dart';
import '../models/verbautes_teil.dart'; // Wichtig: Import des neuen Modells

class AuswahlScreen extends StatefulWidget {
  final List<Geraet> geraete;
  final List<Ersatzteil> ersatzteile;
  // --- GEÄNDERT: Akzeptiert jetzt 'VerbautesTeil'-Objekte ---
  final Map<String, List<VerbautesTeil>> verbauteTeile;

  final void Function(int, Geraet) onEdit;
  final void Function(int) onDelete;
  final void Function(Geraet) onAdd;
  final void Function(List<Ersatzteil>) onErsatzteileChanged;
  final void Function(String, Ersatzteil) onTeilVerbauen;

  const AuswahlScreen({
    Key? key,
    required this.geraete,
    required this.ersatzteile,
    required this.verbauteTeile,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
    required this.onErsatzteileChanged,
    required this.onTeilVerbauen,
  }) : super(key: key);

  @override
  State<AuswahlScreen> createState() => _AuswahlScreenState();
}

class _AuswahlScreenState extends State<AuswahlScreen> {
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
              title: 'Geräteaufnahme',
              icon: Icons.add_box,
              color: Colors.blue,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GeraeteAufnahmeScreen(
                      vorhandeneGeraete: List.from(widget.geraete),
                    ),
                  ),
                );
                if (result != null) {
                  widget.onAdd(result);
                }
              },
            ),
            _SelectionBox(
              title: 'Geräteliste',
              icon: Icons.list_alt,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GeraeteListeScreen(
                      geraete: widget.geraete,
                      onEdit: widget.onEdit,
                      onDelete: widget.onDelete,
                    ),
                  ),
                );
              },
            ),
            _SelectionBox(
              title: 'Zubehör',
              icon: Icons.inventory_2,
              color: Colors.brown,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ZubehoerScreen(
                      ersatzteile: widget.ersatzteile,
                      onErsatzteileChanged: widget.onErsatzteileChanged,
                    ),
                  ),
                );
              },
            ),
            _SelectionBox(
              title: 'Aufbereitung',
              icon: Icons.build,
              color: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AufbereitungScreen(
                      alleGeraete: widget.geraete,
                      alleErsatzteile: widget.ersatzteile,
                      // GEÄNDERT: Übergibt die korrekten Daten
                      verbauteTeile: widget.verbauteTeile,
                      onTeilVerbauen: widget.onTeilVerbauen,
                    ),
                  ),
                );
              },
            ),
            _SelectionBox(
              title: 'Historie',
              icon: Icons.history,
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistorieScreen(
                      verbauteTeile: widget.verbauteTeile,
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

  const _SelectionBox({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 46),
              SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
