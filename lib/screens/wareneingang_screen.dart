import 'package:flutter/material.dart';
import '../models/ersatzteil.dart';

class WareneingangScreen extends StatefulWidget {
  final List<Ersatzteil> alleErsatzteile;
  final Future<void> Function(Ersatzteil teil, String lager, int anzahl) onBookIn;

  const WareneingangScreen({
    Key? key,
    required this.alleErsatzteile,
    required this.onBookIn,
  }) : super(key: key);

  @override
  State<WareneingangScreen> createState() => _WareneingangScreenState();
}

class _WareneingangScreenState extends State<WareneingangScreen> {
  final _formKey = GlobalKey<FormState>();
  final _artikelnummerController = TextEditingController();
  final _anzahlController = TextEditingController();

  Ersatzteil? _gefundenesTeil;
  String? _selectedLager;

  final List<String> _lagerOrte = ['Hauptlager', 'Fahrzeug Patrick', 'Fahrzeug Melanie'];

  void _sucheArtikel() {
    final artikelnummer = _artikelnummerController.text.trim();
    if (artikelnummer.isEmpty) return;

    try {
      final ersatzteil = widget.alleErsatzteile.firstWhere(
            (teil) => teil.artikelnummer == artikelnummer,
      );
      setState(() {
        _gefundenesTeil = ersatzteil;
      });
    } catch (e) {
      setState(() {
        _gefundenesTeil = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artikelnummer nicht gefunden.'), backgroundColor: Colors.red),
      );
    }
  }

  void _wareEinbuchen() async {
    if (_formKey.currentState!.validate()) {
      try {
        await widget.onBookIn(
          _gefundenesTeil!,
          _selectedLager!,
          int.parse(_anzahlController.text),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ware erfolgreich verbucht!'), backgroundColor: Colors.green),
        );
        setState(() {
          _gefundenesTeil = null;
          _selectedLager = null;
          _artikelnummerController.clear();
          _anzahlController.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Buchen: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wareneingang / Inventur'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _artikelnummerController,
                        decoration: InputDecoration(
                          labelText: 'Artikelnummer scannen/eingeben',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner),
                            onPressed: _sucheArtikel,
                            tooltip: 'Suchen',
                          ),
                        ),
                        onFieldSubmitted: (_) => _sucheArtikel(),
                      ),
                      if (_gefundenesTeil != null) ...[
                        const SizedBox(height: 24),
                        Text(_gefundenesTeil!.bezeichnung, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Aktueller Gesamtbestand: ${_gefundenesTeil!.getGesamtbestand()} Stk.'),
                        const Divider(height: 32),
                        TextFormField(
                          controller: _anzahlController,
                          decoration: const InputDecoration(labelText: 'Anzahl zum Einbuchen'),
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Bitte Anzahl eingeben.';
                            if (int.tryParse(val) == null || int.parse(val) <= 0) return 'Ungültige Anzahl.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedLager,
                          hint: const Text('Ziel-Lager auswählen'),
                          items: _lagerOrte.map((lager) => DropdownMenuItem(value: lager, child: Text(lager))).toList(),
                          onChanged: (val) => setState(() => _selectedLager = val),
                          validator: (val) => val == null ? 'Bitte ein Lager auswählen.' : null,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.inventory),
                          label: const Text('Einbuchen'),
                          onPressed: _wareEinbuchen,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
