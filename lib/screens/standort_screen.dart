import 'package:flutter/material.dart';
import '../models/kunde.dart';
import '../models/standort.dart';

class StandortScreen extends StatefulWidget {
  final Kunde kunde;
  final List<Standort> alleStandorte;
  final Future<void> Function(Standort) onAdd;
  final Future<void> Function(Standort) onUpdate;
  final Future<void> Function(String) onDelete;

  const StandortScreen({
    Key? key,
    required this.kunde,
    required this.alleStandorte,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<StandortScreen> createState() => _StandortScreenState();
}

class _StandortScreenState extends State<StandortScreen> {
  late List<Standort> _kundenStandorte;

  @override
  void initState() {
    super.initState();
    _filterStandorte();
  }

  @override
  void didUpdateWidget(StandortScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alleStandorte != oldWidget.alleStandorte) {
      _filterStandorte();
    }
  }

  void _filterStandorte() {
    setState(() {
      _kundenStandorte = widget.alleStandorte.where((s) => s.kundeId == widget.kunde.id).toList();
    });
  }

  void _standortDialog({Standort? standort}) {
    final isEdit = standort != null;

    final nameController = TextEditingController(text: standort?.name ?? '');
    final strasseController = TextEditingController(text: standort?.strasse ?? '');
    final plzController = TextEditingController(text: standort?.plz ?? '');
    final ortController = TextEditingController(text: standort?.ort ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Standort bearbeiten' : 'Neuer Standort'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name (z.B. Zentrale)*')),
              TextField(controller: strasseController, decoration: const InputDecoration(labelText: 'Straße')),
              TextField(controller: plzController, decoration: const InputDecoration(labelText: 'PLZ')),
              TextField(controller: ortController, decoration: const InputDecoration(labelText: 'Ort')),
            ],
          ),
        ),
        actions: [
          TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.of(ctx).pop()),
          ElevatedButton(
            child: Text(isEdit ? 'Speichern' : 'Hinzufügen'),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte einen Namen für den Standort angeben!')));
                return;
              }

              final neuerStandort = Standort(
                id: isEdit ? standort.id : '',
                kundeId: widget.kunde.id,
                name: name,
                strasse: strasseController.text.trim(),
                plz: plzController.text.trim(),
                ort: ortController.text.trim(),
              );

              if (isEdit) {
                await widget.onUpdate(neuerStandort);
              } else {
                await widget.onAdd(neuerStandort);
              }

              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _deleteStandort(Standort standort) async {
    final sicher = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wirklich löschen?'),
        content: Text('Standort "${standort.name}" wirklich löschen?'),
        actions: [
          TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.pop(ctx, false)),
          TextButton(child: Text('Löschen', style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (sicher == true) {
      await widget.onDelete(standort.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Standorte für: ${widget.kunde.name}'),
      ),
      body: ListView.builder(
        itemCount: _kundenStandorte.length,
        itemBuilder: (context, index) {
          final standort = _kundenStandorte[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.location_city)),
              title: Text(standort.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${standort.strasse}, ${standort.plz} ${standort.ort}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.orange), tooltip: 'Bearbeiten', onPressed: () => _standortDialog(standort: standort)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), tooltip: 'Löschen', onPressed: () => _deleteStandort(standort)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _standortDialog(),
        tooltip: 'Neuer Standort',
        child: const Icon(Icons.add_location_alt_outlined),
      ),
    );
  }
}
