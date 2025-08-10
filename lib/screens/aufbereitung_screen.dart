import 'package:flutter/material.dart';
import '../models/geraet.dart';
import '../models/ersatzteil.dart';
import '../models/verbautes_teil.dart';
import '../models/serviceeintrag.dart';
import 'historie_screen.dart';

class AufbereitungScreen extends StatefulWidget {
  final List<Geraet> alleGeraete;
  final List<Ersatzteil> alleErsatzteile;
  final Map<String, List<VerbautesTeil>> verbauteTeile;
  final List<Serviceeintrag> alleServiceeintraege;
  final Future<void> Function(String, Ersatzteil, String) onTeilVerbauen;
  final Future<void> Function(String, VerbautesTeil) onDeleteVerbautesTeil;
  final Future<void> Function(String, VerbautesTeil) onUpdateVerbautesTeil;
  // --- NEU: Funktion zum Löschen von Serviceeinträgen ---
  final Future<void> Function(String) onDeleteServiceeintrag;

  const AufbereitungScreen({
    Key? key,
    required this.alleGeraete,
    required this.alleErsatzteile,
    required this.verbauteTeile,
    required this.alleServiceeintraege,
    required this.onTeilVerbauen,
    required this.onDeleteVerbautesTeil,
    required this.onUpdateVerbautesTeil,
    required this.onDeleteServiceeintrag, // --- NEU ---
  }) : super(key: key);

  @override
  State<AufbereitungScreen> createState() => _AufbereitungScreenState();
}

class _AufbereitungScreenState extends State<AufbereitungScreen> {
  final TextEditingController _geraeteNummerController = TextEditingController();
  Geraet? _gefundenesGeraet;

  String? _selectedPartType;
  final TextEditingController _articleNumberController = TextEditingController();
  Ersatzteil? _foundArticle;

  List<Ersatzteil> _gefilterteErsatzteile = [];
  Ersatzteil? _selectedErsatzteil;
  String? _selectedLager;

  @override
  void dispose() {
    _geraeteNummerController.dispose();
    _articleNumberController.dispose();
    super.dispose();
  }

  void _sucheGeraet() {
    final eingegebeneNummer = _geraeteNummerController.text.trim();
    if (eingegebeneNummer.isEmpty) {
      setState(() { _gefundenesGeraet = null; });
      return;
    }
    try {
      final geraet = widget.alleGeraete.firstWhere((g) => g.nummer.toString() == eingegebeneNummer);
      setState(() { _gefundenesGeraet = geraet; });
    } catch (e) {
      setState(() { _gefundenesGeraet = null; });
      _showSnackbar(context, 'Kein Gerät mit dieser Nummer gefunden.');
    }
  }

  void _sucheArtikel() {
    final artikelnummer = _articleNumberController.text.trim().toLowerCase();
    if (artikelnummer.isEmpty) {
      setState(() => _foundArticle = null);
      return;
    }
    try {
      final ersatzteil = widget.alleErsatzteile.firstWhere(
            (teil) => teil.artikelnummer.toLowerCase().contains(artikelnummer),
      );
      setState(() {
        _foundArticle = ersatzteil;
        _articleNumberController.text = ersatzteil.artikelnummer;
        _selectedPartType = ersatzteil.kategorie;
        _gefilterteErsatzteile = widget.alleErsatzteile.where((t) => t.kategorie == _selectedPartType).toList();
        _selectedErsatzteil = ersatzteil;
      });
    } catch (e) {
      setState(() { _foundArticle = null; });
      _showSnackbar(context, 'Kein Ersatzteil für "${_articleNumberController.text}" gefunden.');
    }
  }

  void _verbaueTeil() async {
    if (_gefundenesGeraet == null || _foundArticle == null || _selectedLager == null) {
      _showSnackbar(context, 'Bitte zuerst Gerät, Lager und Ersatzteil auswählen.');
      return;
    }
    if ((_foundArticle!.lagerbestaende[_selectedLager!] ?? 0) <= 0) {
      _showSnackbar(context, 'Fehler: Dieses Teil ist im Lager "$_selectedLager" nicht mehr vorhanden.');
      return;
    }

    final seriennummer = _gefundenesGeraet!.seriennummer;
    final verbautesTeil = _foundArticle!;

    try {
      await widget.onTeilVerbauen(seriennummer, verbautesTeil, _selectedLager!);
      _showSnackbar(context, '${verbautesTeil.bezeichnung} wurde verbaut.');
      setState(() {
        _foundArticle = null;
        _selectedErsatzteil = null;
        _articleNumberController.clear();
        _selectedPartType = null;
        _gefilterteErsatzteile = [];
        _selectedLager = null;
      });
    } catch (e) {
      _showSnackbar(context, 'Fehler beim Verbuchen: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aufbereitung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Geräte-Historie anzeigen',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistorieScreen(
                    verbauteTeile: widget.verbauteTeile,
                    alleGeraete: widget.alleGeraete,
                    alleServiceeintraege: widget.alleServiceeintraege,
                    onDelete: widget.onDeleteVerbautesTeil,
                    onUpdate: widget.onUpdateVerbautesTeil,
                    onDeleteServiceeintrag: widget.onDeleteServiceeintrag, // <-- HINZUGEFÜGT
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gerät auswählen', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(controller: _geraeteNummerController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Gerätenummer eingeben', border: OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(Icons.search), onPressed: _sucheGeraet, tooltip: 'Suchen')), onSubmitted: (_) => _sucheGeraet()),
                      const SizedBox(height: 16),
                      if (_gefundenesGeraet != null) RichText(text: TextSpan(style: Theme.of(context).textTheme.titleMedium, children: [TextSpan(text: 'Seriennummer: '), TextSpan(text: _gefundenesGeraet!.seriennummer, style: TextStyle(fontWeight: FontWeight.bold))])) else Text('Bitte geben Sie eine gültige Gerätenummer ein.', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Ersatzteil verbauen', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedPartType,
                        decoration: const InputDecoration(labelText: 'Art des Ersatzteils', border: OutlineInputBorder()),
                        items: ['Toner', 'Drum', 'Transferbelt', 'Entwickler', 'Fixiereinheit'].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedPartType = value;
                            _gefilterteErsatzteile = widget.alleErsatzteile.where((teil) => teil.kategorie == value).toList();
                            _selectedErsatzteil = null;
                            _foundArticle = null;
                            _articleNumberController.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_gefilterteErsatzteile.isNotEmpty)
                        DropdownButtonFormField<Ersatzteil>(
                          isExpanded: true,
                          value: _selectedErsatzteil,
                          hint: const Text('Gefundenes Teil auswählen'),
                          decoration: const InputDecoration(labelText: 'Bezeichnung', border: OutlineInputBorder()),
                          items: _gefilterteErsatzteile.map((ersatzteil) => DropdownMenuItem<Ersatzteil>(value: ersatzteil, child: Text(ersatzteil.bezeichnung, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (ersatzteil) {
                            if (ersatzteil == null) return;
                            setState(() {
                              _selectedErsatzteil = ersatzteil;
                              _foundArticle = ersatzteil;
                              _articleNumberController.text = ersatzteil.artikelnummer;
                            });
                          },
                        ),
                      const SizedBox(height: 16),
                      TextField(controller: _articleNumberController, decoration: InputDecoration(labelText: 'Artikelnummer scannen/eingeben', border: const OutlineInputBorder(), suffixIcon: IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _sucheArtikel, tooltip: 'Suchen')), onSubmitted: (_) => _sucheArtikel()),
                      const SizedBox(height: 16),
                      if (_foundArticle != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.green.withValues(alpha:0.1), borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gefundener Artikel:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                              const SizedBox(height: 8),
                              Text('Bezeichnung: ${_foundArticle!.bezeichnung}'),
                              Text('Preis: ${_foundArticle!.preis.toStringAsFixed(2)} €'),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedLager,
                                hint: const Text('Lager auswählen'),
                                decoration: const InputDecoration(labelText: 'Lagerort', border: OutlineInputBorder()),
                                items: ['Hauptlager', 'Fahrzeug Patrick', 'Fahrzeug Melanie'].map((lager) {
                                  final bestand = _foundArticle!.lagerbestaende[lager] ?? 0;
                                  return DropdownMenuItem(value: lager, child: Text('$lager ($bestand Stk.)'));
                                }).toList(),
                                onChanged: (value) => setState(() => _selectedLager = value),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.build),
                                  label: const Text('Teil verbauen'),
                                  onPressed: (_foundArticle!.getGesamtbestand() > 0 && _selectedLager != null) ? _verbaueTeil : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: (_foundArticle!.getGesamtbestand() > 0 && _selectedLager != null) ? Colors.green : Colors.grey,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}