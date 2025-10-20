import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projekte/models/geraet.dart';
import 'package:projekte/models/ersatzteil.dart';
import 'package:projekte/models/verbautes_teil.dart';
import 'package:projekte/models/serviceeintrag.dart';
import 'package:projekte/screens/service/serviceeintrag_screen.dart'; // Import für den ServiceeintragScreen
import 'dart:html' as html;
// --- PDF GENERIERUNGS IMPORTE ---
import 'package:pdf/pdf.dart'; // Für PDF-Formatierung
import 'package:pdf/widgets.dart' as pw; // Für PDF-Widgets
import 'package:printing/printing.dart'; // Für das Drucken und Anzeigen des PDFs
import 'package:flutter/services.dart' show rootBundle; // Für das Laden von Assets/Fonts
// --- ENDE PDF IMPORTE ---


class ServiceScreen extends StatefulWidget {
  final List<Geraet> alleGeraete;
  final List<Ersatzteil> alleErsatzteile;
  final List<Serviceeintrag> alleServiceeintraege;
  final Future<void> Function(Serviceeintrag) onAddServiceeintrag;
  final Future<void> Function(Serviceeintrag) onUpdateServiceeintrag;
  final Future<void> Function(String) onDeleteServiceeintrag;
  final Future<VerbautesTeil> Function(String, Ersatzteil, String, int) onTeilVerbauen;

  const ServiceScreen({
    Key? key,
    required this.alleGeraete,
    required this.alleErsatzteile,
    required this.alleServiceeintraege,
    required this.onAddServiceeintrag,
    required this.onUpdateServiceeintrag,
    required this.onDeleteServiceeintrag,
    required this.onTeilVerbauen,
  }) : super(key: key);

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  Geraet? _selectedGeraet;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openInNewTab(String url) {
    html.window.open(url, '_blank');
  }

  void _deleteServiceeintrag(Serviceeintrag eintrag) async {
    final sicher = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eintrag löschen?'),
        content: Text('Soll der Serviceeintrag vom ${DateFormat('dd.MM.yyyy').format(eintrag.datum.toDate())} wirklich gelöscht werden?'),
        actions: [
          TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.pop(ctx, false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Löschen'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (sicher == true) {
      await widget.onDeleteServiceeintrag(eintrag.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviceeintrag gelöscht.'), backgroundColor: Colors.green),
        );
      }
    }
  }

  void _navigateToServiceeintragScreen({Serviceeintrag? eintrag}) {
    if (_selectedGeraet == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte zuerst ein Gerät auswählen.'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceeintragScreen(
      geraet: _selectedGeraet!,
      initialEintrag: eintrag,
      alleErsatzteile: widget.alleErsatzteile,
      onSave: eintrag != null ? widget.onUpdateServiceeintrag : widget.onAddServiceeintrag,
      onTeilVerbauen: widget.onTeilVerbauen,
    )));
  }


  // --- PDF GENERIERUNG ---
  Future<void> _generateServiceReportPdf(Serviceeintrag eintrag, Geraet geraet) async {
    try {
      final fontData = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
      final ttf = pw.Font.ttf(fontData);

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              pw.Center(
                child: pw.Text(
                  'Servicebericht',
                  style: pw.TextStyle(font: ttf, fontSize: 28, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Gerätedaten
              pw.Text('Geräteinformationen', style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _buildInfoRow(ttf, 'Modell:', geraet.modell),
              _buildInfoRow(ttf, 'Seriennummer:', geraet.seriennummer),
              if (geraet.kundeName != null && geraet.kundeName!.isNotEmpty)
                _buildInfoRow(ttf, 'Kunde:', geraet.kundeName!),
              if (geraet.standortName != null && geraet.standortName!.isNotEmpty)
                _buildInfoRow(ttf, 'Standort:', geraet.standortName!),
              _buildInfoRow(ttf, 'Status:', geraet.status),
              pw.SizedBox(height: 30),

              // Serviceeintrag Details
              pw.Text('Serviceeintrag Details', style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _buildInfoRow(ttf, 'Datum:', DateFormat('dd.MM.yyyy').format(eintrag.datum.toDate())),
              _buildInfoRow(ttf, 'Mitarbeiter:', eintrag.verantwortlicherMitarbeiter),
              pw.SizedBox(height: 15),

              pw.Text('Ausgeführte Arbeiten:', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                padding: const pw.EdgeInsets.all(10),
                child: pw.Text(eintrag.ausgefuehrteArbeiten, style: pw.TextStyle(font: ttf)),
              ),
              pw.SizedBox(height: 30),

              // Verbaute Teile
              if (eintrag.verbauteTeile.isNotEmpty) ...[
                pw.Text('Verbaute Teile', style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Table.fromTextArray(
                  headers: ['Menge', 'Bezeichnung', 'Artikel-Nr.'],
                  data: eintrag.verbauteTeile.map((teil) => [
                    '${teil.menge}x',
                    teil.ersatzteil.bezeichnung,
                    teil.ersatzteil.artikelnummer,
                  ]).toList(),
                  headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                  cellStyle: pw.TextStyle(font: ttf),
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  cellPadding: const pw.EdgeInsets.all(8),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(1.5),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FlexColumnWidth(2),
                  },
                ),
                pw.SizedBox(height: 30),
              ],

              // Anhänge
              if (eintrag.anhaenge.isNotEmpty) ...[
                pw.Text('Anhänge (Links):', style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                ...eintrag.anhaenge.map(
                      (anhang) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 5),
                    child: pw.UrlLink(
                      destination: anhang['url']!,
                      child: pw.Text(
                        '🔗 ${anhang['name']!}',
                        style: pw.TextStyle(
                          font: ttf,
                          color: PdfColors.blue,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              pw.Spacer(), // Schiebt den Footer nach unten
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'Generiert am ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey),
                ),
              ),
            ];
          },
        ),
      );
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Servicebericht_${geraet.seriennummer}_${DateFormat('yyyyMMdd_HHmm').format(eintrag.datum.toDate())}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Generieren des PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Hilfsfunktion für konsistente Info-Zeilen im PDF
  pw.Widget _buildInfoRow(pw.Font ttf, String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120, // Feste Breite für das Label
            child: pw.Text(label, style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: ttf)),
          ),
        ],
      ),
    );
  }


  Widget _buildGeraeteAuswahl() {
    List<Geraet> gefilterteGeraete = widget.alleGeraete;
    if (_searchTerm.isNotEmpty) {
      final s = _searchTerm.toLowerCase();
      gefilterteGeraete = widget.alleGeraete.where((g) =>
      g.seriennummer.toLowerCase().contains(s) ||
          g.modell.toLowerCase().contains(s) ||
          (g.kundeName ?? '').toLowerCase().contains(s) ||
          (g.nummer.isNotEmpty && g.nummer.toLowerCase().contains(s))
      ).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Gerät suchen (SN, Modell, Kunde, Lagernr.)',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _searchTerm.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchTerm = '');
                },
              )
                  : null,
            ),
            onChanged: (value) => setState(() => _searchTerm = value),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: gefilterteGeraete.length,
            itemBuilder: (ctx, index) {
              final geraet = gefilterteGeraete[index];
              final isLager = geraet.status == 'Im Lager';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isLager ? Colors.blueGrey : Colors.green,
                    child: Icon(isLager ? Icons.warehouse : Icons.person, color: Colors.white),
                  ),
                  title: Text('${geraet.modell} (SN: ${geraet.seriennummer})'),
                  subtitle: Text(isLager ? 'Status: Im Lager (Nr: ${geraet.nummer})' : 'Kunde: ${geraet.kundeName ?? 'N/A'}'),
                  onTap: () {
                    setState(() {
                      _selectedGeraet = geraet;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDetailAnsicht() {
    final geraet = _selectedGeraet!;
    final serviceHistorie = widget.alleServiceeintraege
        .where((e) => e.geraeteId == geraet.id)
        .toList();
    serviceHistorie.sort((a, b) => b.datum.compareTo(a.datum));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.grey.shade100,
            child: ListTile(
              title: Text(geraet.modell, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text('SN: ${geraet.seriennummer}\nKunde: ${geraet.kundeName ?? 'N/A'}'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Neuen Serviceeintrag erstellen'),
              onPressed: () => _navigateToServiceeintragScreen(),
            ),
          ),
          const Divider(height: 32),
          Text('Service-Historie', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Expanded(
            child: serviceHistorie.isEmpty
                ? const Center(child: Text('Für dieses Gerät gibt es keine Serviceeinträge.'))
                : ListView.builder(
              itemCount: serviceHistorie.length,
              itemBuilder: (ctx, index) {
                final eintrag = serviceHistorie[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    leading: CircleAvatar(child: Text((serviceHistorie.length - index).toString())),
                    title: Text('Eintrag vom ${DateFormat('dd.MM.yyyy').format(eintrag.datum.toDate())}'),
                    subtitle: Text('Mitarbeiter: ${eintrag.verantwortlicherMitarbeiter}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.print_outlined, color: Colors.blue),
                          tooltip: 'Servicebericht drucken',
                          onPressed: () => _generateServiceReportPdf(eintrag, geraet),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_note, color: Colors.orange),
                          tooltip: 'Eintrag bearbeiten',
                          onPressed: () => _navigateToServiceeintragScreen(eintrag: eintrag),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          tooltip: 'Eintrag löschen',
                          onPressed: () => _deleteServiceeintrag(eintrag),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ausgeführte Arbeiten:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(eintrag.ausgefuehrteArbeiten),
                            if (eintrag.verbauteTeile.isNotEmpty) ...[
                              const Divider(height: 24),
                              const Text('Bei diesem Service verbaute Teile:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...eintrag.verbauteTeile.map((teil) => Text('- ${teil.menge}x ${teil.ersatzteil.bezeichnung} (ArtNr: ${teil.ersatzteil.artikelnummer})')),
                            ],
                            if (eintrag.anhaenge.isNotEmpty) ...[
                              const Divider(height: 24),
                              const Text('Anhänge:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...eintrag.anhaenge.map((anhang) {
                                return ListTile(
                                  leading: const Icon(Icons.attach_file, color: Colors.blue),
                                  title: Text(anhang['name']!, style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
                                  dense: true,
                                  onTap: () => _openInNewTab(anhang['url']!),
                                );
                              })
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedGeraet == null ? 'Service: Gerät auswählen' : 'Service-Historie'),
        actions: [
          if (_selectedGeraet != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedGeraet = null;
                  _searchController.clear();
                  _searchTerm = '';
                });
              },
              child: const Text('Gerät wechseln', style: TextStyle(color: Colors.white)),
            )
        ],
      ),
      body: _selectedGeraet == null
          ? _buildGeraeteAuswahl()
          : _buildServiceDetailAnsicht(),
    );
  }
}