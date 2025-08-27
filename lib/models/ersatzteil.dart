import 'package:cloud_firestore/cloud_firestore.dart';

class Ersatzteil {
  String id;
  String artikelnummer;
  String bezeichnung;
  String hersteller;
  String haendlerArtikelnummer;
  String lieferant;
  double preis;
  String kategorie;
  Map<String, int> lagerbestaende;
  // --- NEUES FELD ---
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
    Map<String, int>? lagerbestaende,
    this.scancode = '', // --- NEU, mit leerem Standardwert ---
  }) : lagerbestaende = lagerbestaende ?? {'Hauptlager': 0, 'Fahrzeug Patrick': 0, 'Fahrzeug Melanie': 0};

  int getGesamtbestand() {
    return lagerbestaende.values.fold(0, (sum, item) => sum + item);
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
      'lagerbestaende': lagerbestaende,
      'scancode': scancode, // --- NEU ---
    };
  }

  static Ersatzteil fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return Ersatzteil(
      id: doc.id,
      artikelnummer: data['artikelnummer'] ?? '',
      bezeichnung: data['bezeichnung'] ?? '',
      hersteller: data['hersteller'] ?? '',
      haendlerArtikelnummer: data['haendlerArtikelnummer'] ?? '',
      lieferant: data['lieferant'] ?? '',
      preis: (data['preis'] as num?)?.toDouble() ?? 0.0,
      kategorie: data['kategorie'] ?? '',
      lagerbestaende: Map<String, int>.from(data['lagerbestaende'] ?? {}),
      scancode: data['scancode'] ?? '', // --- NEU ---
    );
  }

  static Ersatzteil fromMap(Map<String, dynamic> map) {
    return Ersatzteil(
      id: map['id'] ?? '',
      artikelnummer: map['artikelnummer'] ?? '',
      bezeichnung: map['bezeichnung'] ?? '',
      hersteller: map['hersteller'] ?? '',
      haendlerArtikelnummer: map['haendlerArtikelnummer'] ?? '',
      lieferant: map['lieferant'] ?? '',
      preis: (map['preis'] as num?)?.toDouble() ?? 0.0,
      kategorie: map['kategorie'] ?? '',
      lagerbestaende: Map<String, int>.from(map['lagerbestaende'] ?? {}),
      scancode: map['scancode'] ?? '', // --- NEU ---
    );
  }
}