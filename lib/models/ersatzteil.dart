import 'package:cloud_firestore/cloud_firestore.dart';

// NEUE HILFSKLASSE für den Lagerbestand
class LagerbestandEintrag {
  final int menge;
  final Timestamp letzteAenderung;

  LagerbestandEintrag({required this.menge, required this.letzteAenderung});

  // Wandelt das Objekt in eine Map für Firestore um
  Map<String, dynamic> toJson() => {
    'menge': menge,
    'letzteAenderung': letzteAenderung,
  };

  // Erstellt das Objekt aus Firestore-Daten
  factory LagerbestandEintrag.fromMap(Map<String, dynamic> map) {
    return LagerbestandEintrag(
      menge: (map['menge'] as num?)?.toInt() ?? 0,
      letzteAenderung: map['letzteAenderung'] as Timestamp? ?? Timestamp.now(),
    );
  }
}

class Ersatzteil {
  String id;
  String artikelnummer;
  String bezeichnung;
  String hersteller;
  String haendlerArtikelnummer;
  String lieferant;
  double preis;
  String kategorie;
  // --- ANFANG DER ÄNDERUNG ---
  // Speichert jetzt nicht mehr nur eine Zahl, sondern ein Objekt mit Menge und Datum
  Map<String, LagerbestandEintrag> lagerbestaende;
  // --- ENDE DER ÄNDERUNG ---
  String scancode;

  Ersatzteil({
    this.id = '',
    required this.artikelnummer,
    required this.bezeichnung,
    required this.hersteller,
    this.haendlerArtikelnummer = '',
    required this.lieferant,
    required this.preis,
    required this.kategorie,
    Map<String, LagerbestandEintrag>? lagerbestaende,
    this.scancode = '',
  }) : lagerbestaende = lagerbestaende ?? {
    'Hauptlager': LagerbestandEintrag(menge: 0, letzteAenderung: Timestamp.now()),
    'Fahrzeug Patrick': LagerbestandEintrag(menge: 0, letzteAenderung: Timestamp.now()),
    'Fahrzeug Melanie': LagerbestandEintrag(menge: 0, letzteAenderung: Timestamp.now()),
  };

  int getGesamtbestand() {
    return lagerbestaende.values.fold(0, (sum, item) => sum + item.menge);
  }

  Map<String, dynamic> toJson() {
    return {
      'artikelnummer': artikelnummer,
      'bezeichnung': bezeichnung,
      'hersteller': hersteller,
      'haendlerArtikelnummer': haendlerArtikelnummer,
      'lieferant': lieferant,
      'preis': preis,
      'kategorie': kategorie,
      'lagerbestaende': lagerbestaende.map((key, value) => MapEntry(key, value.toJson())),
      'scancode': scancode,
    };
  }

  // --- ANFANG DER ÄNDERUNG ---
  // Diese Funktion kann jetzt das alte und das neue Datenformat lesen
  static Ersatzteil fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    Map<String, LagerbestandEintrag> tempLagerbestaende = {};

    if (data['lagerbestaende'] != null && data['lagerbestaende'] is Map) {
      (data['lagerbestaende'] as Map).forEach((key, value) {
        if (value is int) {
          // Altes Format (nur eine Zahl)
          tempLagerbestaende[key] = LagerbestandEintrag(menge: value, letzteAenderung: Timestamp.fromDate(DateTime(2020))); // Altes Datum für Demo-Daten
        } else if (value is Map) {
          // Neues Format (Map mit Menge und Datum)
          tempLagerbestaende[key] = LagerbestandEintrag.fromMap(Map<String, dynamic>.from(value));
        }
      });
    }

    return Ersatzteil(
      id: doc.id,
      artikelnummer: data['artikelnummer'] ?? '',
      bezeichnung: data['bezeichnung'] ?? '',
      hersteller: data['hersteller'] ?? '',
      haendlerArtikelnummer: data['haendlerArtikelnummer'] ?? '',
      lieferant: data['lieferant'] ?? '',
      preis: (data['preis'] as num?)?.toDouble() ?? 0.0,
      kategorie: data['kategorie'] ?? '',
      lagerbestaende: tempLagerbestaende,
      scancode: data['scancode'] ?? '',
    );
  }

  // Diese Funktion wird auch angepasst, um sicher zu sein
  static Ersatzteil fromMap(Map<String, dynamic> map) {
    Map<String, LagerbestandEintrag> tempLagerbestaende = {};
    if (map['lagerbestaende'] != null && map['lagerbestaende'] is Map) {
      (map['lagerbestaende'] as Map).forEach((key, value) {
        if (value is int) {
          tempLagerbestaende[key] = LagerbestandEintrag(menge: value, letzteAenderung: Timestamp.fromDate(DateTime(2020)));
        } else if (value is Map) {
          tempLagerbestaende[key] = LagerbestandEintrag.fromMap(Map<String, dynamic>.from(value));
        }
      });
    }

    return Ersatzteil(
      id: map['id'] ?? '',
      artikelnummer: map['artikelnummer'] ?? '',
      bezeichnung: map['bezeichnung'] ?? '',
      hersteller: map['hersteller'] ?? '',
      haendlerArtikelnummer: map['haendlerArtikelnummer'] ?? '',
      lieferant: map['lieferant'] ?? '',
      preis: (map['preis'] as num?)?.toDouble() ?? 0.0,
      kategorie: map['kategorie'] ?? '',
      lagerbestaende: tempLagerbestaende,
      scancode: map['scancode'] ?? '',
    );
  }
// --- ENDE DER ÄNDERUNG ---
}