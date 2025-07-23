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
  final List<Kunde> kunden;
  final List<Standort> standorte;
  final Future<void> Function(Geraet, Kunde, Standort) onAssign;
  final Future<void> Function(List<Geraet>) onImport;

  const GeraeteListeScreen({
    Key? key,
    required this.geraete,
    required this.onUpdate,
    required this.onDelete,
    required this.kunden,
    required this.standorte,
    required this.onAssign,
    required this.onImport,
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
    return value.toString();
  }

  // --- ANFANG DER ÄNDERUNG: Filtert jetzt nur noch ausgelieferte Geräte ---
  List<Geraet> get _gefilterteGeraete {
    // 1. Filtert die Gesamtliste, um nur Geräte zu erhalten, die ausgeliefert wurden (keine interne Nummer mehr haben)
    final ausgelieferteGeraete = widget.geraete.where((g) => g.nummer.isEmpty).toList();

    // 2. Wendet den Suchbegriff auf die bereits gefilterte Liste an
    if (_suchbegriff.isEmpty) {
      return ausgelieferteGeraete;
    } else {
      final begriff = _suchbegriff.toLowerCase();
      return ausgelieferteGeraete.where((g) =>
      safeToString(g.modell).toLowerCase().contains(begriff) ||
          safeToString(g.seriennummer).toLowerCase().contains(begriff) ||
          safeToString(g.kundeName ?? '').toLowerCase().contains(begriff) ||
          safeToString(g.standortName ?? '').toLowerCase().contains(begriff)
      ).toList();
    }
  }
  // --- ENDE DER ÄNDERUNG ---

  Future<void> _druckeGeraetAsPdf(Geraet g) async {
    // PDF Logic remains unchanged
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Geräteliste (Ausgeliefert)')),
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
                ? Center(child: Text('Keine ausgelieferten Geräte gefunden.'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _gefilterteGeraete.length,
              itemBuilder: (ctx, index) {
                final g = _gefilterteGeraete[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 3,
                  child: ExpansionTile(
                    title: Text('${g.modell} (SN: ${g.seriennummer})', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Kunde: ${g.kundeName ?? ''} - ${g.standortName ?? ''}', style: TextStyle(color: Colors.blue)),
                    children: [
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(icon: Icon(Icons.edit, color: Colors.orange), tooltip: 'Bearbeiten', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GeraeteAufnahmeScreen(initialGeraet: g, onSave: widget.onUpdate, onImport: widget.onImport)))),
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
}
