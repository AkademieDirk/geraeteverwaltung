import 'package:flutter/material.dart';
import '../models/geraet.dart';
import '../screens/geraeteaufnahme/geraeteaufnahme_screen.dart';

class BestandslisteGruppe extends StatelessWidget {
  final String modell;
  final List<Geraet> geraeteInGruppe;
  final List<Geraet> alleGeraete;
  final Future<void> Function(Geraet) onUpdate;
  final Future<void> Function(List<Geraet>) onImport;
  final Function(Geraet) onShowZuordnungsDialog;
  final Function(Geraet) onShowDeleteDialog;

  const BestandslisteGruppe({
    Key? key,
    required this.modell,
    required this.geraeteInGruppe,
    required this.alleGeraete,
    required this.onUpdate,
    required this.onImport,
    required this.onShowZuordnungsDialog,
    required this.onShowDeleteDialog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          '$modell (${geraeteInGruppe.length} Stk.)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        children: geraeteInGruppe.map((g) {
          // --- ANFANG DER ÄNDERUNG ---
          // Bestimmt die Farbe und das Icon basierend auf dem Status
          final bool maschinenblattVorhanden = g.maschinenblattErstellt == 'Ja';
          final iconColor = maschinenblattVorhanden ? Colors.green : Colors.red;
          final iconData = maschinenblattVorhanden ? Icons.check_circle : Icons.cancel;
          // --- ENDE DER ÄNDERUNG ---

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
                // --- ANFANG DER ÄNDERUNG ---
                // Neuer IconButton, um den Status zu ändern und anzuzeigen
                IconButton(
                  icon: Icon(iconData, color: iconColor),
                  tooltip: 'Maschinenblatt: ${g.maschinenblattErstellt}',
                  onPressed: () {
                    // Kehrt den aktuellen Wert um
                    final neuerStatus = maschinenblattVorhanden ? 'Nein' : 'Ja';
                    // Erstellt eine Kopie des Geräts mit dem neuen Status
                    final geaendertesGeraet = g.copyWith(maschinenblattErstellt: neuerStatus);
                    // Speichert die Änderung sofort
                    onUpdate(geaendertesGeraet);
                  },
                ),
                // --- ENDE DER ÄNDERUNG ---

                IconButton(icon: const Icon(Icons.local_shipping, color: Colors.blueAccent), tooltip: 'Ausliefern', onPressed: () => onShowZuordnungsDialog(g)),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  tooltip: 'Bearbeiten',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => GeraeteAufnahmeScreen(
                      initialGeraet: g,
                      onSave: onUpdate,
                      onImport: onImport,
                      alleGeraete: alleGeraete,
                    ),
                  )),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: 'Löschen',
                  onPressed: () => onShowDeleteDialog(g),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}