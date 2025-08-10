import 'package:cloud_firestore/cloud_firestore.dart';

class Geraet {
  String id;
  String nummer;
  String modell;
  String seriennummer;
  String mitarbeiter;
  Timestamp? aufnahmeDatum;
  String lieferant;
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
  String status;
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
    this.aufnahmeDatum,
    this.lieferant = '',
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
    this.status = 'Im Lager',
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
      'aufnahmeDatum': aufnahmeDatum,
      'lieferant': lieferant,
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
      'status': status,
      'kundeId': kundeId,
      'kundeName': kundeName,
      'standortId': standortId,
      'standortName': standortName,
    };
  }

  // --- ANFANG DER NEUEN METHODE ---
  Geraet copyWith({
    String? id,
    String? nummer,
    String? modell,
    String? seriennummer,
    String? mitarbeiter,
    Timestamp? aufnahmeDatum,
    String? lieferant,
    String? iOption,
    String? pdfTyp,
    String? durchsuchbar,
    String? ocr,
    String? originaleinzugTyp,
    String? originaleinzugSN,
    String? unterschrankTyp,
    String? unterschrankSN,
    String? finisher,
    String? finisherSN,
    String? fax,
    String? faxSN,
    String? bemerkung,
    String? zaehlerGesamt,
    String? zaehlerSW,
    String? zaehlerColor,
    String? rtb,
    String? tonerK,
    String? tonerC,
    String? tonerM,
    String? tonerY,
    String? laufzeitBildeinheitK,
    String? laufzeitBildeinheitC,
    String? laufzeitBildeinheitM,
    String? laufzeitBildeinheitY,
    String? laufzeitEntwicklerK,
    String? laufzeitEntwicklerC,
    String? laufzeitEntwicklerM,
    String? laufzeitEntwicklerY,
    String? laufzeitFixiereinheit,
    String? laufzeitTransferbelt,
    String? fach1,
    String? fach2,
    String? fach3,
    String? fach4,
    String? bypass,
    String? dokumenteneinzug,
    String? duplex,
    String? status,
    String? kundeId,
    String? kundeName,
    String? standortId,
    String? standortName,
  }) {
    return Geraet(
      id: id ?? this.id,
      nummer: nummer ?? this.nummer,
      modell: modell ?? this.modell,
      seriennummer: seriennummer ?? this.seriennummer,
      mitarbeiter: mitarbeiter ?? this.mitarbeiter,
      aufnahmeDatum: aufnahmeDatum ?? this.aufnahmeDatum,
      lieferant: lieferant ?? this.lieferant,
      iOption: iOption ?? this.iOption,
      pdfTyp: pdfTyp ?? this.pdfTyp,
      durchsuchbar: durchsuchbar ?? this.durchsuchbar,
      ocr: ocr ?? this.ocr,
      originaleinzugTyp: originaleinzugTyp ?? this.originaleinzugTyp,
      originaleinzugSN: originaleinzugSN ?? this.originaleinzugSN,
      unterschrankTyp: unterschrankTyp ?? this.unterschrankTyp,
      unterschrankSN: unterschrankSN ?? this.unterschrankSN,
      finisher: finisher ?? this.finisher,
      finisherSN: finisherSN ?? this.finisherSN,
      fax: fax ?? this.fax,
      faxSN: faxSN ?? this.faxSN,
      bemerkung: bemerkung ?? this.bemerkung,
      zaehlerGesamt: zaehlerGesamt ?? this.zaehlerGesamt,
      zaehlerSW: zaehlerSW ?? this.zaehlerSW,
      zaehlerColor: zaehlerColor ?? this.zaehlerColor,
      rtb: rtb ?? this.rtb,
      tonerK: tonerK ?? this.tonerK,
      tonerC: tonerC ?? this.tonerC,
      tonerM: tonerM ?? this.tonerM,
      tonerY: tonerY ?? this.tonerY,
      laufzeitBildeinheitK: laufzeitBildeinheitK ?? this.laufzeitBildeinheitK,
      laufzeitBildeinheitC: laufzeitBildeinheitC ?? this.laufzeitBildeinheitC,
      laufzeitBildeinheitM: laufzeitBildeinheitM ?? this.laufzeitBildeinheitM,
      laufzeitBildeinheitY: laufzeitBildeinheitY ?? this.laufzeitBildeinheitY,
      laufzeitEntwicklerK: laufzeitEntwicklerK ?? this.laufzeitEntwicklerK,
      laufzeitEntwicklerC: laufzeitEntwicklerC ?? this.laufzeitEntwicklerC,
      laufzeitEntwicklerM: laufzeitEntwicklerM ?? this.laufzeitEntwicklerM,
      laufzeitEntwicklerY: laufzeitEntwicklerY ?? this.laufzeitEntwicklerY,
      laufzeitFixiereinheit: laufzeitFixiereinheit ?? this.laufzeitFixiereinheit,
      laufzeitTransferbelt: laufzeitTransferbelt ?? this.laufzeitTransferbelt,
      fach1: fach1 ?? this.fach1,
      fach2: fach2 ?? this.fach2,
      fach3: fach3 ?? this.fach3,
      fach4: fach4 ?? this.fach4,
      bypass: bypass ?? this.bypass,
      dokumenteneinzug: dokumenteneinzug ?? this.dokumenteneinzug,
      duplex: duplex ?? this.duplex,
      status: status ?? this.status,
      kundeId: kundeId ?? this.kundeId,
      kundeName: kundeName ?? this.kundeName,
      standortId: standortId ?? this.standortId,
      standortName: standortName ?? this.standortName,
    );
  }
  // --- ENDE DER NEUEN METHODE ---

  static Geraet fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return Geraet(
      id: doc.id,
      nummer: data['nummer'] ?? '',
      modell: data['modell'] ?? '',
      seriennummer: data['seriennummer'] ?? '',
      mitarbeiter: data['mitarbeiter'] ?? '',
      aufnahmeDatum: data['aufnahmeDatum'] as Timestamp?,
      lieferant: data['lieferant'] ?? '',
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
      status: data['status'] ?? 'Im Lager',
      kundeId: data['kundeId'],
      kundeName: data['kundeName'],
      standortId: data['standortId'],
      standortName: data['standortName'],
    );
  }
}