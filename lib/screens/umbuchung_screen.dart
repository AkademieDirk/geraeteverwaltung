import 'package:flutter/material.dart';
import 'package:projekte/models/ersatzteil.dart';

class UmbuchungScreen extends StatefulWidget {
  final List<Ersatzteil> alleErsatzteile;
  final Future<void> Function(Ersatzteil teil, String von, String nach, int anzahl) onTransfer;

  const UmbuchungScreen({
    Key? key,
    required this.alleErsatzteile,
    required this.onTransfer,
  }) : super(key: key);

  @override
  State<UmbuchungScreen> createState() => _UmbuchungScreenState();
}

class _UmbuchungScreenState extends State<UmbuchungScreen> {
  final _formKey = GlobalKey<FormState>();
  Ersatzteil? _selectedTeil;
  String? _vonLager;
  String? _nachLager;
  final _anzahlController = TextEditingController();

  final List<String> _lagerOrte = ['Hauptlager', 'Fahrzeug Patrick', 'Fahrzeug Melanie'];

  void _umbuchen() async {
    if (_formKey.currentState!.validate()) {
      try {
        await widget.onTransfer(
          _selectedTeil!,
          _vonLager!,
          _nachLager!,
          int.parse(_anzahlController.text),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Umbuchung erfolgreich!'), backgroundColor: Colors.green),
        );
        setState(() {
          _selectedTeil = null;
          _vonLager = null;
          _nachLager = null;
          _anzahlController.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler bei Umbuchung: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bestand umbuchen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<Ersatzteil>(
                    value: _selectedTeil,
                    hint: const Text('Ersatzteil auswählen'),
                    isExpanded: true,
                    items: widget.alleErsatzteile.map((teil) {
                      return DropdownMenuItem(
                        value: teil,
                        child: Text(teil.bezeichnung, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedTeil = val),
                    validator: (val) => val == null ? 'Bitte ein Teil auswählen' : null,
                  ),
                  const SizedBox(height: 16),
                  if (_selectedTeil != null) ...[
                    DropdownButtonFormField<String>(
                      value: _vonLager,
                      hint: const Text('Von Lager...'),
                      items: _lagerOrte.map((lager) {
                        // --- ANFANG DER ÄNDERUNG ---
                        // Greift jetzt auf die 'menge' im LagerbestandEintrag zu
                        final bestand = _selectedTeil!.lagerbestaende[lager]?.menge ?? 0;
                        // --- ENDE DER ÄNDERUNG ---
                        return DropdownMenuItem(value: lager, child: Text('$lager ($bestand Stk.)'));
                      }).toList(),
                      onChanged: (val) => setState(() => _vonLager = val),
                      validator: (val) => val == null ? 'Bitte ein Start-Lager auswählen' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _nachLager,
                      hint: const Text('Nach Lager...'),
                      items: _lagerOrte.where((l) => l != _vonLager).map((lager) {
                        return DropdownMenuItem(value: lager, child: Text(lager));
                      }).toList(),
                      onChanged: (val) => setState(() => _nachLager = val),
                      validator: (val) => val == null ? 'Bitte ein Ziel-Lager auswählen' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _anzahlController,
                      decoration: const InputDecoration(labelText: 'Anzahl'),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Bitte Anzahl eingeben';
                        final anzahl = int.tryParse(val);
                        if (anzahl == null || anzahl <= 0) return 'Ungültige Anzahl';
                        // --- ANFANG DER ÄNDERUNG ---
                        final bestand = _selectedTeil!.lagerbestaende[_vonLager!]?.menge ?? 0;
                        // --- ENDE DER ÄNDERUNG ---
                        if (anzahl > bestand) return 'Nicht genügend Bestand in $_vonLager';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.sync_alt),
                      label: const Text('Umbuchen'),
                      onPressed: _umbuchen,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}