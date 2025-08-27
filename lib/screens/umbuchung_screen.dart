import 'package:flutter/material.dart';
import 'package:projekte/models/ersatzteil.dart';

class UmbuchungScreen extends StatefulWidget {
  final List<Ersatzteil> alleErsatzteile;
  final Future<void> Function(Ersatzteil teil, String von, String nach, int anzahl) onTransfer;

  const UmbuchungScreen({
    Key? key,
    required this.alleErsatzteile,
    required this.onTransfer,
  }) : super(key: key);

  @override
  State<UmbuchungScreen> createState() => _UmbuchungScreenState();
}

class _UmbuchungScreenState extends State<UmbuchungScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUmbuchungsDialog(Ersatzteil teil) {
    final formKey = GlobalKey<FormState>();
    String? vonLager;
    String? nachLager;
    final anzahlController = TextEditingController();
    final lagerOrte = teil.lagerbestaende.keys.toList();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Umbuchen: ${teil.bezeichnung}'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: vonLager,
                      hint: const Text('Von Lager...'),
                      items: lagerOrte.map((lager) {
                        final bestand = teil.lagerbestaende[lager] ?? 0;
                        return DropdownMenuItem(value: lager, child: Text('$lager ($bestand Stk.)'));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => vonLager = val),
                      validator: (val) => val == null ? 'Bitte ein Start-Lager auswählen' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: nachLager,
                      hint: const Text('Nach Lager...'),
                      items: lagerOrte.where((l) => l != vonLager).map((lager) {
                        return DropdownMenuItem(value: lager, child: Text(lager));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => nachLager = val),
                      validator: (val) => val == null ? 'Bitte ein Ziel-Lager auswählen' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: anzahlController,
                      autofocus: true,
                      decoration: const InputDecoration(labelText: 'Anzahl'),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Bitte Anzahl eingeben';
                        final anzahl = int.tryParse(val);
                        if (anzahl == null || anzahl <= 0) return 'Ungültige Anzahl';
                        final bestand = teil.lagerbestaende[vonLager!] ?? 0;
                        if (anzahl > bestand) return 'Nicht genügend Bestand in $vonLager';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        await widget.onTransfer(
                          teil,
                          vonLager!,
                          nachLager!,
                          int.parse(anzahlController.text),
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Umbuchung erfolgreich!'), backgroundColor: Colors.green),
                        );
                      } catch (e) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Fehler bei Umbuchung: ${e.toString()}'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: const Text('Bestätigen'),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Ersatzteil> gefilterteErsatzteile;
    if (_searchTerm.isEmpty) {
      gefilterteErsatzteile = widget.alleErsatzteile;
    } else {
      final s = _searchTerm.toLowerCase();
      gefilterteErsatzteile = widget.alleErsatzteile.where((teil) {
        return teil.bezeichnung.toLowerCase().contains(s) ||
            teil.artikelnummer.toLowerCase().contains(s) ||
            teil.scancode.toLowerCase().contains(s);
      }).toList();
    }

    final Map<String, List<Ersatzteil>> gruppierteTeile = {};
    for (final teil in gefilterteErsatzteile) {
      final kategorie = teil.kategorie.isNotEmpty ? teil.kategorie : 'Sonstiges';
      (gruppierteTeile[kategorie] ??= []).add(teil);
    }
    final kategorien = gruppierteTeile.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bestand umbuchen'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Ersatzteil suchen (Bezeichnung, Scancode, ...)',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchTerm.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _searchTerm.isNotEmpty && gefilterteErsatzteile.length == 1
                ? _buildSingleArticleView(gefilterteErsatzteile.first)
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: kategorien.length,
              itemBuilder: (context, index) {
                final kategorie = kategorien[index];
                final teileInKategorie = gruppierteTeile[kategorie]!;

                teileInKategorie.sort((a, b) => a.bezeichnung.toLowerCase().compareTo(b.bezeichnung.toLowerCase()));

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ExpansionTile(
                    title: Text(kategorie, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    children: teileInKategorie.map((teil) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(teil.getGesamtbestand().toString()),
                        ),
                        title: Text(teil.bezeichnung),
                        subtitle: Text('Art-Nr: ${teil.artikelnummer}'),
                        trailing: ElevatedButton.icon(
                          icon: const Icon(Icons.sync_alt, size: 18),
                          label: const Text('Umbuchen'),
                          onPressed: () => _showUmbuchungsDialog(teil),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleArticleView(Ersatzteil teil) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Eindeutiger Treffer gefunden:", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 28,
                  child: Text(teil.getGesamtbestand().toString(), style: const TextStyle(fontSize: 18)),
                ),
                title: Text(teil.bezeichnung, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Art-Nr: ${teil.artikelnummer} | Hersteller: ${teil.hersteller}'),
                    if (teil.scancode.isNotEmpty)
                      Text('Scancode: ${teil.scancode}'),
                  ],
                ),
              ),
              const Divider(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.sync_alt),
                  label: const Text('Diesen Artikel umbuchen'),
                  onPressed: () => _showUmbuchungsDialog(teil),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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