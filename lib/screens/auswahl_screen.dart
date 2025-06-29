import 'package:flutter/material.dart';
import 'geraeteaufnahme/geraeteaufnahme_screen.dart';
import 'geraeteliste_screen.dart';
import 'aufbereitung_screen.dart';
import 'lagerverwaltung_screen.dart';
import 'historie_screen.dart';
import 'service_screen.dart';
import 'zubehoer_screen.dart';
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

  final Future<void> Function(String, Ersatzteil, String) onTeilVerbauen;
  final Future<void> Function(String, VerbautesTeil) onDeleteVerbautesTeil;
  final Future<void> Function(String, VerbautesTeil) onUpdateVerbautesTeil;
  final Future<void> Function(Ersatzteil, String, String, int) onTransfer;
  final Future<void> Function(Ersatzteil, String, int) onBookIn;

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
    required this.onTransfer,
    required this.onBookIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Listen für die einzelnen Sektionen ---
    final List<Map<String, dynamic>> arbeitsablaeufe = [
      {'title': 'Geräteaufnahme', 'icon': Icons.add_box, 'color': Colors.blue, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => GeraeteAufnahmeScreen(onSave: onAddGeraet)))},
      {'title': 'Aufbereitung', 'icon': Icons.build, 'color': Colors.deepPurple, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => AufbereitungScreen(alleGeraete: geraete, alleErsatzteile: ersatzteile, verbauteTeile: verbauteTeile, onTeilVerbauen: onTeilVerbauen, onDeleteVerbautesTeil: onDeleteVerbautesTeil, onUpdateVerbautesTeil: onUpdateVerbautesTeil)))},
      {'title': 'Service', 'icon': Icons.miscellaneous_services, 'color': Colors.orange, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceScreen(alleGeraete: geraete, alleErsatzteile: ersatzteile, verbauteTeile: verbauteTeile, onTeilVerbauen: onTeilVerbauen, onDeleteVerbautesTeil: onDeleteVerbautesTeil, onUpdateVerbautesTeil: onUpdateVerbautesTeil)))},
    ];

    final List<Map<String, dynamic>> uebersichten = [
      {'title': 'Geräteliste', 'icon': Icons.list_alt, 'color': Colors.green, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => GeraeteListeScreen(geraete: geraete, onUpdate: onUpdateGeraet, onDelete: onDeleteGeraet)))},
      {'title': 'Historie', 'icon': Icons.history, 'color': Colors.teal, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistorieScreen(verbauteTeile: verbauteTeile, onDelete: onDeleteVerbautesTeil, onUpdate: onUpdateVerbautesTeil)))},
    ];

    // --- GEÄNDERT: "Verwaltung" enthält jetzt die einzelnen Lager ---
    final List<Map<String, dynamic>> verwaltung = [
      {'title': 'Stammdaten & Umbuchung', 'icon': Icons.inventory_2, 'color': Colors.brown, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => LagerverwaltungScreen(ersatzteile: ersatzteile, onAdd: onAddErsatzteil, onUpdate: onUpdateErsatzteil, onDelete: onDeleteErsatzteil, onTransfer: onTransfer, onBookIn: onBookIn)))},
      {'title': 'Hauptlager', 'icon': Icons.home_work_outlined, 'color': Colors.blueGrey, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => ZubehoerScreen(ersatzteile: ersatzteile, angezeigtesLager: 'Hauptlager', onAdd: onAddErsatzteil, onUpdate: onUpdateErsatzteil, onDelete: onDeleteErsatzteil)))},
      {'title': 'Fahrzeug Patrick', 'icon': Icons.directions_car, 'color': Colors.indigo, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => ZubehoerScreen(ersatzteile: ersatzteile, angezeigtesLager: 'Fahrzeug Patrick', onAdd: onAddErsatzteil, onUpdate: onUpdateErsatzteil, onDelete: onDeleteErsatzteil)))},
      {'title': 'Fahrzeug Melanie', 'icon': Icons.directions_car, 'color': Colors.pink.shade300, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => ZubehoerScreen(ersatzteile: ersatzteile, angezeigtesLager: 'Fahrzeug Melanie', onAdd: onAddErsatzteil, onUpdate: onUpdateErsatzteil, onDelete: onDeleteErsatzteil)))},
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.work_history_outlined), text: "Arbeitsabläufe"),
              Tab(icon: Icon(Icons.table_chart_outlined), text: "Übersichten"),
              Tab(icon: Icon(Icons.admin_panel_settings_outlined), text: "Verwaltung"),
            ],
          ),
          title: const Text('Hauptmenü'),
        ),
        body: TabBarView(
          children: [
            _buildSection(arbeitsablaeufe, context),
            _buildSection(uebersichten, context),
            _buildSection(verwaltung, context),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(List<Map<String, dynamic>> items, BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 5 : (MediaQuery.of(context).size.width > 600 ? 4 : 2),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: items.length,
          itemBuilder: (ctx, index) {
            final item = items[index];
            return _SelectionBox(
              title: item['title'],
              icon: item['icon'],
              color: item['color'],
              onTap: item['onTap'],
            );
          },
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: color, width: 2)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
