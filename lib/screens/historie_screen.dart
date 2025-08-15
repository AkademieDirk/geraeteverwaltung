import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/verbautes_teil.dart';
import '../models/geraet.dart';
import '../models/serviceeintrag.dart';

class HistorieScreen extends StatefulWidget {
  final Map<String, List<VerbautesTeil>> verbauteTeile;
  final List<Geraet> alleGeraete;
  final List<Serviceeintrag> alleServiceeintraege;
  final Future<void> Function(String seriennummer, VerbautesTeil teil) onDelete;
  final Future<void> Function(String seriennummer, VerbautesTeil teil) onUpdate;
  final Future<void> Function(String) onDeleteServiceeintrag;

  const HistorieScreen({
    Key? key,
    required this.verbauteTeile,
    required this.alleGeraete,
    required this.alleServiceeintraege,
    required this.onDelete,
    required this.onUpdate,
    required this.onDeleteServiceeintrag,
  }) : super(key: key);

  @override
  State<HistorieScreen> createState() => _HistorieScreenState();
}

class _HistorieScreenState extends State<HistorieScreen> {
  final TextEditingController _seriennummerController = TextEditingController();
  List<VerbautesTeil> _aufbereitungsteile = [];
  List<Serviceeintrag> _serviceeintraege = [];

  double _gesamtkosten = 0.0;
  String _angezeigteSeriennummer = '';
  List<String> _suchergebnisse = [];
  Geraet? _gefundenesGeraet;

  @override
  void dispose() {
    _seriennummerController.dispose();
    super.dispose();
  }

  void _sucheHistorie() {
    final suchbegriff = _seriennummerController.text.trim().toLowerCase();

    setState(() {
      _aufbereitungsteile = [];
      _serviceeintraege = [];
      _angezeigteSeriennummer = '';
      _gesamtkosten = 0.0;
      _suchergebnisse = [];
      _gefundenesGeraet = null;
    });

    if (suchbegriff.isEmpty) return;

    final passendeGeraete = widget.alleGeraete.where((geraet) {
      final seriennummerMatch = geraet.seriennummer.toLowerCase().contains(suchbegriff);
      final kundenNameMatch = geraet.kundeName?.toLowerCase().contains(suchbegriff) ?? false;
      return seriennummerMatch || kundenNameMatch;
    }).toList();

    final treffer = passendeGeraete.map((g) => g.id).toSet().where((geraeteId) {
      final geraet = widget.alleGeraete.firstWhere((g) => g.id == geraeteId);
      final hatTeile = widget.verbauteTeile.containsKey(geraet.seriennummer) && widget.verbauteTeile[geraet.seriennummer]!.isNotEmpty;
      final hatService = widget.alleServiceeintraege.any((e) => e.geraeteId == geraeteId);
      return hatTeile || hatService;
    }).map((geraeteId) => widget.alleGeraete.firstWhere((g) => g.id == geraeteId).seriennummer).toList();


    if (treffer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Für diesen Suchbegriff wurde keine Historie gefunden.')),
      );
    } else if (treffer.length == 1) {
      _zeigeHistorieFuer(treffer.first);
    } else {
      setState(() {
        _suchergebnisse = treffer;
      });
    }
  }

  void _zeigeHistorieFuer(String seriennummer) {
    Geraet? zugehoerigesGeraet;
    try {
      zugehoerigesGeraet = widget.alleGeraete.firstWhere((g) => g.seriennummer == seriennummer);
    } catch(e) {
      zugehoerigesGeraet = null;
    }

    if (zugehoerigesGeraet == null) return;

    final serviceEintraegeGefiltert = widget.alleServiceeintraege.where((e) => e.geraeteId == zugehoerigesGeraet!.id).toList();
    serviceEintraegeGefiltert.sort((a, b) => b.datum.compareTo(a.datum));

    final alleVerbautenTeile = widget.verbauteTeile[seriennummer] ?? [];
    final teileKosten = alleVerbautenTeile.fold(0.0, (total, item) => total + (item.tatsaechlicherPreis));

    final inServiceVerbauteTeileIDs = serviceEintraegeGefiltert.expand((e) => e.verbauteTeile).map((t) => t.id).toSet();
    final aufbereitungsteileGefiltert = alleVerbautenTeile.where((t) => !inServiceVerbauteTeileIDs.contains(t.id)).toList();

    setState(() {
      _serviceeintraege = serviceEintraegeGefiltert;
      _aufbereitungsteile = aufbereitungsteileGefiltert;
      _gesamtkosten = teileKosten;
      _angezeigteSeriennummer = seriennummer;
      _suchergebnisse = [];
      _seriennummerController.text = seriennummer;
      _gefundenesGeraet = zugehoerigesGeraet;
    });
  }

  void _loescheServiceeintrag(Serviceeintrag eintrag) async {
    final sicher = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Serviceeintrag löschen?'),
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
      for (var teil in eintrag.verbauteTeile) {
        await widget.onDelete(_angezeigteSeriennummer, teil);
      }
      await widget.onDeleteServiceeintrag(eintrag.id);
      _zeigeHistorieFuer(_angezeigteSeriennummer);
    }
  }

  void _loescheVerbautesTeil(VerbautesTeil teil) async {
    final sicher = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Eintrag löschen?'), content: Text('Soll der Eintrag "${teil.ersatzteil.bezeichnung}" wirklich aus der Historie gelöscht werden?'), actions: [TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.pop(ctx, false)), TextButton(child: Text('Löschen', style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx, true))]));
    if (sicher == true && mounted) {
      try {
        await widget.onDelete(_angezeigteSeriennummer, teil);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eintrag erfolgreich gelöscht.'), backgroundColor: Colors.green));
        _zeigeHistorieFuer(_angezeigteSeriennummer);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler beim Löschen: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }

  void _bearbeiteVerbautesTeilDialog(VerbautesTeil teil) {
    final preisController = TextEditingController(text: (teil.tatsaechlicherPreis / teil.menge).toStringAsFixed(2));
    final mengeController = TextEditingController(text: teil.menge.toString());
    final bemerkungController = TextEditingController(text: teil.bemerkung);

    showDialog(context: context, builder: (context) => AlertDialog(title: Text('Eintrag bearbeiten'), content: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(teil.ersatzteil.bezeichnung, style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(height: 16),
      TextField(controller: preisController, decoration: InputDecoration(labelText: 'Preis pro Stück', border: OutlineInputBorder(), suffixText: '€'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
      SizedBox(height: 16),
      TextField(controller: mengeController, decoration: InputDecoration(labelText: 'Menge', border: OutlineInputBorder()), keyboardType: TextInputType.number),
      SizedBox(height: 16),
      TextField(controller: bemerkungController, decoration: InputDecoration(labelText: 'Bemerkung', border: OutlineInputBorder()), maxLines: 2)
    ]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Abbrechen')), ElevatedButton(onPressed: () async {
      final neuerPreisProStueck = double.tryParse(preisController.text.replaceAll(',', '.')) ?? (teil.tatsaechlicherPreis / teil.menge);
      final neueMenge = int.tryParse(mengeController.text) ?? teil.menge;
      final geandertesTeil = VerbautesTeil(id: teil.id, ersatzteil: teil.ersatzteil, installationsDatum: teil.installationsDatum, tatsaechlicherPreis: neuerPreisProStueck * neueMenge, bemerkung: bemerkungController.text.trim(), herkunftslager: teil.herkunftslager, menge: neueMenge);
      await widget.onUpdate(_angezeigteSeriennummer, geandertesTeil);
      Navigator.pop(context);
      _zeigeHistorieFuer(_angezeigteSeriennummer);
    }, child: Text('Speichern'))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geräte-Historie')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _seriennummerController,
                  decoration: InputDecoration(
                      labelText: 'Suche nach Seriennummer oder Kunde',
                      hintText: 'Teileingabe ist möglich...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _sucheHistorie, tooltip: 'Historie suchen')),
                  onSubmitted: (_) => _sucheHistorie(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _suchergebnisse.isNotEmpty ? _buildSuchergebnisListe() : _buildHistorienAnsicht(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuchergebnisListe() {
    return Column(
      key: const ValueKey('ergebnisliste'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text('${_suchergebnisse.length} Treffer gefunden. Bitte auswählen:', style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _suchergebnisse.length,
            itemBuilder: (context, index) {
              final seriennummer = _suchergebnisse[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(title: Text(seriennummer), leading: const Icon(Icons.receipt_long), trailing: const Icon(Icons.arrow_forward_ios), onTap: () => _zeigeHistorieFuer(seriennummer)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistorienAnsicht() {
    if (_angezeigteSeriennummer.isEmpty) {
      return const Center(key: ValueKey('leere_ansicht'), child: Text('Bitte eine Seriennummer oder einen Kunden eingeben.'));
    }
    if (_aufbereitungsteile.isEmpty && _serviceeintraege.isEmpty) {
      return Center(key: ValueKey('keine_eintraege'), child: Text('Für die Seriennummer $_angezeigteSeriennummer wurden keine Einträge gefunden.'));
    }
    return Column(
      key: ValueKey(_angezeigteSeriennummer),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Gesamtkosten Teile:', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)), Text('${_gesamtkosten.toStringAsFixed(2)} €', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))]),
          ),
        ),
        const SizedBox(height: 16),
        Text('Historie für: $_angezeigteSeriennummer', style: Theme.of(context).textTheme.titleLarge),
        if (_gefundenesGeraet?.kundeName != null && _gefundenesGeraet!.kundeName!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text('Kunde: ${_gefundenesGeraet!.kundeName}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700)),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: [
              if (_aufbereitungsteile.isNotEmpty)
                Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.inventory_2, color: Colors.blueGrey),
                    title: Text('Teile verbaut (${_aufbereitungsteile.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    children: _aufbereitungsteile.map((teil) {
                      return ExpansionTile(
                        leading: const SizedBox(width: 24),
                        title: Text('${teil.menge}x ${teil.ersatzteil.bezeichnung}'),
                        subtitle: Text('Eingebaut am: ${DateFormat('dd.MM.yyyy').format(teil.installationsDatum)}'),
                        trailing: Text('${teil.tatsaechlicherPreis.toStringAsFixed(2)} €'),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit_note),
                                label: const Text('Bearbeiten'),
                                onPressed: () => _bearbeiteVerbautesTeilDialog(teil),
                                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Löschen'),
                                onPressed: () => _loescheVerbautesTeil(teil),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                              ),
                            ],
                          )
                        ],
                      );
                    }).toList(),
                  ),
                ),

              if (_serviceeintraege.isNotEmpty)
                ..._serviceeintraege.map((eintrag) {
                  return Card(
                    margin: const EdgeInsets.only(top: 8),
                    child: ExpansionTile(
                      leading: const Icon(Icons.miscellaneous_services, color: Colors.orange),
                      title: Text('Service vom ${DateFormat('dd.MM.yyyy').format(eintrag.datum.toDate())}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(eintrag.verantwortlicherMitarbeiter),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _loescheServiceeintrag(eintrag),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ausgeführte Arbeiten:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(eintrag.ausgefuehrteArbeiten.isEmpty ? 'Keine Beschreibung.' : eintrag.ausgefuehrteArbeiten),
                              if (eintrag.verbauteTeile.isNotEmpty) ...[
                                const Divider(height: 20),
                                const Text('Verbaute Teile bei diesem Service:', style: TextStyle(fontWeight: FontWeight.bold)),
                                ...eintrag.verbauteTeile.map((teil) {
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.settings, size: 18),
                                    title: Text('${teil.menge}x ${teil.ersatzteil.bezeichnung}'),
                                    trailing: Text('${teil.tatsaechlicherPreis.toStringAsFixed(2)} €'),
                                  );
                                }).toList()
                              ]
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}