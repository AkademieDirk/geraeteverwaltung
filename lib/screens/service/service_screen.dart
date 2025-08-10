import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/geraet.dart';
import '../../models/ersatzteil.dart';
import '../../models/serviceeintrag.dart';
import 'serviceeintrag_screen.dart';

class ServiceScreen extends StatefulWidget {
  final List<Geraet> alleGeraete;
  final List<Ersatzteil> alleErsatzteile;
  final List<Serviceeintrag> alleServiceeintraege;
  final Future<void> Function(Serviceeintrag) onAddServiceeintrag;
  final Future<void> Function(Serviceeintrag) onUpdateServiceeintrag;
  final Future<void> Function(String) onDeleteServiceeintrag;
  // --- KORRIGIERTE SIGNATUR ---
  final Future<void> Function(String, Ersatzteil, String) onTeilVerbauen;

  const ServiceScreen({
    Key? key,
    required this.alleGeraete,
    required this.alleErsatzteile,
    required this.alleServiceeintraege,
    required this.onAddServiceeintrag,
    required this.onUpdateServiceeintrag,
    required this.onDeleteServiceeintrag,
    required this.onTeilVerbauen,
  }) : super(key: key);

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  Geraet? _selectedGeraet;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _deleteServiceeintrag(Serviceeintrag eintrag) async {
    final sicher = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eintrag löschen?'),
        content: Text('Soll der Serviceeintrag vom ${DateFormat('dd.MM.yyyy').format(eintrag.datum.toDate())} wirklich gelöscht werden?'),
        actions: [
          TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.pop(ctx, false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Löschen'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (sicher == true) {
      await widget.onDeleteServiceeintrag(eintrag.id);
    }
  }

  void _navigateToServiceeintragScreen({Serviceeintrag? eintrag}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceeintragScreen(
      geraet: _selectedGeraet!,
      initialEintrag: eintrag,
      alleErsatzteile: widget.alleErsatzteile,
      onSave: eintrag != null ? widget.onUpdateServiceeintrag : widget.onAddServiceeintrag,
      onTeilVerbauen: widget.onTeilVerbauen,
    )));
  }

  Widget _buildGeraeteAuswahl() {
    List<Geraet> gefilterteGeraete = widget.alleGeraete;
    if (_searchTerm.isNotEmpty) {
      final s = _searchTerm.toLowerCase();
      gefilterteGeraete = widget.alleGeraete.where((g) =>
      g.seriennummer.toLowerCase().contains(s) ||
          g.modell.toLowerCase().contains(s) ||
          (g.kundeName ?? '').toLowerCase().contains(s) ||
          (g.nummer.isNotEmpty && g.nummer.toLowerCase().contains(s))
      ).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Gerät suchen (SN, Modell, Kunde, Lagernr.)',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _searchTerm.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchTerm = '');
                },
              )
                  : null,
            ),
            onChanged: (value) => setState(() => _searchTerm = value),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: gefilterteGeraete.length,
            itemBuilder: (ctx, index) {
              final geraet = gefilterteGeraete[index];
              final isLager = geraet.status == 'Im Lager';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isLager ? Colors.blueGrey : Colors.green,
                    child: Icon(isLager ? Icons.warehouse : Icons.person, color: Colors.white),
                  ),
                  title: Text('${geraet.modell} (SN: ${geraet.seriennummer})'),
                  subtitle: Text(isLager ? 'Status: Im Lager (Nr: ${geraet.nummer})' : 'Kunde: ${geraet.kundeName ?? 'N/A'}'),
                  onTap: () {
                    setState(() {
                      _selectedGeraet = geraet;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDetailAnsicht() {
    final geraet = _selectedGeraet!;
    final serviceHistorie = widget.alleServiceeintraege
        .where((e) => e.geraeteId == geraet.id)
        .toList();
    serviceHistorie.sort((a, b) => b.datum.compareTo(a.datum));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.grey.shade100,
            child: ListTile(
              title: Text(geraet.modell, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text('SN: ${geraet.seriennummer}\nKunde: ${geraet.kundeName ?? 'N/A'}'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Neuen Serviceeintrag erstellen'),
              onPressed: () => _navigateToServiceeintragScreen(),
            ),
          ),
          const Divider(height: 32),
          Text('Service-Historie', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Expanded(
            child: serviceHistorie.isEmpty
                ? const Center(child: Text('Für dieses Gerät gibt es keine Serviceeinträge.'))
                : ListView.builder(
              itemCount: serviceHistorie.length,
              itemBuilder: (ctx, index) {
                final eintrag = serviceHistorie[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    leading: CircleAvatar(child: Text((serviceHistorie.length - index).toString())),
                    title: Text('Eintrag vom ${DateFormat('dd.MM.yyyy').format(eintrag.datum.toDate())}'),
                    subtitle: Text('Mitarbeiter: ${eintrag.verantwortlicherMitarbeiter}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_note, color: Colors.orange),
                          tooltip: 'Eintrag bearbeiten',
                          onPressed: () => _navigateToServiceeintragScreen(eintrag: eintrag),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          tooltip: 'Eintrag löschen',
                          onPressed: () => _deleteServiceeintrag(eintrag),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ausgeführte Arbeiten:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(eintrag.ausgefuehrteArbeiten),
                            if (eintrag.verbauteTeile.isNotEmpty) ...[
                              const Divider(height: 24),
                              const Text('Bei diesem Service verbaute Teile:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...eintrag.verbauteTeile.map((teil) => Text('- ${teil.ersatzteil.bezeichnung} (ArtNr: ${teil.ersatzteil.artikelnummer})')),
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedGeraet == null ? 'Service: Gerät auswählen' : 'Service-Historie'),
        actions: [
          if (_selectedGeraet != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedGeraet = null;
                  _searchController.clear();
                  _searchTerm = '';
                });
              },
              child: const Text('Gerät wechseln', style: TextStyle(color: Colors.white)),
            )
        ],
      ),
      body: _selectedGeraet == null
          ? _buildGeraeteAuswahl()
          : _buildServiceDetailAnsicht(),
    );
  }
}