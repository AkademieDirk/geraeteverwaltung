import 'package:cloud_firestore/cloud_firestore.dart';
import 'verbautes_teil.dart';

class Serviceeintrag {
  final String id;
  final String geraeteId;
  final String verantwortlicherMitarbeiter;
  final Timestamp datum;
  final String ausgefuehrteArbeiten;
  final List<VerbautesTeil> verbauteTeile;
  // --- NEUES FELD ---
  final List<Map<String, String>> anhaenge; // Speichert eine Liste von Maps mit Name und URL

  Serviceeintrag({
    required this.id,
    required this.geraeteId,
    required this.verantwortlicherMitarbeiter,
    required this.datum,
    required this.ausgefuehrteArbeiten,
    this.verbauteTeile = const [],
    this.anhaenge = const [], // --- NEU ---
  });

  Map<String, dynamic> toJson() {
    return {
      'geraeteId': geraeteId,
      'verantwortlicherMitarbeiter': verantwortlicherMitarbeiter,
      'datum': datum,
      'ausgefuehrteArbeiten': ausgefuehrteArbeiten,
      'verbauteTeile': verbauteTeile.map((teil) => teil.toJson()).toList(),
      'anhaenge': anhaenge, // --- NEU ---
    };
  }

  factory Serviceeintrag.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final teileData = data['verbauteTeile'] as List<dynamic>? ?? [];

    return Serviceeintrag(
      id: doc.id,
      geraeteId: data['geraeteId'] ?? '',
      verantwortlicherMitarbeiter: data['verantwortlicherMitarbeiter'] ?? '',
      datum: data['datum'] ?? Timestamp.now(),
      ausgefuehrteArbeiten: data['ausgefuehrteArbeiten'] ?? '',
      verbauteTeile: teileData.map((data) => VerbautesTeil.fromMap(data)).toList(),
      // --- NEU: Konvertiert die Firestore-Daten sicher in unsere Map-Liste ---
      anhaenge: List<Map<String, String>>.from(
        (data['anhaenge'] as List<dynamic>? ?? []).map(
              (item) => Map<String, String>.from(item as Map),
        ),
      ),
    );
  }
}