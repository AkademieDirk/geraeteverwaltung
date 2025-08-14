import 'package:flutter/material.dart';


import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/geraet.dart';
import '../models/kunde.dart';
import '../models/standort.dart';

import '../widgets/bestandsliste_gruppe.dart';

class BestandslisteScreen extends StatefulWidget {
  final List<Geraet> alleGeraete;
  final Future<void> Function(Geraet) onUpdate;
  final Future<void> Function(String) onDelete;
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

  // --- NEUER FILTER ---
  String _selectedMaschinenblattFilter = 'Alle';
  final List<String> _maschinenblattFilterOptionen = ['Alle', 'Ja', 'Nein'];

  @override
  void dispose() {
    _suchController.dispose();
    super.dispose();
  }

  Future<void> _printBestandsliste(Map<String, List<Geraet>> gruppierteGeraete) async {
    final pdf = pw.Document();
    final sortierteModelle = gruppierteGeraete.keys.toList()..sort();

    final gesamtAnzahl = gruppierteGeraete.values.fold<int>(0, (sum, list) => sum + list.length);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.centerLeft,
              margin: const pw.EdgeInsets.only(bottom: 20.0),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Bestandsliste Lager', style: pw.Theme.of(context).header1),
                    pw.Text('Gedruckt am: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}'),
                    pw.Text('Gesamtanzahl Geräte: $gesamtAnzahl'),
                  ]
              )
          );
        },
        build: (pw.Context context) {
          List<pw.Widget> content = [];

          for (var modell in sortierteModelle) {
            final geraeteInGruppe = gruppierteGeraete[modell]!;

            content.add(pw.Header(
              level: 1,
              text: '$modell (${geraeteInGruppe.length} Stk.)',
            ));

            // --- DRUCKFUNKTION ERWEITERT ---
            content.add(pw.TableHelper.fromTextArray(
                headers: ['Lager-Nr.', 'Seriennummer', 'Maschinenblatt', 'Zähler'],
                data: geraeteInGruppe.map((g) => [
                  g.nummer,
                  g.seriennummer,
                  g.maschinenblattErstellt,
                  g.zaehlerGesamt.isNotEmpty ? g.zaehlerGesamt : 'k.A.',
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 10),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.5),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                }
            ));
            content.add(pw.SizedBox(height: 20));
          }
          return content;
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> _importGeraete() async {
    // Implementierung...
  }

  void _showZuordnungsDialog(Geraet geraet) {
    // Implementierung...
  }

  void _showDeleteConfirmationDialog(Geraet geraet) {
    // Implementierung...
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

    // --- NEUER FILTER WIRD ANGEWENDET ---
    if (_selectedMaschinenblattFilter != 'Alle') {
      gefilterteListe = gefilterteListe.where((g) => g.maschinenblattErstellt == _selectedMaschinenblattFilter).toList();
    }

    if (_suchbegriff.isNotEmpty) {
      final begriff = _suchbegriff.toLowerCase();
      gefilterteListe = gefilterteListe.where((g) =>
      g.nummer.toLowerCase().contains(begriff) ||
          g.modell.toLowerCase().contains(begriff) ||
          g.seriennummer.toLowerCase().contains(begriff) ||
          g.lieferant.toLowerCase().contains(begriff) ||
          g.mitarbeiter.toLowerCase().contains(begriff) ||
          g.bemerkung.toLowerCase().contains(begriff) ||
          g.originaleinzugSN.toLowerCase().contains(begriff) ||
          g.unterschrankSN.toLowerCase().contains(begriff) ||
          g.finisherSN.toLowerCase().contains(begriff)
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
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Bestandsliste drucken',
            onPressed: () => _printBestandsliste(gruppierteGeraete),
          ),
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
                    decoration: InputDecoration(labelText: 'Volltextsuche im Bestand...', prefixIcon: const Icon(Icons.search), suffixIcon: _suchbegriff.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { setState(() { _suchController.clear(); _suchbegriff = ''; }); }) : null, border: const OutlineInputBorder()),
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
          // --- NEUES FILTER-DROPDOWN ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedMaschinenblattFilter,
              decoration: const InputDecoration(labelText: 'Filter: Maschinenblatt', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)),
              items: _maschinenblattFilterOptionen.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
              onChanged: (newValue) => setState(() => _selectedMaschinenblattFilter = newValue!),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Gefundene Geräte: ${gefilterteListe.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
          Expanded(
            child: gruppierteGeraete.isEmpty
                ? const Center(child: Text('Keine Geräte für die Auswahl gefunden.'))
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: sortierteModelle.length,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.green,
                thickness: 1,
              ),
              itemBuilder: (ctx, index) {
                final modell = sortierteModelle[index];
                final geraeteInGruppe = gruppierteGeraete[modell]!;

                return BestandslisteGruppe(
                  modell: modell,
                  geraeteInGruppe: geraeteInGruppe,
                  alleGeraete: widget.alleGeraete,
                  onUpdate: widget.onUpdate,
                  onImport: widget.onImport,
                  onShowZuordnungsDialog: _showZuordnungsDialog,
                  onShowDeleteDialog: _showDeleteConfirmationDialog,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}