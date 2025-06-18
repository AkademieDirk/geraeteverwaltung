class VerbauteKomponente {
  final String geraetSeriennummer;
  final String artikelnummer;
  final String seriennummerErsatzteil;
  final DateTime einbaudatum;

  VerbauteKomponente({
    required this.geraetSeriennummer,
    required this.artikelnummer,
    this.seriennummerErsatzteil = '',
    required this.einbaudatum,
  });

  Map<String, dynamic> toMap() => {
    'geraetSeriennummer': geraetSeriennummer,
    'artikelnummer': artikelnummer,
    'seriennummerErsatzteil': seriennummerErsatzteil,
    'einbaudatum': einbaudatum.toIso8601String(),
  };

  factory VerbauteKomponente.fromMap(Map<String, dynamic> map) => VerbauteKomponente(
    geraetSeriennummer: map['geraetSeriennummer'],
    artikelnummer: map['artikelnummer'],
    seriennummerErsatzteil: map['seriennummerErsatzteil'] ?? '',
    einbaudatum: DateTime.parse(map['einbaudatum']),
  );
}
