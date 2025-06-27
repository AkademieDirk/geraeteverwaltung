import 'package:flutter/material.dart';
import '../models/ersatzteil.dart';
import 'zubehoer_screen.dart'; // Führt zum umbenannten "Ersatzteile Screen"

class LagerverwaltungScreen extends StatelessWidget {
  final List<Ersatzteil> ersatzteile;
  // GEÄNDERT: Nimmt die neuen Firestore-Funktionen entgegen
  final Future<void> Function(Ersatzteil) onAdd;
  final Future<void> Function(Ersatzteil) onUpdate;
  final Future<void> Function(String) onDelete;

  const LagerverwaltungScreen({
    Key? key,
    required this.ersatzteile,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lagerverwaltung'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
          crossAxisSpacing: 30,
          mainAxisSpacing: 30,
          children: [
            // Kachel, die zum Ersatzteile-Screen führt
            _SelectionBox(
              title: 'Ersatzteile verwalten',
              icon: Icons.inventory_2,
              color: Colors.brown,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // GEÄNDERT: Übergibt die neuen Funktionen an den ZubehoerScreen
                    builder: (_) => ZubehoerScreen(
                      ersatzteile: ersatzteile,
                      onAdd: onAdd,
                      onUpdate: onUpdate,
                      onDelete: onDelete,
                    ),
                  ),
                );
              },
            ),
            // Hier können später weitere Kacheln für die Lagerverwaltung hinzukommen
          ],
        ),
      ),
    );
  }
}

// Dies ist eine Kopie der _SelectionBox aus dem AuswahlScreen für ein einheitliches Design.
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
              const SizedBox(height: 14),
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
