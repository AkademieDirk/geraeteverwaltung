import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Wichtig für die Datumsformatierung
import 'package:projekte/models/ersatzteil.dart';
import 'package:projekte/screens/zubehoer_screen.dart';
import 'package:projekte/screens/umbuchung_screen.dart';

class LagerverwaltungScreen extends StatefulWidget {
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
  State<LagerverwaltungScreen> createState() => _LagerverwaltungScreenState();
}

class _LagerverwaltungScreenState extends State<LagerverwaltungScreen> {
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

  void _showEinbuchenDialog(Ersatzteil teil) {
    final mengeController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedLager;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Wareneingang: ${teil.bezeichnung}'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: mengeController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Menge*',
                        hintText: 'Anzahl der gelieferten Teile',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Bitte eine Menge eingeben.';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Bitte eine gültige Zahl größer als 0 eingeben.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedLager,
                      hint: const Text('Lager auswählen*'),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: teil.lagerbestaende.keys.map((lager) {
                        return DropdownMenuItem(value: lager, child: Text(lager));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedLager = value;
                        });
                      },
                      validator: (value) => value == null ? 'Bitte ein Lager auswählen.' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final menge = int.parse(mengeController.text.trim());
                      await widget.onBookIn(teil, selectedLager!, menge);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$menge x ${teil.bezeichnung} wurde(n) eingebucht.'), backgroundColor: Colors.green),
                      );
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
      gefilterteErsatzteile = widget.ersatzteile;
    } else {
      final s = _searchTerm.toLowerCase();
      gefilterteErsatzteile = widget.ersatzteile.where((teil) {
        return teil.bezeichnung.toLowerCase().contains(s) ||
            teil.artikelnummer.toLowerCase().contains(s) ||
            teil.hersteller.toLowerCase().contains(s) ||
            teil.lieferant.toLowerCase().contains(s) ||
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
        title: const Text('Lagerverwaltung / Wareneingang'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildNavigationButton(
                    context: context,
                    title: 'Stammdaten pflegen',
                    icon: Icons.inventory_2,
                    color: Colors.brown,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZubehoerScreen(
                        ersatzteile: widget.ersatzteile,
                        onAdd: widget.onAdd,
                        onUpdate: widget.onUpdate,
                        onDelete: widget.onDelete,
                      )));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNavigationButton(
                    context: context,
                    title: 'Umbuchen',
                    icon: Icons.sync_alt,
                    color: Colors.deepOrange,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => UmbuchungScreen(
                        alleErsatzteile: widget.ersatzteile,
                        onTransfer: widget.onTransfer,
                      )));
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          const SizedBox(height: 8),
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
                      LagerbestandEintrag? letzterEintrag;
                      if (teil.lagerbestaende.isNotEmpty) {
                        letzterEintrag = teil.lagerbestaende.values.reduce((a, b) =>
                        a.letzteAenderung.compareTo(b.letzteAenderung) > 0 ? a : b
                        );
                      }
                      final isDemoData = letzterEintrag != null && letzterEintrag.letzteAenderung.toDate().year <= 2020;

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(teil.getGesamtbestand().toString()),
                        ),
                        title: Text(teil.bezeichnung),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Art-Nr: ${teil.artikelnummer}'),
                            if (letzterEintrag != null)
                              Text(
                                'Letzte Buchung: ${DateFormat('dd.MM.yy').format(letzterEintrag.letzteAenderung.toDate())}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDemoData ? Colors.red.shade300 : Colors.grey,
                                  fontStyle: isDemoData ? FontStyle.italic : FontStyle.normal,
                                ),
                              ),
                          ],
                        ),
                        trailing: ElevatedButton.icon(
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: const Text('Einbuchen'),
                          onPressed: () => _showEinbuchenDialog(teil),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
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
    LagerbestandEintrag? letzterEintrag;
    if (teil.lagerbestaende.isNotEmpty) {
      letzterEintrag = teil.lagerbestaende.values.reduce((a, b) =>
      a.letzteAenderung.compareTo(b.letzteAenderung) > 0 ? a : b
      );
    }
    final isDemoData = letzterEintrag != null && letzterEintrag.letzteAenderung.toDate().year <= 2020;

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
                    if (teil.scancode.isNotEmpty) Text('Scancode: ${teil.scancode}'),
                    if (letzterEintrag != null)
                      Text(
                        'Letzte Buchung: ${DateFormat('dd.MM.yyyy').format(letzterEintrag.letzteAenderung.toDate())}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDemoData ? Colors.red.shade300 : Colors.grey,
                          fontStyle: isDemoData ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Diesen Artikel einbuchen'),
                  onPressed: () => _showEinbuchenDialog(teil),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
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

  Widget _buildNavigationButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 28),
      label: Text(title, style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      ),
    );
  }
}