import 'geraeteaufnahme/geraeteaufnahme_screen.dart';
import 'package:flutter/material.dart';
import 'geraeteliste_screen.dart';
import 'zubehoer_screen.dart';
import 'aufbereitung_screen.dart';
import '../models/geraet.dart';
import '../models/ersatzteil.dart';

class AuswahlScreen extends StatefulWidget {
  final List<Geraet> geraete;
  final List<Ersatzteil> ersatzteile;
  final void Function(int, Geraet) onEdit;
  final void Function(int) onDelete;
  final void Function(Geraet) onAdd;
  final void Function(List<Ersatzteil>) onErsatzteileChanged;

  const AuswahlScreen({
    Key? key,
    required this.geraete,
    required this.ersatzteile,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
    required this.onErsatzteileChanged,
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
                print('DEBUG: Zurück von Geräteaufnahme: $result');
                if (result != null) {
                  print('DEBUG: Gerät gespeichert! $result');
                  widget.onAdd(result);
                  setState(() {}); // Falls du eine Live-Aktualisierung willst
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
                      geraete: List.from(widget.geraete),
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
                      onErsatzteileChanged: (neueListe) {
                        setState(() {
                          widget.ersatzteile
                            ..clear()
                            ..addAll(neueListe);
                          widget.onErsatzteileChanged(widget.ersatzteile);
                        });
                      },
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
                  MaterialPageRoute(builder: (_) => AufbereitungScreen()),
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
