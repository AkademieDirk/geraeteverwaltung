import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // NEU: Import für die Datumsformatierung
import '../models/verbautes_teil.dart'; // NEU: Import des neuen Modells

/// Ein Screen, der die verbauten Teile für eine bestimmte Seriennummer anzeigt.
class HistorieScreen extends StatefulWidget {
  // GEÄNDERT: Akzeptiert die neue Datenstruktur
  final Map<String, List<VerbautesTeil>> verbauteTeile;

  const HistorieScreen({
    Key? key,
    required this.verbauteTeile,
  }) : super(key: key);

  @override
  State<HistorieScreen> createState() => _HistorieScreenState();
}

class _HistorieScreenState extends State<HistorieScreen> {
  final TextEditingController _seriennummerController = TextEditingController();
  // GEÄNDERT: Speichert jetzt 'VerbautesTeil'-Objekte
  List<VerbautesTeil> _gefundeneTeile = [];
  double _gesamtkosten = 0.0;
  String _angezeigteSeriennummer = '';

  @override
  void dispose() {
    _seriennummerController.dispose();
    super.dispose();
  }

  /// Sucht in der übergebenen Historie nach der eingegebenen Seriennummer.
  void _sucheHistorie() {
    final seriennummer = _seriennummerController.text.trim();
    if (seriennummer.isEmpty) {
      setState(() {
        _gefundeneTeile = [];
        _gesamtkosten = 0.0;
        _angezeigteSeriennummer = '';
      });
      return;
    }

    if (widget.verbauteTeile.containsKey(seriennummer)) {
      final teile = widget.verbauteTeile[seriennummer]!;
      // GEÄNDERT: Greift auf den Preis über das 'ersatzteil'-Objekt zu
      final summe = teile.fold(0.0, (total, verbautesTeil) => total + verbautesTeil.ersatzteil.preis);

      setState(() {
        _gefundeneTeile = teile;
        _gesamtkosten = summe;
        _angezeigteSeriennummer = seriennummer;
      });
    } else {
      setState(() {
        _gefundeneTeile = [];
        _gesamtkosten = 0.0;
        _angezeigteSeriennummer = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Für diese Seriennummer wurde keine Historie gefunden.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geräte-Historie'),
      ),
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
                    labelText: 'Seriennummer eingeben',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _sucheHistorie,
                      tooltip: 'Historie suchen',
                    ),
                  ),
                  onSubmitted: (_) => _sucheHistorie(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_gefundeneTeile.isNotEmpty) ...[
              Card(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gesamtkosten:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_gesamtkosten.toStringAsFixed(2)} €',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Verbaute Teile für: $_angezeigteSeriennummer',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),

              Expanded(
                child: ListView.builder(
                  itemCount: _gefundeneTeile.length,
                  itemBuilder: (context, index) {
                    final verbautes = _gefundeneTeile[index];
                    final teil = verbautes.ersatzteil;
                    final datum = DateFormat('dd.MM.yyyy').format(verbautes.installationsDatum);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ExpansionTile(
                        title: Text(
                          teil.bezeichnung,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // GEÄNDERT: Zeigt das Installationsdatum an
                        subtitle: Text(
                          'Verbaut am: $datum',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        leading: CircleAvatar(
                          child: Text((index + 1).toString()),
                        ),
                        // GEÄNDERT: Zeigt Preis jetzt als erstes Detail an
                        children: [
                          ListTile(
                            title: Text('${teil.preis.toStringAsFixed(2)} €'),
                            subtitle: const Text('Preis'),
                            leading: const Icon(Icons.euro_symbol),
                          ),
                          ListTile(
                            title: Text(teil.artikelnummer),
                            subtitle: const Text('Artikelnummer'),
                            leading: const Icon(Icons.qr_code),
                          ),
                          ListTile(
                            title: Text(teil.lieferant),
                            subtitle: const Text('Lieferant'),
                            leading: const Icon(Icons.local_shipping),
                          ),
                          ListTile(
                            title: Text(teil.kategorie),
                            subtitle: const Text('Kategorie'),
                            leading: const Icon(Icons.category),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else
              const Center(
                child: Text('Bitte eine Seriennummer eingeben, um die Historie anzuzeigen.'),
              )
          ],
        ),
      ),
    );
  }
}
