// lib/models/verbautes_teil.dart

import 'ersatzteil.dart';

/// Repräsentiert ein Ersatzteil, das zu einem bestimmten Zeitpunkt
/// in einem Gerät verbaut wurde.
class VerbautesTeil {
  final Ersatzteil ersatzteil;
  final DateTime installationsDatum;

  VerbautesTeil({
    required this.ersatzteil,
    required this.installationsDatum,
  });
}
