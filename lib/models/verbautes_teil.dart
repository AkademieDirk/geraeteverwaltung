// lib/models/verbautes_teil.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'ersatzteil.dart';

/// Repräsentiert ein Ersatzteil, das zu einem bestimmten Zeitpunkt
/// in einem Gerät verbaut wurde, mit der Möglichkeit für abweichende Daten.
class VerbautesTeil {
  final String id; // Eindeutige ID für diesen spezifischen Einbau
  final Ersatzteil ersatzteil;
  final DateTime installationsDatum;
  final String bemerkung; // NEU: Feld für Abweichungen oder Notizen
  final double tatsaechlicherPreis; // NEU: Preis zum Zeitpunkt des Einbaus

  VerbautesTeil({
    required this.id,
    required this.ersatzteil,
    required this.installationsDatum,
    this.bemerkung = '',
    required this.tatsaechlicherPreis,
  });

  /// Wandelt das Objekt in eine Map für Firestore um.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ersatzteil': ersatzteil.toJson(), // Speichert eine Kopie der Ersatzteildaten
      'ersatzteilId': ersatzteil.id,
      'installationsDatum': Timestamp.fromDate(installationsDatum),
      'bemerkung': bemerkung,
      'tatsaechlicherPreis': tatsaechlicherPreis,
    };
  }

  /// Erstellt ein Objekt aus einer Firestore-Map.
  static VerbautesTeil fromMap(Map<String, dynamic> map) {
    return VerbautesTeil(
      id: map['id'] ?? '',
      ersatzteil: Ersatzteil.fromMap(map['ersatzteil']),
      installationsDatum: (map['installationsDatum'] as Timestamp).toDate(),
      bemerkung: map['bemerkung'] ?? '',
      tatsaechlicherPreis: (map['tatsaechlicherPreis'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Auch das Ersatzteil-Modell braucht eine fromMap-Methode für die Konvertierung.
// Bitte stellen Sie sicher, dass Ihre ersatzteil.dart so aussieht:
/*
class Ersatzteil {
  String id;
  String artikelnummer;
  String bezeichnung;
  String lieferant;
  double preis;
  String kategorie;

  Ersatzteil({ ... });
  Map<String, dynamic> toJson() { ... }
  static Ersatzteil fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) { ... }

  // NEUE METHODE HINZUFÜGEN:
  static Ersatzteil fromMap(Map<String, dynamic> map) {
    return Ersatzteil(
      id: map['id'] ?? '',
      artikelnummer: map['artikelnummer'] ?? '',
      bezeichnung: map['bezeichnung'] ?? '',
      lieferant: map['lieferant'] ?? '',
      preis: (map['preis'] as num?)?.toDouble() ?? 0.0,
      kategorie: map['kategorie'] ?? '',
    );
  }
}
*/
