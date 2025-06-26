import 'package:flutter/material.dart';
import '../models/geraet.dart';
import '../models/ersatzteil.dart';
import '../models/verbautes_teil.dart'; // Wichtig: Import des neuen Modells
import 'historie_screen.dart';

class AufbereitungScreen extends StatefulWidget {
  final List<Geraet> alleGeraete;
  final List<Ersatzteil> alleErsatzteile;
  // --- GEÄNDERT: Akzeptiert jetzt die korrekte Datenstruktur mit Datum ---
  final Map<String, List<VerbautesTeil>> verbauteTeile;
  final void Function(String, Ersatzteil) onTeilVerbauen;

  const AufbereitungScreen({
    Key? key,
    required this.alleGeraete,
    required this.alleErsatzteile,
    required this.verbauteTeile,
    required this.onTeilVerbauen,
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
    final artikelnummer = _articleNumberController.text.trim();
    if (artikelnummer.isEmpty) {
      setState(() => _foundArticle = null);
      return;
    }

    try {
      final ersatzteil = widget.alleErsatzteile.firstWhere(
            (teil) => teil.artikelnummer == artikelnummer,
      );
      setState(() {
        _foundArticle = ersatzteil;
        _selectedPartType = ersatzteil.kategorie;
        _gefilterteErsatzteile = widget.alleErsatzteile.where((t) => t.kategorie == _selectedPartType).toList();
        _selectedErsatzteil = ersatzteil;
      });
    } catch (e) {
      setState(() { _foundArticle = null; });
      _showSnackbar(context, 'Artikelnummer nicht im Zubehör gefunden.');
    }
  }

  void _verbaueTeil() {
    if (_gefundenesGeraet == null || _foundArticle == null) {
      _showSnackbar(context, 'Bitte zuerst Gerät und Ersatzteil auswählen.');
      return;
    }

    final seriennummer = _gefundenesGeraet!.seriennummer;
    final verbautesTeil = _foundArticle!;

    widget.onTeilVerbauen(seriennummer, verbautesTeil);

    setState(() {
      _showSnackbar(context, '${verbautesTeil.bezeichnung} wurde Gerät $seriennummer zugeordnet.');

      _foundArticle = null;
      _selectedErsatzteil = null;
      _articleNumberController.clear();
      _selectedPartType = null;
      _gefilterteErsatzteile = [];
    });
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
                    // Übergibt die korrekte Datenstruktur
                    verbauteTeile: widget.verbauteTeile,
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
                      TextField(
                        controller: _geraeteNummerController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Gerätenummer eingeben',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(icon: Icon(Icons.search), onPressed: _sucheGeraet, tooltip: 'Suchen'),
                        ),
                        onSubmitted: (_) => _sucheGeraet(),
                      ),
                      const SizedBox(height: 16),
                      if (_gefundenesGeraet != null)
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.titleMedium,
                            children: [TextSpan(text: 'Seriennummer: '), TextSpan(text: _gefundenesGeraet!.seriennummer, style: TextStyle(fontWeight: FontWeight.bold))],
                          ),
                        )
                      else
                        Text('Bitte geben Sie eine gültige Gerätenummer ein.', style: TextStyle(color: Colors.grey.shade600)),
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
                        items: ['Toner', 'Drum', 'TBU', 'Entwickler', 'Fixiereinheit'].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
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
                          value: _selectedErsatzteil,
                          hint: const Text('Gefundenes Teil auswählen'),
                          decoration: const InputDecoration(labelText: 'Bezeichnung', border: OutlineInputBorder()),
                          items: _gefilterteErsatzteile.map((ersatzteil) {
                            return DropdownMenuItem<Ersatzteil>(
                              value: ersatzteil,
                              child: Text(ersatzteil.bezeichnung),
                            );
                          }).toList(),
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
                      TextField(
                        controller: _articleNumberController,
                        decoration: InputDecoration(
                          labelText: 'Artikelnummer scannen/eingeben',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _sucheArtikel, tooltip: 'Suchen'),
                        ),
                        onSubmitted: (_) => _sucheArtikel(),
                      ),
                      const SizedBox(height: 16),
                      if (_foundArticle != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gefundener Artikel:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                              const SizedBox(height: 8),
                              Text('Bezeichnung: ${_foundArticle!.bezeichnung}'),
                              Text('Preis: ${_foundArticle!.preis.toStringAsFixed(2)} €'),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.build),
                                  label: const Text('Teil verbauen'),
                                  onPressed: _verbaueTeil,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
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
              const SizedBox(height: 24),
              // Platzhalter für weitere Arbeitsschritte
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
