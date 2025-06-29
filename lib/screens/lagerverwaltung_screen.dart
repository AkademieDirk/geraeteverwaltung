import 'package:flutter/material.dart';
import '../models/ersatzteil.dart';
import 'zubehoer_screen.dart';
import 'umbuchung_screen.dart';
import 'wareneingang_screen.dart';

class LagerverwaltungScreen extends StatelessWidget {
  final List<Ersatzteil> ersatzteile;
  final Future<void> Function(Ersatzteil) onAdd;
  final Future<void> Function(Ersatzteil) onUpdate;
  final Future<void> Function(String) onDelete;
  final Future<void> Function(Ersatzteil, String, String, int) onTransfer;
  final Future<void> Function(Ersatzteil, String, int) onBookIn;

  const LagerverwaltungScreen({
    Key? key,
    required this.ersatzteile,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
    required this.onTransfer,
    required this.onBookIn,
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
          crossAxisCount: MediaQuery.of(context).size.width > 900 ? 5 : 2,
          crossAxisSpacing: 30,
          mainAxisSpacing: 30,
          children: [
            _SelectionBox(
              title: 'Stammdaten pflegen',
              icon: Icons.inventory_2,
              color: Colors.brown,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ZubehoerScreen(
                  ersatzteile: ersatzteile,
                  onAdd: onAdd,
                  onUpdate: onUpdate,
                  onDelete: onDelete,
                )));
              },
            ),
            _SelectionBox(
              title: 'Wareneingang',
              icon: Icons.add_shopping_cart,
              color: Colors.green,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => WareneingangScreen(
                  alleErsatzteile: ersatzteile,
                  onBookIn: onBookIn,
                )));
              },
            ),
            _SelectionBox(
              title: 'Umbuchen',
              icon: Icons.sync_alt,
              color: Colors.deepOrange,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => UmbuchungScreen(
                  alleErsatzteile: ersatzteile,
                  onTransfer: onTransfer,
                )));
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
