import 'package:cloud_firestore/cloud_firestore.dart';

class Ersatzteil {
  String id;
  String artikelnummer;
  String bezeichnung;
  String lieferant;
  double preis;
  String kategorie;

  Ersatzteil({
    this.id = '',
    required this.artikelnummer,
    required this.bezeichnung,
    required this.lieferant,
    required this.preis,
    required this.kategorie,
  });

  Map<String, dynamic> toJson() {
    return {
      'artikelnummer': artikelnummer,
      'bezeichnung': bezeichnung,
      'lieferant': lieferant,
      'preis': preis,
      'kategorie': kategorie,
    };
  }

  static Ersatzteil fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return Ersatzteil(
      id: doc.id,
      artikelnummer: data['artikelnummer'] ?? '',
      bezeichnung: data['bezeichnung'] ?? '',
      lieferant: data['lieferant'] ?? '',
      preis: (data['preis'] as num?)?.toDouble() ?? 0.0,
      kategorie: data['kategorie'] ?? '',
    );
  }

  // --- NEU: Diese Methode hat gefehlt ---
  // Erstellt ein Ersatzteil-Objekt aus einer einfachen Map.
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
