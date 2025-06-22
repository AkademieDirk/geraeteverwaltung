import 'package:flutter/material.dart';
import '../../models/geraet.dart';
import 'geraete_form.dart';

class GeraeteAufnahmeScreen extends StatelessWidget {
  final List<Geraet> vorhandeneGeraete;
  final Geraet? initialGeraet;

  const GeraeteAufnahmeScreen({
    Key? key,
    required this.vorhandeneGeraete,
    this.initialGeraet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geräteaufnahme')),
      body: GeraeteForm(
        vorhandeneGeraete: vorhandeneGeraete,
        initialGeraet: initialGeraet,
      ),
    );
  }
}
