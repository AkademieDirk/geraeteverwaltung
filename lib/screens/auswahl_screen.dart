import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'geraeteaufnahme/geraeteaufnahme_screen.dart';
import 'geraeteliste_screen.dart';
import 'aufbereitung_screen.dart';
import 'lagerverwaltung_screen.dart';
import 'historie_screen.dart';
import 'service_screen.dart';
import 'kunden_screen.dart';
import 'bestandsliste_screen.dart';
import '../models/geraet.dart';
import '../models/ersatzteil.dart';
import '../models/verbautes_teil.dart';
import '../models/kunde.dart';
import '../models/standort.dart';
import '../widgets/selection_box.dart';

class AuswahlScreen extends StatelessWidget {
  final List<Geraet> geraete;
  final List<Ersatzteil> ersatzteile;
  final Map<String, List<VerbautesTeil>> verbauteTeile;
  final List<Kunde> kunden;
  final List<Standort> standorte;

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

  final Future<void> Function(Kunde, Standort) onAddKunde;
  final Future<void> Function(Kunde) onUpdateKunde;
  final Future<void> Function(String) onDeleteKunde;

  final Future<void> Function(Standort) onAddStandort;
  final Future<void> Function(Standort) onUpdateStandort;
  final Future<void> Function(String) onDeleteStandort;

  final Future<void> Function(Geraet, Kunde, Standort) onAssignGeraet;
  final Future<void> Function(List<Kunde>) onImportKunden;

  const AuswahlScreen({
    Key? key,
    required this.geraete,
    required this.ersatzteile,
    required this.verbauteTeile,
    required this.kunden,
    required this.standorte,
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
    required this.onAddKunde,
    required this.onUpdateKunde,
    required this.onDeleteKunde,
    required this.onAddStandort,
    required this.onUpdateStandort,
    required this.onDeleteStandort,
    required this.onAssignGeraet,
    required this.onImportKunden,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> arbeitsablaeufe = [
      {'title': 'Geräteaufnahme', 'icon': Icons.add_box, 'color': Colors.blue, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => GeraeteAufnahmeScreen(onSave: onAddGeraet)))},
      {'title': 'Aufbereitung', 'icon': Icons.build, 'color': Colors.deepPurple, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => AufbereitungScreen(alleGeraete: geraete, alleErsatzteile: ersatzteile, verbauteTeile: verbauteTeile, onTeilVerbauen: onTeilVerbauen, onDeleteVerbautesTeil: onDeleteVerbautesTeil, onUpdateVerbautesTeil: onUpdateVerbautesTeil)))},
      {'title': 'Service', 'icon': Icons.miscellaneous_services, 'color': Colors.orange, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceScreen(alleGeraete: geraete, alleErsatzteile: ersatzteile, verbauteTeile: verbauteTeile, onTeilVerbauen: onTeilVerbauen, onDeleteVerbautesTeil: onDeleteVerbautesTeil, onUpdateVerbautesTeil: onUpdateVerbautesTeil)))},
    ];

    final List<Map<String, dynamic>> uebersichten = [
      // KORREKTUR: Der Aufruf übergibt jetzt alle benötigten Parameter
      {'title': 'Bestandsliste', 'icon': Icons.inventory, 'color': Colors.blueAccent, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => BestandslisteScreen(alleGeraete: geraete, onUpdate: onUpdateGeraet, onDelete: onDeleteGeraet, kunden: kunden, standorte: standorte, onAssign: onAssignGeraet)))},
      {'title': 'Geräteliste (Alle)', 'icon': Icons.list_alt, 'color': Colors.green, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => GeraeteListeScreen(geraete: geraete, onUpdate: onUpdateGeraet, onDelete: onDeleteGeraet, kunden: kunden, standorte: standorte, onAssign: onAssignGeraet)))},
      {'title': 'Historie', 'icon': Icons.history, 'color': Colors.teal, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistorieScreen(verbauteTeile: verbauteTeile, alleGeraete: geraete, onDelete: onDeleteVerbautesTeil, onUpdate: onUpdateVerbautesTeil)))},
    ];

    final List<Map<String, dynamic>> verwaltung = [
      {'title': 'Kundenverwaltung', 'icon': Icons.people, 'color': Colors.red.shade400, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => KundenScreen(kunden: kunden, standorte: standorte, onAdd: onAddKunde, onUpdate: onUpdateKunde, onDelete: onDeleteKunde, onAddStandort: onAddStandort, onUpdateStandort: onUpdateStandort, onDeleteStandort: onDeleteStandort, onImport: onImportKunden)))},
      {'title': 'Lagerverwaltung', 'icon': Icons.warehouse, 'color': Colors.brown, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => LagerverwaltungScreen(ersatzteile: ersatzteile, onAdd: onAddErsatzteil, onUpdate: onUpdateErsatzteil, onDelete: onDeleteErsatzteil, onTransfer: onTransfer, onBookIn: onBookIn)))},
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hauptmenü'),
          actions: [IconButton(icon: const Icon(Icons.logout), tooltip: 'Abmelden', onPressed: () async { await FirebaseAuth.instance.signOut(); })],
          bottom: const TabBar(tabs: [Tab(icon: Icon(Icons.work_history_outlined), text: "Arbeitsabläufe"), Tab(icon: Icon(Icons.table_chart_outlined), text: "Übersichten"), Tab(icon: Icon(Icons.admin_panel_settings_outlined), text: "Verwaltung")]),
        ),
        body: TabBarView(children: [_buildSection(arbeitsablaeufe, context), _buildSection(uebersichten, context), _buildSection(verwaltung, context)]),
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
            return SelectionBox(title: item['title'], icon: item['icon'], color: item['color'], onTap: item['onTap']);
          },
        ),
      ),
    );
  }
}
