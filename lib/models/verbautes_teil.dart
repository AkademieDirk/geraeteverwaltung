import 'package:cloud_firestore/cloud_firestore.dart';
import 'ersatzteil.dart';

class VerbautesTeil {
  final String id;
  final Ersatzteil ersatzteil;
  final DateTime installationsDatum;
  final String bemerkung;
  final double tatsaechlicherPreis;
  final String herkunftslager;

  VerbautesTeil({
    required this.id,
    required this.ersatzteil,
    required this.installationsDatum,
    this.bemerkung = '',
    required this.tatsaechlicherPreis,
    required this.herkunftslager, // KORREKTUR: Fehlender Parameter hinzugefügt
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ersatzteil': ersatzteil.toJson(),
      'ersatzteilId': ersatzteil.id,
      'installationsDatum': Timestamp.fromDate(installationsDatum),
      'bemerkung': bemerkung,
      'tatsaechlicherPreis': tatsaechlicherPreis,
      'herkunftslager': herkunftslager,
    };
  }

  static VerbautesTeil fromMap(Map<String, dynamic> map) {
    return VerbautesTeil(
      id: map['id'] ?? '',
      ersatzteil: Ersatzteil.fromMap(map['ersatzteil']),
      installationsDatum: (map['installationsDatum'] as Timestamp).toDate(),
      bemerkung: map['bemerkung'] ?? '',
      tatsaechlicherPreis: (map['tatsaechlicherPreis'] as num?)?.toDouble() ?? 0.0,
      herkunftslager: map['herkunftslager'] ?? 'Unbekannt',
    );
  }
}
