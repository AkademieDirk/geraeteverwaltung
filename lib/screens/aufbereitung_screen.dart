import 'package:flutter/material.dart';

class AufbereitungScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aufbereitung'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aufbereitungs-Übersicht',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Beispielhafte Platzhalter-Karten für verschiedene Aufbereitungsoptionen
            _AufbereitungsCard(
              title: 'Geräte reinigen',
              icon: Icons.cleaning_services,
              color: Colors.blue.shade100,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Funktion „Geräte reinigen“ kommt noch!')),
                );
              },
            ),
            _AufbereitungsCard(
              title: 'Ersatzteile prüfen',
              icon: Icons.build_circle,
              color: Colors.green.shade100,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Funktion „Ersatzteile prüfen“ kommt noch!')),
                );
              },
            ),
            _AufbereitungsCard(
              title: 'Funktionskontrolle',
              icon: Icons.check_circle_outline,
              color: Colors.amber.shade100,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Funktion „Funktionskontrolle“ kommt noch!')),
                );
              },
            ),
            // Weitere Aufbereitungs-Karten kannst du hier ergänzen!
          ],
        ),
      ),
    );
  }
}

class _AufbereitungsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AufbereitungsCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: color,
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.black87),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
