import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/geraet.dart';
import '../models/kunde.dart';
import '../models/standort.dart';
import 'geraeteaufnahme/geraeteaufnahme_screen.dart';

class GeraeteListeScreen extends StatefulWidget {
  final List<Geraet> geraete;
  final Future<void> Function(Geraet) onUpdate;
  final Future<void> Function(String) onDelete;
  // NEU: Benötigt Kunden- und Standortdaten
  final List<Kunde> kunden;
  final List<Standort> standorte;
  final Future<void> Function(Geraet, Kunde, Standort) onAssign;

  const GeraeteListeScreen({
    Key? key,
    required this.geraete,
    required this.onUpdate,
    required this.onDelete,
    required this.kunden,
    required this.standorte,
    required this.onAssign,
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
        safeToString(g.kundeName ?? '').toLowerCase().contains(begriff) ||
        safeToString(g.standortName ?? '').toLowerCase().contains(begriff)
    ).toList();
  }

  // Dialog zur Zuordnung eines Geräts zu einem Kunden und Standort
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
                      items: widget.kunden.map((k) => DropdownMenuItem(value: k, child: Text(k.name))).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedKunde = val;
                          selectedStandort = null;
                          kundenStandorte = widget.standorte.where((s) => s.kundeId == selectedKunde!.id).toList();
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

  Future<void> _druckeGeraetAsPdf(Geraet g) async {
    final pdf = pw.Document();
    pw.Widget _pdfRow(String label, String value, {pw.FontWeight weight = pw.FontWeight.normal}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(width: 150, child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontWeight: weight))),
          ],
        ),
      );
    }
    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(30),
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) {
          return pw.Header(level: 0, child: pw.Text('Gerätedatenblatt: ${safeToString(g.modell)}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)));
        },
        build: (pw.Context context) => [
          pw.Divider(thickness: 1.5),
          pw.SizedBox(height: 15),
          _pdfRow('Gerätenummer:', safeToString(g.nummer)),
          _pdfRow('Seriennummer:', safeToString(g.seriennummer)),
          _pdfRow('Kunde:', safeToString(g.kundeName)),
          _pdfRow('Standort:', safeToString(g.standortName)),
          pw.Divider(height: 15),
          // ... (Rest der PDF-Logik)
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
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
              decoration: InputDecoration(labelText: 'Suche (Modell, SN, Kunde...)', prefixIcon: Icon(Icons.search), suffixIcon: _suchbegriff.isNotEmpty ? IconButton(icon: Icon(Icons.clear), onPressed: () { setState(() { _suchController.clear(); _suchbegriff = ''; }); }) : null, border: OutlineInputBorder()),
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
                final bool imLager = g.status == 'Im Lager';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 3,
                  child: ExpansionTile(
                    title: Text('${g.modell} (SN: ${g.seriennummer})', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(imLager ? 'Status: Im Lager (Nr: ${g.nummer})' : 'Kunde: ${g.kundeName ?? ''} - ${g.standortName ?? ''}', style: TextStyle(color: imLager ? Colors.green : Colors.blue)),
                    children: [
                      Divider(),
                      _row('Verantwortlich:', safeToString(g.mitarbeiter)),
                      _row('I-Option:', safeToString(g.iOption)),
                      _row('PDF Typ:', safeToString(g.pdfTyp)),
                      _row('Durchsuchbar:', safeToString(g.durchsuchbar)),
                      _row('OCR:', safeToString(g.ocr)),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // --- NEU: Button wird nur angezeigt, wenn Gerät im Lager ist ---
                          if (imLager)
                            ElevatedButton.icon(
                              icon: Icon(Icons.local_shipping, size: 18),
                              label: Text('Ausliefern'),
                              onPressed: () => _showZuordnungsDialog(g),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                            ),
                          IconButton(icon: Icon(Icons.edit, color: Colors.orange), tooltip: 'Bearbeiten', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GeraeteAufnahmeScreen(initialGeraet: g, onSave: widget.onUpdate)))),
                          IconButton(icon: Icon(Icons.delete, color: Colors.red), tooltip: 'Löschen', onPressed: () async {
                            final sicher = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: Text('Löschen bestätigen'), content: Text('Gerät "${g.modell}" wirklich löschen?'), actions: [TextButton(child: Text('Abbrechen'), onPressed: () => Navigator.pop(ctx, false)), TextButton(child: Text('Löschen', style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx, true))]));
                            if (sicher == true) { await widget.onDelete(g.id); }
                          }),
                          IconButton(icon: Icon(Icons.print, color: Colors.grey[700]), tooltip: 'Datenblatt drucken', onPressed: () => _druckeGeraetAsPdf(g)),
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
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
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
