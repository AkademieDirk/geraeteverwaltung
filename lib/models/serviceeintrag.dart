import 'package:cloud_firestore/cloud_firestore.dart';
import 'verbautes_teil.dart'; // <-- Wichtiger Import

class Serviceeintrag {
  final String id;
  final String geraeteId;
  final String verantwortlicherMitarbeiter;
  final Timestamp datum;
  final String ausgefuehrteArbeiten;
  // --- WIEDER HINZUGEFÜGT ---
  final List<VerbautesTeil> verbauteTeile;

  Serviceeintrag({
    required this.id,
    required this.geraeteId,
    required this.verantwortlicherMitarbeiter,
    required this.datum,
    required this.ausgefuehrteArbeiten,
    // --- WIEDER HINZUGEFÜGT ---
    this.verbauteTeile = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'geraeteId': geraeteId,
      'verantwortlicherMitarbeiter': verantwortlicherMitarbeiter,
      'datum': datum,
      'ausgefuehrteArbeiten': ausgefuehrteArbeiten,
      // --- WIEDER HINZUGEFÜGT ---
      'verbauteTeile': verbauteTeile.map((teil) => teil.toJson()).toList(),
    };
  }

  factory Serviceeintrag.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    // --- WIEDER HINZUGEFÜGT ---
    final teileData = data['verbauteTeile'] as List<dynamic>? ?? [];

    return Serviceeintrag(
      id: doc.id,
      geraeteId: data['geraeteId'] ?? '',
      verantwortlicherMitarbeiter: data['verantwortlicherMitarbeiter'] ?? '',
      datum: data['datum'] ?? Timestamp.now(),
      ausgefuehrteArbeiten: data['ausgefuehrteArbeiten'] ?? '',
      // --- WIEDER HINZUGEFÜGT ---
      verbauteTeile: teileData.map((data) => VerbautesTeil.fromMap(data)).toList(),
    );
  }
}