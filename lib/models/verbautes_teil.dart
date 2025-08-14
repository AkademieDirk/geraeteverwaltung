import 'package:cloud_firestore/cloud_firestore.dart';
import 'ersatzteil.dart';

class VerbautesTeil {
  final String id;
  final Ersatzteil ersatzteil;
  final DateTime installationsDatum;
  final double tatsaechlicherPreis;
  final String bemerkung;
  final String herkunftslager;
  final int menge;

  VerbautesTeil({
    required this.id,
    required this.ersatzteil,
    required this.installationsDatum,
    required this.tatsaechlicherPreis,
    this.bemerkung = '',
    required this.herkunftslager,
    this.menge = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ersatzteil': ersatzteil.toJson(),
      'installationsDatum': installationsDatum.toIso8601String(),
      'tatsaechlicherPreis': tatsaechlicherPreis,
      'bemerkung': bemerkung,
      'herkunftslager': herkunftslager,
      'menge': menge,
    };
  }

  factory VerbautesTeil.fromMap(Map<String, dynamic> map) {
    // --- ANFANG DER KORREKTUR ---
    DateTime installationsDatum;
    final rawDatum = map['installationsDatum'];

    if (rawDatum is Timestamp) {
      // Wenn das Datum ein Firestore-Timestamp ist, wandle es um.
      installationsDatum = rawDatum.toDate();
    } else if (rawDatum is String) {
      // Wenn es ein String ist, parse es.
      installationsDatum = DateTime.parse(rawDatum);
    } else {
      // Fallback, falls das Feld fehlt oder null ist.
      installationsDatum = DateTime.now();
    }
    // --- ENDE DER KORREKTUR ---

    return VerbautesTeil(
      id: map['id'] ?? '',
      ersatzteil: Ersatzteil.fromMap(map['ersatzteil']),
      installationsDatum: installationsDatum, // Das umgewandelte Datum wird verwendet
      tatsaechlicherPreis: (map['tatsaechlicherPreis'] as num?)?.toDouble() ?? 0.0,
      bemerkung: map['bemerkung'] ?? '',
      herkunftslager: map['herkunftslager'] ?? '',
      menge: map['menge'] ?? 1,
    );
  }
}