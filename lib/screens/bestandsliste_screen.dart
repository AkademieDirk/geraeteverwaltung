import 'package:flutter/material.dart';
import '../models/geraet.dart';
import '../models/kunde.dart';
import '../models/standort.dart';
import 'geraeteaufnahme/geraeteaufnahme_screen.dart';

class BestandslisteScreen extends StatefulWidget {
  final List<Geraet> alleGeraete;
  final Future<void> Function(Geraet) onUpdate;
  final Future<void> Function(String) onDelete;
  final List<Kunde> kunden;
  final List<Standort> standorte;
  final Future<void> Function(Geraet, Kunde, Standort) onAssign;

  const BestandslisteScreen({
    Key? key,
    required this.alleGeraete,
    required this.onUpdate,
    required this.onDelete,
    required this.kunden,
    required this.standorte,
    required this.onAssign,
  }) : super(key: key);

  @override
  State<BestandslisteScreen> createState() => _BestandslisteScreenState();
}

class _BestandslisteScreenState extends State<BestandslisteScreen> {
  final TextEditingController _suchController = TextEditingController();
  String _suchbegriff = '';

  @override
  void dispose() {
    _suchController.dispose();
    super.dispose();
  }

  void _showZuordnungsDialog(Geraet geraet) {
    Kunde? selectedKunde;
    Standort? selectedStandort;
    List<Standort> kundenStandorte = [];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Gerät "${geraet.modell}" ausliefern'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Kunde>(
                      value: selectedKunde,
                      hint: const Text('Kunde auswählen'),
                      isExpanded: true,
                      items: widget.kunden
                          .map((k) => DropdownMenuItem(value: k, child: Text(k.name)))
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedKunde = val;
                          selectedStandort = null;
                          kundenStandorte = widget.standorte
                              .where((s) => s.kundeId == selectedKunde!.id)
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (selectedKunde != null)
                      DropdownButtonFormField<Standort>(
                        value: selectedStandort,
                        hint: const Text('Standort auswählen'),
                        isExpanded: true,
                        items: kundenStandorte
                            .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                            .toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedStandort = val;
                          });
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    child: const Text('Abbrechen'),
                    onPressed: () => Navigator.of(ctx).pop()),
                ElevatedButton(
                  child: const Text('Bestätigen & Ausliefern'),
                  onPressed: (selectedKunde != null && selectedStandort != null)
                      ? () async {
                    await widget.onAssign(
                        geraet, selectedKunde!, selectedStandort!);
                    Navigator.of(ctx).pop();
                  }
                      : null,
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bestandsGeraete =
    widget.alleGeraete.where((g) => g.status == 'Im Lager').toList();

    final List<Geraet> gefilterteListe;
    if (_suchbegriff.isEmpty) {
      gefilterteListe = bestandsGeraete;
    } else {
      final begriff = _suchbegriff.toLowerCase();
      gefilterteListe = bestandsGeraete.where((g) {
        return g.nummer.toLowerCase().contains(begriff) ||
            g.modell.toLowerCase().contains(begriff) ||
            g.seriennummer.toLowerCase().contains(begriff);
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Bestandsliste (Lager)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _suchController,
              decoration: InputDecoration(
                labelText: 'Bestand durchsuchen...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _suchbegriff.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _suchController.clear();
                      _suchbegriff = '';
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(),
              ),
              onChanged: (wert) =>
                  setState(() => _suchbegriff = wert.trim()),
            ),
          ),
          Expanded(
            child: gefilterteListe.isEmpty
                ? Center(child: Text('Keine Geräte im Lager gefunden.'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: gefilterteListe.length,
              itemBuilder: (ctx, index) {
                final g = gefilterteListe[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                        child: Icon(Icons.inventory_2_outlined)),
                    title: Text(
                      '${g.modell} (SN: ${g.seriennummer})',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Interne Nr: ${g.nummer}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.local_shipping,
                              color: Colors.blueAccent),
                          tooltip: 'Ausliefern',
                          onPressed: () =>
                              _showZuordnungsDialog(g),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit,
                              color: Colors.orange),
                          tooltip: 'Bearbeiten',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GeraeteAufnahmeScreen(
                                initialGeraet: g,
                                onSave: widget.onUpdate,
                                onImport: (_) async {}, // ❗ hinzugefügt
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
