import 'package:cloud_firestore/cloud_firestore.dart';

class Geraet {
  String id;
  String nummer;
  String modell;
  String seriennummer;
  String mitarbeiter;
  String iOption;
  String pdfTyp;
  String durchsuchbar;
  String ocr;
  String originaleinzugTyp;
  String originaleinzugSN;
  String unterschrankTyp;
  String unterschrankSN;
  String finisher;
  String finisherSN;
  String fax;
  String faxSN;
  String bemerkung;
  String zaehlerGesamt;
  String zaehlerSW;
  String zaehlerColor;
  String rtb;
  String tonerK;
  String tonerC;
  String tonerM;
  String tonerY;
  String laufzeitBildeinheitK;
  String laufzeitBildeinheitC;
  String laufzeitBildeinheitM;
  String laufzeitBildeinheitY;
  String laufzeitEntwicklerK;
  String laufzeitEntwicklerC;
  String laufzeitEntwicklerM;
  String laufzeitEntwicklerY;
  String laufzeitFixiereinheit;
  String laufzeitTransferbelt;
  String fach1;
  String fach2;
  String fach3;
  String fach4;
  String bypass;
  String dokumenteneinzug;
  String duplex;

  // --- NEU: Felder für Kunden-Zuordnung und Status ---
  String status; // z.B. 'Im Lager', 'Verkauft', 'Im Service'
  String? kundeId;
  String? kundeName;
  String? standortId;
  String? standortName;

  Geraet({
    this.id = '',
    required this.nummer,
    required this.modell,
    required this.seriennummer,
    this.mitarbeiter = '',
    this.iOption = '',
    this.pdfTyp = '',
    this.durchsuchbar = '',
    this.ocr = '',
    this.originaleinzugTyp = '',
    this.originaleinzugSN = '',
    this.unterschrankTyp = '',
    this.unterschrankSN = '',
    this.finisher = '',
    this.finisherSN = '',
    this.fax = '',
    this.faxSN = '',
    this.bemerkung = '',
    this.zaehlerGesamt = '',
    this.zaehlerSW = '',
    this.zaehlerColor = '',
    this.rtb = '',
    this.tonerK = '',
    this.tonerC = '',
    this.tonerM = '',
    this.tonerY = '',
    this.laufzeitBildeinheitK = '',
    this.laufzeitBildeinheitC = '',
    this.laufzeitBildeinheitM = '',
    this.laufzeitBildeinheitY = '',
    this.laufzeitEntwicklerK = '',
    this.laufzeitEntwicklerC = '',
    this.laufzeitEntwicklerM = '',
    this.laufzeitEntwicklerY = '',
    this.laufzeitFixiereinheit = '',
    this.laufzeitTransferbelt = '',
    this.fach1 = '',
    this.fach2 = '',
    this.fach3 = '',
    this.fach4 = '',
    this.bypass = '',
    this.dokumenteneinzug = '',
    this.duplex = '',
    this.status = 'Im Lager', // Standardstatus für neue Geräte
    this.kundeId,
    this.kundeName,
    this.standortId,
    this.standortName,
  });

  Map<String, dynamic> toJson() {
    return {
      'nummer': nummer,
      'modell': modell,
      'seriennummer': seriennummer,
      'mitarbeiter': mitarbeiter,
      'iOption': iOption,
      'pdfTyp': pdfTyp,
      'durchsuchbar': durchsuchbar,
      'ocr': ocr,
      'originaleinzugTyp': originaleinzugTyp,
      'originaleinzugSN': originaleinzugSN,
      'unterschrankTyp': unterschrankTyp,
      'unterschrankSN': unterschrankSN,
      'finisher': finisher,
      'finisherSN': finisherSN,
      'fax': fax,
      'faxSN': faxSN,
      'bemerkung': bemerkung,
      'zaehlerGesamt': zaehlerGesamt,
      'zaehlerSW': zaehlerSW,
      'zaehlerColor': zaehlerColor,
      'rtb': rtb,
      'tonerK': tonerK,
      'tonerC': tonerC,
      'tonerM': tonerM,
      'tonerY': tonerY,
      'laufzeitBildeinheitK': laufzeitBildeinheitK,
      'laufzeitBildeinheitC': laufzeitBildeinheitC,
      'laufzeitBildeinheitM': laufzeitBildeinheitM,
      'laufzeitBildeinheitY': laufzeitBildeinheitY,
      'laufzeitEntwicklerK': laufzeitEntwicklerK,
      'laufzeitEntwicklerC': laufzeitEntwicklerC,
      'laufzeitEntwicklerM': laufzeitEntwicklerM,
      'laufzeitEntwicklerY': laufzeitEntwicklerY,
      'laufzeitFixiereinheit': laufzeitFixiereinheit,
      'laufzeitTransferbelt': laufzeitTransferbelt,
      'fach1': fach1,
      'fach2': fach2,
      'fach3': fach3,
      'fach4': fach4,
      'bypass': bypass,
      'dokumenteneinzug': dokumenteneinzug,
      'duplex': duplex,
      // --- NEU: Felder werden gespeichert ---
      'status': status,
      'kundeId': kundeId,
      'kundeName': kundeName,
      'standortId': standortId,
      'standortName': standortName,
    };
  }

  static Geraet fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return Geraet(
      id: doc.id,
      nummer: data['nummer'] ?? '',
      modell: data['modell'] ?? '',
      seriennummer: data['seriennummer'] ?? '',
      mitarbeiter: data['mitarbeiter'] ?? '',
      iOption: data['iOption'] ?? '',
      pdfTyp: data['pdfTyp'] ?? '',
      durchsuchbar: data['durchsuchbar'] ?? '',
      ocr: data['ocr'] ?? '',
      originaleinzugTyp: data['originaleinzugTyp'] ?? '',
      originaleinzugSN: data['originaleinzugSN'] ?? '',
      unterschrankTyp: data['unterschrankTyp'] ?? '',
      unterschrankSN: data['unterschrankSN'] ?? '',
      finisher: data['finisher'] ?? '',
      finisherSN: data['finisherSN'] ?? '',
      fax: data['fax'] ?? '',
      faxSN: data['faxSN'] ?? '',
      bemerkung: data['bemerkung'] ?? '',
      zaehlerGesamt: data['zaehlerGesamt'] ?? '',
      zaehlerSW: data['zaehlerSW'] ?? '',
      zaehlerColor: data['zaehlerColor'] ?? '',
      rtb: data['rtb'] ?? '',
      tonerK: data['tonerK'] ?? '',
      tonerC: data['tonerC'] ?? '',
      tonerM: data['tonerM'] ?? '',
      tonerY: data['tonerY'] ?? '',
      laufzeitBildeinheitK: data['laufzeitBildeinheitK'] ?? '',
      laufzeitBildeinheitC: data['laufzeitBildeinheitC'] ?? '',
      laufzeitBildeinheitM: data['laufzeitBildeinheitM'] ?? '',
      laufzeitBildeinheitY: data['laufzeitBildeinheitY'] ?? '',
      laufzeitEntwicklerK: data['laufzeitEntwicklerK'] ?? '',
      laufzeitEntwicklerC: data['laufzeitEntwicklerC'] ?? '',
      laufzeitEntwicklerM: data['laufzeitEntwicklerM'] ?? '',
      laufzeitEntwicklerY: data['laufzeitEntwicklerY'] ?? '',
      laufzeitFixiereinheit: data['laufzeitFixiereinheit'] ?? '',
      laufzeitTransferbelt: data['laufzeitTransferbelt'] ?? '',
      fach1: data['fach1'] ?? '',
      fach2: data['fach2'] ?? '',
      fach3: data['fach3'] ?? '',
      fach4: data['fach4'] ?? '',
      bypass: data['bypass'] ?? '',
      dokumenteneinzug: data['dokumenteneinzug'] ?? '',
      duplex: data['duplex'] ?? '',
      // --- NEU: Felder werden gelesen ---
      status: data['status'] ?? 'Im Lager',
      kundeId: data['kundeId'],
      kundeName: data['kundeName'],
      standortId: data['standortId'],
      standortName: data['standortName'],
    );
  }
}
