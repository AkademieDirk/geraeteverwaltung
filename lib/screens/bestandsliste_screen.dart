import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../models/geraet.dart';
import '../models/kunde.dart';
import '../models/standort.dart';
import 'geraeteaufnahme/geraeteaufnahme_screen.dart';

class BestandslisteScreen extends StatefulWidget {
  final List<Geraet> alleGeraete;
  final Future<void> Function(Geraet) onUpdate;
  final Future<void> Function(String) onDelete; // Nimmt die ID des Geräts entgegen
  final List<Kunde> kunden;
  final List<Standort> standorte;
  final Future<void> Function(Geraet, Kunde, Standort) onAssign;
  final Future<void> Function(List<Geraet>) onImport;

  const BestandslisteScreen({
    Key? key,
    required this.alleGeraete,
    required this.onUpdate,
    required this.onDelete,
    required this.kunden,
    required this.standorte,
    required this.onAssign,
    required this.onImport,
  }) : super(key: key);

  @override
  State<BestandslisteScreen> createState() => _BestandslisteScreenState();
}

class _BestandslisteScreenState extends State<BestandslisteScreen> {
  final TextEditingController _suchController = TextEditingController();
  String _suchbegriff = '';
  bool _isImporting = false;

  String _selectedEinzugFilter = 'Alle';
  final List<String> _einzugFilterOptionen = ['Alle', 'Kein', 'DF-714', 'DF-715', 'DF-632', 'DF-633', 'Sonstiges'];

  String _selectedOcrFilter = 'Alle';
  final List<String> _ocrFilterOptionen = ['Alle', 'Ja', 'Nein'];


  @override
  void dispose() {
    _suchController.dispose();
    super.dispose();
  }

  Future<void> _importGeraete() async {
    setState(() => _isImporting = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
      );

      if (result != null && result.files.single.bytes != null) {
        var bytes = result.files.single.bytes!;
        var excel = Excel.decodeBytes(bytes);
        var sheet = excel.tables[excel.tables.keys.first];

        if (sheet == null) throw Exception("Kein Tabellenblatt in der Datei gefunden.");

        List<Geraet> geraeteToImport = [];
        for (var i = 1; i < sheet.rows.length; i++) {
          var row = sheet.rows[i];
          if (row.length >= 3 && row[0] != null && row[1] != null && row[2] != null) {
            geraeteToImport.add(Geraet(
              nummer: row[0]?.value.toString() ?? '',
              modell: row[1]?.value.toString() ?? '',
              seriennummer: row[2]?.value.toString() ?? '',
              mitarbeiter: row.length > 3 ? row[3]?.value.toString() ?? '' : '',
              lieferant: row.length > 5 ? row[5]?.value.toString() ?? '' : '',
            ));
          }
        }

        if (geraeteToImport.isNotEmpty) {
          await widget.onImport(geraeteToImport);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${geraeteToImport.length} neue Geräte erfolgreich importiert!'), backgroundColor: Colors.green));
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keine neuen Geräte in der Datei gefunden.'), backgroundColor: Colors.orange));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler beim Import: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _showZuordnungsDialog(Geraet geraet) {
    Kunde? selectedKunde;
    Standort? selectedStandort;
    List<Standort> kundenStandorte = [];
    String kundenSuchbegriff = '';
    List<Kunde> gefilterteKunden = widget.kunden;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Gerät "${geraet.modell}" ausliefern'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Kunde suchen (Name oder Kundennr.)',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (wert) {
                          setDialogState(() {
                            kundenSuchbegriff = wert.toLowerCase();
                            gefilterteKunden = widget.kunden.where((k) {
                              return k.name.toLowerCase().contains(kundenSuchbegriff) ||
                                  k.kundennummer.toLowerCase().contains(kundenSuchbegriff);
                            }).toList();
                            selectedKunde = null;
                            selectedStandort = null;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<Kunde>(
                        value: selectedKunde,
                        hint: const Text('Kunde auswählen'),
                        isExpanded: true,
                        items: gefilterteKunden.map((k) => DropdownMenuItem(value: k, child: Text(k.name))).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedKunde = val;
                            selectedStandort = null;
                            if (selectedKunde != null) {
                              kundenStandorte = widget.standorte.where((s) => s.kundeId == selectedKunde!.id).toList();
                            } else {
                              kundenStandorte = [];
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (selectedKunde != null)
                        DropdownButtonFormField<Standort>(
                          value: selectedStandort,
                          hint: const Text('Standort auswählen'),
                          isExpanded: true,
                          items: kundenStandorte.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                          onChanged: (val) {
                            setDialogState(() {
                              selectedStandort = val;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.of(ctx).pop()),
                ElevatedButton(
                  child: const Text('Bestätigen & Ausliefern'),
                  onPressed: (selectedKunde != null && selectedStandort != null)
                      ? () async {
                    await widget.onAssign(geraet, selectedKunde!, selectedStandort!);
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

  void _showDeleteConfirmationDialog(Geraet geraet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Löschen bestätigen'),
        content: Text('Sind Sie sicher, dass Sie das Gerät "${geraet.modell}" (SN: ${geraet.seriennummer}) endgültig löschen möchten?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Abbrechen'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Löschen'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await widget.onDelete(geraet.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gerät wurde gelöscht.'), backgroundColor: Colors.green),
                );
              }
            },
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    List<Geraet> gefilterteListe = widget.alleGeraete.where((g) => g.status == 'Im Lager').toList();

    if (_selectedEinzugFilter != 'Alle') {
      gefilterteListe = gefilterteListe.where((g) => g.originaleinzugTyp == _selectedEinzugFilter).toList();
    }

    if (_selectedOcrFilter != 'Alle') {
      gefilterteListe = gefilterteListe.where((g) => g.ocr == _selectedOcrFilter).toList();
    }

    if (_suchbegriff.isNotEmpty) {
      final begriff = _suchbegriff.toLowerCase();
      gefilterteListe = gefilterteListe.where((g) =>
      g.nummer.toLowerCase().contains(begriff) ||
          g.modell.toLowerCase().contains(begriff) ||
          g.seriennummer.toLowerCase().contains(begriff)
      ).toList();
    }

    Map<String, List<Geraet>> gruppierteGeraete = {};
    for (var geraet in gefilterteListe) {
      gruppierteGeraete.putIfAbsent(geraet.modell, () => []).add(geraet);
    }

    gruppierteGeraete.forEach((modell, geraeteListe) {
      geraeteListe.sort((a, b) {
        final zaehlerA = int.tryParse(a.zaehlerGesamt) ?? 9999999;
        final zaehlerB = int.tryParse(b.zaehlerGesamt) ?? 9999999;
        return zaehlerA.compareTo(zaehlerB);
      });
    });

    final sortierteModelle = gruppierteGeraete.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bestandsliste (Lager)'),
        actions: [
          _isImporting
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)),
          )
              : IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Geräte aus Excel importieren',
            onPressed: _importGeraete,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _suchController,
                    decoration: InputDecoration(labelText: 'Bestand durchsuchen...', prefixIcon: const Icon(Icons.search), suffixIcon: _suchbegriff.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { setState(() { _suchController.clear(); _suchbegriff = ''; }); }) : null, border: const OutlineInputBorder()),
                    onChanged: (wert) => setState(() => _suchbegriff = wert.trim()),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedEinzugFilter,
                    decoration: const InputDecoration(labelText: 'Filter: Originaleinzug', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)),
                    items: _einzugFilterOptionen.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                    onChanged: (newValue) => setState(() => _selectedEinzugFilter = newValue!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedOcrFilter,
                    decoration: const InputDecoration(labelText: 'Filter: OCR', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)),
                    items: _ocrFilterOptionen.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                    onChanged: (newValue) => setState(() => _selectedOcrFilter = newValue!),
                  ),
                ),
              ],
            ),
          ),
          // --- ANFANG DER ÄNDERUNG ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Gefundene Geräte: ${gefilterteListe.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
          // --- ENDE DER ÄNDERUNG ---
          Expanded(
            child: gruppierteGeraete.isEmpty
                ? const Center(child: Text('Keine Geräte für die Auswahl gefunden.'))
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sortierteModelle.length,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.green,
                thickness: 1,
              ),
              itemBuilder: (ctx, index) {
                final modell = sortierteModelle[index];
                final geraeteInGruppe = gruppierteGeraete[modell]!;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      '$modell (${geraeteInGruppe.length} Stk.)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    children: geraeteInGruppe.map((g) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(g.nummer, textAlign: TextAlign.center),
                        ),
                        title: Row(
                          children: [
                            Text('SN: ${g.seriennummer}'),
                            const SizedBox(width: 24),
                            Text(
                              'Zähler: ${g.zaehlerGesamt.isNotEmpty ? g.zaehlerGesamt : 'k.A.'}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 24),
                            Text(
                              g.originaleinzugTyp.isNotEmpty ? g.originaleinzugTyp : 'k.A.',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.local_shipping, color: Colors.blueAccent), tooltip: 'Ausliefern', onPressed: () => _showZuordnungsDialog(g)),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              tooltip: 'Bearbeiten',
                              onPressed: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => GeraeteAufnahmeScreen(
                                  initialGeraet: g,
                                  onSave: widget.onUpdate,
                                  onImport: widget.onImport,
                                  alleGeraete: widget.alleGeraete,
                                ),
                              )),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              tooltip: 'Löschen',
                              onPressed: () => _showDeleteConfirmationDialog(g),
                            ),
                          ],
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
}