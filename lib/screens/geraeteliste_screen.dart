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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Geräteliste')),
      body: widget.geraete.isEmpty
          ? Center(child: Text('Keine Geräte erfasst.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.geraete.length,
        itemBuilder: (ctx, index) {
          final g = widget.geraete[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            elevation: 3,
            child: ExpansionTile(
              initiallyExpanded: false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${g.nummer} – ${g.modell}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('Seriennummer: ${g.seriennummer}', style: TextStyle(fontSize: 13)),
                ],
              ),
              children: [
                Divider(),
                _row('Verantwortlich:', g.mitarbeiter),
                _row('I-Option:', g.iOption),
                _row('PDF-Typ:', g.pdfTyp),
                _row('Durchsuchbar:', g.durchsuchbar),
                SizedBox(height: 6),
                Text('Zubehör:', style: TextStyle(fontWeight: FontWeight.bold)),
                _row('Originaleinzug:', '${g.originaleinzugTyp} / SN: ${g.originaleinzugSN}'),
                _row('Unterschrank:', '${g.unterschrankTyp} / SN: ${g.unterschrankSN}'),
                _row('Finisher:', '${g.finisher} / SN: ${g.finisherSN}'),
                _row('Fax:', g.fax),
                Divider(),
                Text('Zählerstände:', style: TextStyle(fontWeight: FontWeight.bold)),
                _row('Gesamt:', '${g.zaehlerGesamt}'),
                _row('S/W:', '${g.zaehlerSW}'),
                _row('Color:', '${g.zaehlerColor}'),
                Divider(),
                Text('Füllstände / RTB / Toner (in %):', style: TextStyle(fontWeight: FontWeight.bold)),
                _row('RTB:', '${g.rtb}'),
                _row('Toner K / C / M / Y:', '${g.tonerK} / ${g.tonerC} / ${g.tonerM} / ${g.tonerY}'),
                Divider(),
                Text('Laufzeiten Bildeinheit (K/C/M/Y):', style: TextStyle(fontWeight: FontWeight.bold)),
                _row('', '${g.laufzeitBildeinheitK} / ${g.laufzeitBildeinheitC} / ${g.laufzeitBildeinheitM} / ${g.laufzeitBildeinheitY} %'),
                Text('Laufzeiten Entwickler (K/C/M/Y):', style: TextStyle(fontWeight: FontWeight.bold)),
                _row('', '${g.laufzeitEntwicklerK} / ${g.laufzeitEntwicklerC} / ${g.laufzeitEntwicklerM} / ${g.laufzeitEntwicklerY} %'),
                _row('Fixiereinheit:', '${g.laufzeitFixiereinheit} %'),
                _row('Transferbelt:', '${g.laufzeitTransferbelt} %'),
                Divider(),
                Text('Testergebnisse und Zustand:', style: TextStyle(fontWeight: FontWeight.bold)),
                _row('Fach1:', g.fach1 ?? ''),
                _row('Fach2:', g.fach2 ?? ''),
                _row('Fach3:', g.fach3 ?? ''),
                _row('Fach4:', g.fach4 ?? ''),
                _row('Bypass:', g.bypass ?? ''),
                _row('Dokumenteneinzug:', g.dokumenteneinzug ?? ''),
                _row('Duplex:', g.duplex ?? ''),
                if ((g.bemerkung ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text('Bemerkung: ${g.bemerkung}', style: TextStyle(color: Colors.black54)),
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
                          widget.onEdit(index, result);
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
                                'Gerät "${g.nummer}" wirklich löschen?'),
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
                        if (sicher == true) widget.onDelete(index);
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
