import 'package:flutter/material.dart';
import '../models/geraet.dart';
import 'geraeteaufnahme/geraeteaufnahme_screen.dart';

class GeraeteListeScreen extends StatefulWidget {
  final List<Geraet> geraete;
  final void Function(int, Geraet) onEdit;
  final void Function(int) onDelete;

  const GeraeteListeScreen({
    Key? key,
    required this.geraete,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<GeraeteListeScreen> createState() => _GeraeteListeScreenState();
}

class _GeraeteListeScreenState extends State<GeraeteListeScreen> {
  final TextEditingController _suchController = TextEditingController();
  String _suchbegriff = '';

  @override
  void dispose() {
    _suchController.dispose();
    super.dispose();
  }

  // Hilfsfunktion für Null- und Typ-sichere String-Darstellung
  String safeToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Enum) return value.name;
    return value.toString();
  }

  List<Geraet> get _gefilterteGeraete {
    if (_suchbegriff.isEmpty) return widget.geraete;
    final begriff = _suchbegriff.toLowerCase();

    return widget.geraete.where((g) =>
    safeToString(g.nummer).toLowerCase().contains(begriff) ||
        safeToString(g.modell).toLowerCase().contains(begriff) ||
        safeToString(g.seriennummer).toLowerCase().contains(begriff) ||
        safeToString(g.mitarbeiter).toLowerCase().contains(begriff) ||
        safeToString(g.iOption).toLowerCase().contains(begriff) ||
        safeToString(g.pdfTyp).toLowerCase().contains(begriff) ||
        safeToString(g.durchsuchbar).toLowerCase().contains(begriff) ||
        safeToString(g.originaleinzugTyp).toLowerCase().contains(begriff) ||
        safeToString(g.originaleinzugSN).toLowerCase().contains(begriff) ||
        safeToString(g.unterschrankTyp).toLowerCase().contains(begriff) ||
        safeToString(g.unterschrankSN).toLowerCase().contains(begriff) ||
        safeToString(g.finisher).toLowerCase().contains(begriff) ||
        safeToString(g.finisherSN).toLowerCase().contains(begriff) ||
        safeToString(g.fax).toLowerCase().contains(begriff) ||
        safeToString(g.bemerkung).toLowerCase().contains(begriff)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Geräteliste')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _suchController,
              decoration: InputDecoration(
                labelText: 'Suche (Modell, Seriennummer, etc.)',
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
              onChanged: (wert) => setState(() => _suchbegriff = wert.trim()),
            ),
          ),
          Expanded(
            child: _gefilterteGeraete.isEmpty
                ? Center(child: Text('Keine passenden Geräte gefunden.'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _gefilterteGeraete.length,
              itemBuilder: (ctx, index) {
                final g = _gefilterteGeraete[index];
                final originalIndex = widget.geraete.indexOf(g);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 3,
                  child: ExpansionTile(
                    initiallyExpanded: false,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${safeToString(g.nummer)} – ${safeToString(g.modell)}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text('Seriennummer: ${safeToString(g.seriennummer)}', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    children: [
                      Divider(),
                      _row('Verantwortlich:', safeToString(g.mitarbeiter)),
                      _row('I-Option:', safeToString(g.iOption)),
                      _row('PDF-Typ:', safeToString(g.pdfTyp)),
                      _row('Durchsuchbar:', safeToString(g.durchsuchbar)),
                      SizedBox(height: 6),
                      Text('Zubehör:', style: TextStyle(fontWeight: FontWeight.bold)),
                      _row('Originaleinzug:', '${safeToString(g.originaleinzugTyp)} / SN: ${safeToString(g.originaleinzugSN)}'),
                      _row('Unterschrank:', '${safeToString(g.unterschrankTyp)} / SN: ${safeToString(g.unterschrankSN)}'),
                      _row('Finisher:', '${safeToString(g.finisher)} / SN: ${safeToString(g.finisherSN)}'),
                      _row('Fax:', safeToString(g.fax)),
                      Divider(),
                      Text('Zählerstände:', style: TextStyle(fontWeight: FontWeight.bold)),
                      _row('Gesamt:', safeToString(g.zaehlerGesamt)),
                      _row('S/W:', safeToString(g.zaehlerSW)),
                      _row('Color:', safeToString(g.zaehlerColor)),
                      Divider(),
                      Text('Füllstände / RTB / Toner (in %):', style: TextStyle(fontWeight: FontWeight.bold)),
                      _row('RTB:', safeToString(g.rtb)),
                      _row('Toner K / C / M / Y:', '${safeToString(g.tonerK)} / ${safeToString(g.tonerC)} / ${safeToString(g.tonerM)} / ${safeToString(g.tonerY)}'),
                      Divider(),
                      Text('Laufzeiten Bildeinheit (K/C/M/Y):', style: TextStyle(fontWeight: FontWeight.bold)),
                      _row('', '${safeToString(g.laufzeitBildeinheitK)} / ${safeToString(g.laufzeitBildeinheitC)} / ${safeToString(g.laufzeitBildeinheitM)} / ${safeToString(g.laufzeitBildeinheitY)} %'),
                      Text('Laufzeiten Entwickler (K/C/M/Y):', style: TextStyle(fontWeight: FontWeight.bold)),
                      _row('', '${safeToString(g.laufzeitEntwicklerK)} / ${safeToString(g.laufzeitEntwicklerC)} / ${safeToString(g.laufzeitEntwicklerM)} / ${safeToString(g.laufzeitEntwicklerY)} %'),
                      _row('Fixiereinheit:', '${safeToString(g.laufzeitFixiereinheit)} %'),
                      _row('Transferbelt:', '${safeToString(g.laufzeitTransferbelt)} %'),
                      Divider(),
                      Text('Testergebnisse und Zustand:', style: TextStyle(fontWeight: FontWeight.bold)),
                      _row('Fach1:', safeToString(g.fach1)),
                      _row('Fach2:', safeToString(g.fach2)),
                      _row('Fach3:', safeToString(g.fach3)),
                      _row('Fach4:', safeToString(g.fach4)),
                      _row('Bypass:', safeToString(g.bypass)),
                      _row('Dokumenteneinzug:', safeToString(g.dokumenteneinzug)),
                      _row('Duplex:', safeToString(g.duplex)),
                      if (safeToString(g.bemerkung).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text('Bemerkung: ${safeToString(g.bemerkung)}', style: TextStyle(color: Colors.black54)),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Bearbeiten',
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GeraeteAufnahmeScreen(
                                    vorhandeneGeraete: widget.geraete,
                                    initialGeraet: g,
                                  ),
                                ),
                              );
                              if (result != null && result is Geraet) {
                                widget.onEdit(originalIndex, result);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Löschen',
                            onPressed: () async {
                              final sicher = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Löschen bestätigen'),
                                  content: Text(
                                      'Gerät "${safeToString(g.nummer)}" wirklich löschen?'),
                                  actions: [
                                    TextButton(
                                      child: Text('Abbrechen'),
                                      onPressed: () => Navigator.pop(ctx, false),
                                    ),
                                    TextButton(
                                      child: Text('Löschen', style: TextStyle(color: Colors.red)),
                                      onPressed: () => Navigator.pop(ctx, true),
                                    ),
                                  ],
                                ),
                              );
                              if (sicher == true) widget.onDelete(originalIndex);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            SizedBox(width: 150, child: Text(label, style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
