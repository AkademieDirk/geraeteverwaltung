class Geraet {
  String nummer;
  String modell;
  String seriennummer;
  String mitarbeiter;
  String iOption;
  String pdfTyp;
  String durchsuchbar;
  String originaleinzugTyp;
  String originaleinzugSN;
  String unterschrankTyp;
  String unterschrankSN;
  String finisher;
  String finisherSN;
  String fax;
  int zaehlerGesamt;
  int zaehlerSW;
  int zaehlerColor;
  int rtb;
  int tonerK;
  int tonerC;
  int tonerM;
  int tonerY;

  int laufzeitBildeinheitK;
  int laufzeitBildeinheitC;
  int laufzeitBildeinheitM;
  int laufzeitBildeinheitY;
  int laufzeitEntwicklerK;
  int laufzeitEntwicklerC;
  int laufzeitEntwicklerM;
  int laufzeitEntwicklerY;
  int laufzeitFixiereinheit;
  int laufzeitTransferbelt;

  String? fach1;
  String? fach2;
  String? fach3;
  String? fach4;
  String? bypass;
  String? dokumenteneinzug;
  String? duplex;
  String? bemerkung;

  Geraet({
    required this.nummer,
    required this.modell,
    required this.seriennummer,
    required this.mitarbeiter,
    required this.iOption,
    required this.pdfTyp,
    required this.durchsuchbar,
    required this.originaleinzugTyp,
    required this.originaleinzugSN,
    required this.unterschrankTyp,
    required this.unterschrankSN,
    required this.finisher,
    required this.finisherSN,
    required this.fax,
    required this.zaehlerGesamt,
    required this.zaehlerSW,
    required this.zaehlerColor,
    required this.rtb,
    required this.tonerK,
    required this.tonerC,
    required this.tonerM,
    required this.tonerY,
    required this.laufzeitBildeinheitK,
    required this.laufzeitBildeinheitC,
    required this.laufzeitBildeinheitM,
    required this.laufzeitBildeinheitY,
    required this.laufzeitEntwicklerK,
    required this.laufzeitEntwicklerC,
    required this.laufzeitEntwicklerM,
    required this.laufzeitEntwicklerY,
    required this.laufzeitFixiereinheit,
    required this.laufzeitTransferbelt,
    this.fach1,
    this.fach2,
    this.fach3,
    this.fach4,
    this.bypass,
    this.dokumenteneinzug,
    this.duplex,
    this.bemerkung,
  });
}
