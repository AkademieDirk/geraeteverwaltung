import 'package:cloud_firestore/cloud_firestore.dart';

class Kunde {
  final String id;
  final String kundennummer;
  final String name;
  final String ansprechpartner;
  final String telefon;
  final String email;
  final String strasse;
  final String plz;
  final String ort;
  final String bemerkung;
  final List<Map<String, String>> anhaenge;

  Kunde({
    this.id = '',
    required this.kundennummer,
    required this.name,
    this.ansprechpartner = '',
    this.telefon = '',
    this.email = '',
    this.strasse = '',
    this.plz = '',
    this.ort = '',
    this.bemerkung = '',
    this.anhaenge = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'kundennummer': kundennummer,
      'name': name,
      'ansprechpartner': ansprechpartner,
      'telefon': telefon,
      'email': email,
      'strasse': strasse,
      'plz': plz,
      'ort': ort,
      'bemerkung': bemerkung,
      'anhaenge': anhaenge,
    };
  }

  // --- ANFANG DER KORREKTUR ---
  // Diese Methode hat in der letzten Antwort gefehlt.
  Kunde copyWith({
    String? id,
    String? kundennummer,
    String? name,
    String? ansprechpartner,
    String? telefon,
    String? email,
    String? strasse,
    String? plz,
    String? ort,
    String? bemerkung,
    List<Map<String, String>>? anhaenge,
  }) {
    return Kunde(
      id: id ?? this.id,
      kundennummer: kundennummer ?? this.kundennummer,
      name: name ?? this.name,
      ansprechpartner: ansprechpartner ?? this.ansprechpartner,
      telefon: telefon ?? this.telefon,
      email: email ?? this.email,
      strasse: strasse ?? this.strasse,
      plz: plz ?? this.plz,
      ort: ort ?? this.ort,
      bemerkung: bemerkung ?? this.bemerkung,
      anhaenge: anhaenge ?? this.anhaenge,
    );
  }
  // --- ENDE DER KORREKTUR ---

  factory Kunde.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Kunde(
      id: doc.id,
      kundennummer: data['kundennummer'] ?? '',
      name: data['name'] ?? '',
      ansprechpartner: data['ansprechpartner'] ?? '',
      telefon: data['telefon'] ?? '',
      email: data['email'] ?? '',
      strasse: data['strasse'] ?? '',
      plz: data['plz'] ?? '',
      ort: data['ort'] ?? '',
      bemerkung: data['bemerkung'] ?? '',
      anhaenge: List<Map<String, String>>.from(
        (data['anhaenge'] as List<dynamic>? ?? []).map(
              (item) => Map<String, String>.from(item as Map),
        ),
      ),
    );
  }
}