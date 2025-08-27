import 'package:flutter/material.dart';
import 'package:projekte/models/geraet.dart';
import 'package:projekte/screens/geraeteaufnahme/geraeteaufnahme_screen.dart';

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
          final bool maschinenblattVorhanden = g.maschinenblattErstellt == 'Ja';
          final iconColor = maschinenblattVorhanden ? Colors.green : Colors.red;
          final iconData = maschinenblattVorhanden ? Icons.check_circle : Icons.cancel;

          return ListTile(
            contentPadding: const EdgeInsets.only(left: 4, right: 16),
            horizontalTitleGap: 8,
            leading: CircleAvatar(
              child: Text(g.nummer, textAlign: TextAlign.center),
            ),
            title: Row(
              children: [
                Text('SN: ${g.seriennummer}'),

                // --- ANFANG DER KORREKTUR ---
                // Der Spacer wurde durch eine SizedBox mit fester Breite ersetzt.
                // Ändere den 'width'-Wert, um den Abstand anzupassen.
                const SizedBox(width: 150),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Zähler: ${g.zaehlerGesamt.isNotEmpty ? g.zaehlerGesamt : 'k.A.'}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      g.originaleinzugTyp.isNotEmpty ? g.originaleinzugTyp : 'k.A.',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      g.unterschrankTyp.isNotEmpty && g.unterschrankTyp != 'Kein'
                          ? g.unterschrankTyp
                          : 'Ohne US',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: g.unterschrankTyp.isNotEmpty && g.unterschrankTyp != 'Kein'
                            ? Colors.purple.shade300
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
                // --- ENDE DER KORREKTUR ---
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(iconData, color: iconColor),
                  tooltip: 'Maschinenblatt: ${g.maschinenblattErstellt}',
                  onPressed: () {
                    final neuerStatus = maschinenblattVorhanden ? 'Nein' : 'Ja';
                    final geaendertesGeraet = g.copyWith(maschinenblattErstellt: neuerStatus);
                    onUpdate(geaendertesGeraet);
                  },
                ),
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