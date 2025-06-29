import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/verbautes_teil.dart';

class HistorieScreen extends StatefulWidget {
  final Map<String, List<VerbautesTeil>> verbauteTeile;
  final Future<void> Function(String seriennummer, VerbautesTeil teil) onDelete;
  final Future<void> Function(String seriennummer, VerbautesTeil teil) onUpdate;

  const HistorieScreen({
    Key? key,
    required this.verbauteTeile,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<HistorieScreen> createState() => _HistorieScreenState();
}

class _HistorieScreenState extends State<HistorieScreen> {
  final TextEditingController _seriennummerController = TextEditingController();
  List<VerbautesTeil> _gefundeneTeile = [];
  double _gesamtkosten = 0.0;
  String _angezeigteSeriennummer = '';
  List<String> _suchergebnisse = [];

  @override
  void dispose() {
    _seriennummerController.dispose();
    super.dispose();
  }

  void _sucheHistorie() {
    final suchbegriff = _seriennummerController.text.trim().toLowerCase();

    setState(() {
      _gefundeneTeile = [];
      _angezeigteSeriennummer = '';
      _gesamtkosten = 0.0;
      _suchergebnisse = [];
    });

    if (suchbegriff.isEmpty) {
      return;
    }

    final treffer = widget.verbauteTeile.keys
        .where((seriennummer) => seriennummer.toLowerCase().contains(suchbegriff))
        .toList();

    if (treffer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Für diesen Suchbegriff wurde keine Historie gefunden.')),
      );
    } else if (treffer.length == 1) {
      _zeigeHistorieFuer(treffer.first);
    } else {
      setState(() {
        _suchergebnisse = treffer;
      });
    }
  }

  void _zeigeHistorieFuer(String seriennummer) {
    final teile = widget.verbauteTeile[seriennummer]!;
    final summe = teile.fold(0.0, (total, verbautesTeil) => total + verbautesTeil.tatsaechlicherPreis);

    setState(() {
      _gefundeneTeile = teile;
      _gesamtkosten = summe;
      _angezeigteSeriennummer = seriennummer;
      _suchergebnisse = [];
      _seriennummerController.text = seriennummer;
    });
  }

  // --- GEÄNDERT: Fügt try-catch für besseres Feedback hinzu ---
  void _loescheVerbautesTeil(VerbautesTeil teil) async {
    final sicher = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eintrag löschen?'),
        content: Text('Soll der Eintrag "${teil.ersatzteil.bezeichnung}" wirklich aus der Historie gelöscht werden?'),
        actions: [
          TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.pop(ctx, false)),
          TextButton(child: Text('Löschen', style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );

    if (sicher == true && mounted) {
      try {
        await widget.onDelete(_angezeigteSeriennummer, teil);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eintrag erfolgreich gelöscht.'), backgroundColor: Colors.green),
        );
        // Die UI wird automatisch durch den StreamBuilder aktualisiert.
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _bearbeiteVerbautesTeilDialog(VerbautesTeil teil) {
    final preisController = TextEditingController(text: teil.tatsaechlicherPreis.toStringAsFixed(2));
    final bemerkungController = TextEditingController(text: teil.bemerkung);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eintrag bearbeiten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(teil.ersatzteil.bezeichnung, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextField(controller: preisController, decoration: InputDecoration(labelText: 'Tatsächlicher Preis', border: OutlineInputBorder(), suffixText: '€'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
            SizedBox(height: 16),
            TextField(controller: bemerkungController, decoration: InputDecoration(labelText: 'Bemerkung (z.B. Abweichung)', border: OutlineInputBorder()), maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              final neuerPreis = double.tryParse(preisController.text.replaceAll(',', '.')) ?? teil.tatsaechlicherPreis;
              final geandertesTeil = VerbautesTeil(
                id: teil.id,
                ersatzteil: teil.ersatzteil,
                installationsDatum: teil.installationsDatum,
                tatsaechlicherPreis: neuerPreis,
                bemerkung: bemerkungController.text.trim(),
                herkunftslager: teil.herkunftslager,
              );
              await widget.onUpdate(_angezeigteSeriennummer, geandertesTeil);
              Navigator.pop(context);
            },
            child: Text('Speichern'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geräte-Historie')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _seriennummerController,
                  decoration: InputDecoration(labelText: 'Seriennummer suchen', hintText: 'Auch Teile der Nummer sind möglich...', border: const OutlineInputBorder(), suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _sucheHistorie, tooltip: 'Historie suchen')),
                  onSubmitted: (_) => _sucheHistorie(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _suchergebnisse.isNotEmpty
                    ? _buildSuchergebnisListe()
                    : _buildHistorienAnsicht(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuchergebnisListe() {
    return Column(
      key: const ValueKey('ergebnisliste'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text('${_suchergebnisse.length} Treffer gefunden. Bitte auswählen:', style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _suchergebnisse.length,
            itemBuilder: (context, index) {
              final seriennummer = _suchergebnisse[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(title: Text(seriennummer), leading: const Icon(Icons.receipt_long), trailing: const Icon(Icons.arrow_forward_ios), onTap: () => _zeigeHistorieFuer(seriennummer)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistorienAnsicht() {
    if (_angezeigteSeriennummer.isEmpty) {
      return const Center(
        key: ValueKey('leere_ansicht'),
        child: Text('Bitte eine Seriennummer eingeben, um die Historie anzuzeigen.'),
      );
    }
    if (_gefundeneTeile.isEmpty) {
      return Center(
        key: ValueKey('keine_teile'),
        child: Text('Für die Seriennummer $_angezeigteSeriennummer wurden keine Teile verbaut.'),
      );
    }
    return Column(
      key: ValueKey(_angezeigteSeriennummer),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Gesamtkosten:', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)), Text('${_gesamtkosten.toStringAsFixed(2)} €', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))]),
          ),
        ),
        const SizedBox(height: 16),
        Text('Verbaute Teile für: $_angezeigteSeriennummer', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _gefundeneTeile.length,
            itemBuilder: (context, index) {
              final verbautes = _gefundeneTeile[index];
              final teil = verbautes.ersatzteil;
              final datum = DateFormat('dd.MM.yyyy').format(verbautes.installationsDatum);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ExpansionTile(
                  title: Text(teil.bezeichnung, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Verbaut am: $datum', style: TextStyle(color: Colors.grey.shade600)),
                  leading: CircleAvatar(child: Text((index + 1).toString())),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_note, color: Colors.blue), tooltip: 'Diesen Eintrag bearbeiten', onPressed: () => _bearbeiteVerbautesTeilDialog(verbautes)),
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), tooltip: 'Diesen Eintrag löschen', onPressed: () => _loescheVerbautesTeil(verbautes)),
                    ],
                  ),
                  children: [
                    ListTile(title: Text('${verbautes.tatsaechlicherPreis.toStringAsFixed(2)} €'), subtitle: const Text('Tatsächlicher Preis'), leading: const Icon(Icons.euro_symbol)),
                    if (verbautes.bemerkung.isNotEmpty) ListTile(title: Text(verbautes.bemerkung), subtitle: const Text('Bemerkung'), leading: const Icon(Icons.notes)),
                    ListTile(title: Text(teil.artikelnummer), subtitle: const Text('Artikelnummer'), leading: const Icon(Icons.qr_code)),
                    ListTile(title: Text('aus: ${verbautes.herkunftslager}'), subtitle: const Text('Herkunftslager'), leading: const Icon(Icons.warehouse)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
