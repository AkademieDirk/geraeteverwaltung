import 'package:cloud_firestore/cloud_firestore.dart';

class Kunde {
  final String id;
  final String kundennummer;
  final String name;
  final String ansprechpartner;
  final String telefon;
  final String email;
  // --- NEUE FELDER ---
  final String strasse;
  final String plz;
  final String ort;
  final String bemerkung;

  Kunde({
    this.id = '',
    required this.kundennummer,
    required this.name,
    this.ansprechpartner = '',
    this.telefon = '',
    this.email = '',
    // --- NEUE FELDER ---
    this.strasse = '',
    this.plz = '',
    this.ort = '',
    this.bemerkung = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'kundennummer': kundennummer,
      'name': name,
      'ansprechpartner': ansprechpartner,
      'telefon': telefon,
      'email': email,
      // --- NEUE FELDER ---
      'strasse': strasse,
      'plz': plz,
      'ort': ort,
      'bemerkung': bemerkung,
    };
  }

  factory Kunde.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Kunde(
      id: doc.id,
      kundennummer: data['kundennummer'] ?? '',
      name: data['name'] ?? '',
      ansprechpartner: data['ansprechpartner'] ?? '',
      telefon: data['telefon'] ?? '',
      email: data['email'] ?? '',
      // --- NEUE FELDER ---
      strasse: data['strasse'] ?? '',
      plz: data['plz'] ?? '',
      ort: data['ort'] ?? '',
      bemerkung: data['bemerkung'] ?? '',
    );
  }
}