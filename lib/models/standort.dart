import 'package:cloud_firestore/cloud_firestore.dart';

class Standort {
  String id;
  String kundeId; // Um den Standort einem Kunden zuzuordnen
  String name;    // z.B. "Zentrale" oder "Filiale B"
  String strasse;
  String plz;
  String ort;

  Standort({
    this.id = '',
    required this.kundeId,
    required this.name,
    this.strasse = '',
    this.plz = '',
    this.ort = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'kundeId': kundeId,
      'name': name,
      'strasse': strasse,
      'plz': plz,
      'ort': ort,
    };
  }

  static Standort fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return Standort(
      id: doc.id,
      kundeId: data['kundeId'] ?? '',
      name: data['name'] ?? '',
      strasse: data['strasse'] ?? '',
      plz: data['plz'] ?? '',
      ort: data['ort'] ?? '',
    );
  }
}
