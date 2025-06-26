// lib/models/ersatzteil.dart

class Ersatzteil {
  String artikelnummer;
  String bezeichnung;
  String lieferant;
  double preis;
  String kategorie;

  Ersatzteil({
    required this.artikelnummer,
    required this.bezeichnung,
    required this.lieferant,
    required this.preis,
    required this.kategorie,
  });
}
