import 'package:cloud_firestore/cloud_firestore.dart';

class Kunde {
  String id;
  String kundennummer;
  String name;
  String ansprechpartner;
  String telefon;
  String email;

  Kunde({
    this.id = '',
    required this.kundennummer,
    required this.name,
    this.ansprechpartner = '',
    this.telefon = '',
    this.email = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'kundennummer': kundennummer,
      'name': name,
      'ansprechpartner': ansprechpartner,
      'telefon': telefon,
      'email': email,
    };
  }

  static Kunde fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return Kunde(
      id: doc.id,
      kundennummer: data['kundennummer'] ?? '',
      name: data['name'] ?? '',
      ansprechpartner: data['ansprechpartner'] ?? '',
      telefon: data['telefon'] ?? '',
      email: data['email'] ?? '',
    );
  }
}
