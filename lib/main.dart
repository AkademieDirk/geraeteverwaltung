import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';
import 'screens/auswahl_screen.dart';
import 'screens/login_screen.dart';
import 'models/geraet.dart';
import 'models/ersatzteil.dart';
import 'models/verbautes_teil.dart';
import 'models/kunde.dart';
import 'models/standort.dart';
import 'models/serviceeintrag.dart';

// ========================= FirestoreService (unverändert) =========================
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // --- Geräte-Operationen ---
  Stream<List<Geraet>> getGeraete() => _db
      .collection('geraete')
      .snapshots()
      .map((s) => s.docs.map((d) => Geraet.fromFirestore(d)).toList());

  Future<void> addGeraet(Geraet geraet) =>
      _db.collection('geraete').add(geraet.toJson());

  Future<void> updateGeraet(Geraet geraet) =>
      _db.collection('geraete').doc(geraet.id).update(geraet.toJson());

  Future<void> deleteGeraet(String geraetId) =>
      _db.collection('geraete').doc(geraetId).delete();

  Future<void> importGeraete(List<Geraet> geraete) {
    final batch = _db.batch();
    for (final g in geraete) {
      final docRef = _db.collection('geraete').doc();
      batch.set(docRef, g.toJson());
    }
    return batch.commit();
  }

  Future<void> addGeraetForKunde(Geraet geraet, Kunde kunde, Standort standort) {
    final geraetMitKunde = geraet.copyWith(
      status: 'Verkauft',
      kundeId: kunde.id,
      kundeName: kunde.name,
      standortId: standort.id,
      standortName: standort.name,
      nummer: '',
    );
    return _db.collection('geraete').add(geraetMitKunde.toJson());
  }

  Future<void> addGeraetForKundeOhneStandort(Geraet geraet, Kunde kunde) {
    final geraetMitKunde = geraet.copyWith(
      status: 'Verkauft',
      kundeId: kunde.id,
      kundeName: kunde.name,
      standortId: null,
      standortName: 'N/A',
      nummer: '',
    );
    return _db.collection('geraete').add(geraetMitKunde.toJson());
  }

  // --- Ersatzteil-Operationen ---
  Stream<List<Ersatzteil>> getErsatzteile() => _db
      .collection('ersatzteile')
      .snapshots()
      .map((s) => s.docs.map((d) => Ersatzteil.fromFirestore(d)).toList());

  Future<void> addErsatzteil(Ersatzteil e) =>
      _db.collection('ersatzteile').add(e.toJson());

  Future<void> updateErsatzteil(Ersatzteil e) =>
      _db.collection('ersatzteile').doc(e.id).update(e.toJson());

  Future<void> deleteErsatzteil(String id) =>
      _db.collection('ersatzteile').doc(id).delete();

  // --- Historien-Operationen (für verbaute Teile) ---
  Stream<Map<String, List<VerbautesTeil>>> getVerbauteTeile() {
    return _db.collection('historie').snapshots().map((snapshot) {
      final Map<String, List<VerbautesTeil>> historie = {};
      for (var doc in snapshot.docs) {
        final seriennummer = doc.id;
        final teileData = doc.data()['teile'] as List<dynamic>? ?? [];
        final teileListe =
        teileData.map((data) => VerbautesTeil.fromMap(data)).toList();
        historie[seriennummer] = teileListe;
      }
      return historie;
    });
  }

  // --- KORREKTUR beibehalten ---
  Future<void> addVerbautesTeil(
      String seriennummer, Ersatzteil teil, String lager) async {
    final ersatzteilRef = _db.collection('ersatzteile').doc(teil.id);
    final historieRef = _db.collection('historie').doc(seriennummer);

    final verbautesTeil = VerbautesTeil(
      id: _uuid.v4(),
      ersatzteil: teil,
      installationsDatum: DateTime.now(),
      tatsaechlicherPreis: teil.preis,
      herkunftslager: lager,
    );

    return _db.runTransaction((transaction) async {
      final ersatzteilSnapshot = await transaction.get(ersatzteilRef);
      if (!ersatzteilSnapshot.exists) {
        throw Exception("Ersatzteil nicht gefunden!");
      }
      final ersatzteilDaten = Ersatzteil.fromFirestore(ersatzteilSnapshot);
      final aktuellerBestand = ersatzteilDaten.lagerbestaende[lager] ?? 0;
      if (aktuellerBestand <= 0) {
        throw Exception("Kein Bestand in Lager '$lager'.");
      }

      transaction.update(
          ersatzteilRef, {'lagerbestaende.$lager': FieldValue.increment(-1)});
      transaction.set(
        historieRef,
        {'teile': FieldValue.arrayUnion([verbautesTeil.toJson()])},
        SetOptions(merge: true),
      );
    });
  }

  Future<void> updateVerbautesTeil(
      String seriennummer, VerbautesTeil geandertesTeil) async {
    final docRef = _db.collection('historie').doc(seriennummer);
    final doc = await docRef.get();
    if (doc.exists) {
      final teileData = doc.data()!['teile'] as List<dynamic>;
      final teileListe =
      teileData.map((data) => VerbautesTeil.fromMap(data)).toList();
      final index = teileListe.indexWhere((t) => t.id == geandertesTeil.id);
      if (index != -1) {
        teileListe[index] = geandertesTeil;
        await docRef.update({'teile': teileListe.map((t) => t.toJson()).toList()});
      }
    }
  }

  Future<void> deleteVerbautesTeil(
      String seriennummer, VerbautesTeil teil) async {
    final historieRef = _db.collection('historie').doc(seriennummer);
    if (teil.ersatzteil.id.isNotEmpty) {
      final ersatzteilRef = _db.collection('ersatzteile').doc(teil.ersatzteil.id);
      return _db.runTransaction((transaction) async {
        transaction.update(ersatzteilRef,
            {'lagerbestaende.${teil.herkunftslager}': FieldValue.increment(1)});
        final doc = await transaction.get(historieRef);
        if (doc.exists) {
          final teileData = doc.data()!['teile'] as List<dynamic>? ?? [];
          final teileMapList =
          teileData.map((e) => e as Map<String, dynamic>).toList();
          teileMapList.removeWhere((m) => m['id'] == teil.id);
          transaction.update(historieRef, {'teile': teileMapList});
        }
      });
    } else {
      final doc = await historieRef.get();
      if (doc.exists) {
        final teileData = doc.data()!['teile'] as List<dynamic>? ?? [];
        final teileMapList =
        teileData.map((e) => e as Map<String, dynamic>).toList();
        teileMapList.removeWhere((m) => m['id'] == teil.id);
        await historieRef.update({'teile': teileMapList});
      }
    }
  }

  Future<void> transferErsatzteil(
      Ersatzteil teil, String vonLager, String nachLager, int anzahl) async {
    final ersatzteilRef = _db.collection('ersatzteile').doc(teil.id);
    return _db.runTransaction((transaction) async {
      final snap = await transaction.get(ersatzteilRef);
      if (!snap.exists) throw Exception("Ersatzteil nicht mehr gefunden.");
      final daten = Ersatzteil.fromFirestore(snap);
      final aktuellerVonBestand = daten.lagerbestaende[vonLager] ?? 0;
      if (aktuellerVonBestand < anzahl) {
        throw Exception("Nicht genügend Bestand im Lager '$vonLager'.");
      }
      transaction.update(ersatzteilRef, {
        'lagerbestaende.$vonLager': FieldValue.increment(-anzahl),
        'lagerbestaende.$nachLager': FieldValue.increment(anzahl),
      });
    });
  }

  Future<void> bookInErsatzteil(Ersatzteil teil, String lager, int anzahl) {
    final ersatzteilRef = _db.collection('ersatzteile').doc(teil.id);
    return ersatzteilRef
        .update({'lagerbestaende.$lager': FieldValue.increment(anzahl)});
  }

  // --- Service-Operationen ---
  Stream<List<Serviceeintrag>> getServiceeintraege() => _db
      .collection('servicehistorie')
      .snapshots()
      .map((s) => s.docs.map((d) => Serviceeintrag.fromFirestore(d)).toList());

  Future<void> addServiceeintrag(Serviceeintrag e) =>
      _db.collection('servicehistorie').add(e.toJson());

  Future<void> updateServiceeintrag(Serviceeintrag e) =>
      _db.collection('servicehistorie').doc(e.id).update(e.toJson());

  Future<void> deleteServiceeintrag(String id) =>
      _db.collection('servicehistorie').doc(id).delete();

  // --- Kunden-Operationen ---
  Stream<List<Kunde>> getKunden() => _db
      .collection('kunden')
      .snapshots()
      .map((s) => s.docs.map((d) => Kunde.fromFirestore(d)).toList());

  Future<void> updateKunde(Kunde k) =>
      _db.collection('kunden').doc(k.id).update(k.toJson());

  Future<void> deleteKunde(String id) =>
      _db.collection('kunden').doc(id).delete();

  Future<void> addKundeAndStandort(Kunde kunde, Standort standort) {
    final batch = _db.batch();
    final kundenRef = _db.collection('kunden').doc();
    batch.set(kundenRef, kunde.toJson());
    standort.kundeId = kundenRef.id;
    final standortRef = _db.collection('standorte').doc();
    batch.set(standortRef, standort.toJson());
    return batch.commit();
  }

  Future<void> importKunden(List<Kunde> kunden) {
    final batch = _db.batch();
    for (final k in kunden) {
      final docRef = _db.collection('kunden').doc();
      batch.set(docRef, k.toJson());
    }
    return batch.commit();
  }

  // --- Standorte ---
  Stream<List<Standort>> getStandorte() => _db
      .collection('standorte')
      .snapshots()
      .map((s) => s.docs.map((d) => Standort.fromFirestore(d)).toList());

  Future<void> addStandort(Standort s) =>
      _db.collection('standorte').add(s.toJson());

  Future<void> updateStandort(Standort s) =>
      _db.collection('standorte').doc(s.id).update(s.toJson());

  Future<void> deleteStandort(String id) =>
      _db.collection('standorte').doc(id).delete();

  // --- Geräte-Zuordnung ---
  Future<void> assignGeraetToKunde(
      Geraet g, Kunde kunde, Standort standort) {
    final ref = _db.collection('geraete').doc(g.id);
    return ref.update({
      'status': 'Verkauft',
      'kundeId': kunde.id,
      'kundeName': kunde.name,
      'standortId': standort.id,
      'standortName': standort.name,
      'nummer': '',
    });
  }
}

// ========================= main() & App =========================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // offizieller Weg laut FlutterFire
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // GoRouter lokal in main.dart, damit keine Kreis-Imports entstehen
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      // AuthGate bleibt der Einstieg wie vorher
      GoRoute(
        path: '/',
        name: 'root',
        builder: (context, state) => const AuthGate(),
      ),
      // Optional: direkte Routen für Login und Home (falls du später URLs nutzen willst)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MyHomePage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gerätemanager',
      routerConfig: _router, // Nutzung des Router-APIs
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}

// ========================= AuthGate & MyHomePage (unverändert) =========================
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          // Du kannst alternativ auch: context.go('/home'); zurückgeben
          return const MyHomePage();
        }
        return const LoginScreen();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Serviceeintrag>>(
      stream: _firestoreService.getServiceeintraege(),
      builder: (context, serviceSnapshot) {
        if (serviceSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (serviceSnapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Fehler: ${serviceSnapshot.error}')),
          );
        }
        final serviceeintraege = serviceSnapshot.data ?? [];

        return StreamBuilder<List<Geraet>>(
          stream: _firestoreService.getGeraete(),
          builder: (context, geraeteSnapshot) {
            if (geraeteSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (geraeteSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Fehler beim Laden der Geräte: ${geraeteSnapshot.error}'),
                ),
              );
            }
            final geraete = geraeteSnapshot.data ?? [];

            return StreamBuilder<List<Ersatzteil>>(
              stream: _firestoreService.getErsatzteile(),
              builder: (context, ersatzteileSnapshot) {
                if (ersatzteileSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (ersatzteileSnapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text('Fehler beim Laden der Ersatzteile: ${ersatzteileSnapshot.error}'),
                    ),
                  );
                }
                final ersatzteile = ersatzteileSnapshot.data ?? [];

                return StreamBuilder<Map<String, List<VerbautesTeil>>>(
                  stream: _firestoreService.getVerbauteTeile(),
                  builder: (context, historieSnapshot) {
                    if (historieSnapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (historieSnapshot.hasError) {
                      return Scaffold(
                        body: Center(
                          child: Text('Fehler beim Laden der Historie: ${historieSnapshot.error}'),
                        ),
                      );
                    }
                    final verbauteTeile = historieSnapshot.data ?? {};

                    return StreamBuilder<List<Kunde>>(
                      stream: _firestoreService.getKunden(),
                      builder: (context, kundenSnapshot) {
                        if (kundenSnapshot.connectionState == ConnectionState.waiting) {
                          return const Scaffold(
                            body: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (kundenSnapshot.hasError) {
                          return Scaffold(
                            body: Center(
                              child: Text('Fehler beim Laden der Kunden: ${kundenSnapshot.error}'),
                            ),
                          );
                        }
                        final kunden = kundenSnapshot.data ?? [];

                        return StreamBuilder<List<Standort>>(
                          stream: _firestoreService.getStandorte(),
                          builder: (context, standorteSnapshot) {
                            if (standorteSnapshot.connectionState == ConnectionState.waiting) {
                              return const Scaffold(
                                body: Center(child: CircularProgressIndicator()),
                              );
                            }
                            if (standorteSnapshot.hasError) {
                              return Scaffold(
                                body: Center(
                                  child: Text('Fehler beim Laden der Standorte: ${standorteSnapshot.error}'),
                                ),
                              );
                            }
                            final standorte = standorteSnapshot.data ?? [];

                            return AuswahlScreen(
                              serviceeintraege: serviceeintraege,
                              onAddServiceeintrag: _firestoreService.addServiceeintrag,
                              onUpdateServiceeintrag: _firestoreService.updateServiceeintrag,
                              onDeleteServiceeintrag: _firestoreService.deleteServiceeintrag,
                              geraete: geraete,
                              ersatzteile: ersatzteile,
                              verbauteTeile: verbauteTeile,
                              kunden: kunden,
                              standorte: standorte,
                              onAddGeraet: _firestoreService.addGeraet,
                              onUpdateGeraet: _firestoreService.updateGeraet,
                              onDeleteGeraet: _firestoreService.deleteGeraet,
                              onImportGeraete: _firestoreService.importGeraete,
                              onAddErsatzteil: _firestoreService.addErsatzteil,
                              onUpdateErsatzteil: _firestoreService.updateErsatzteil,
                              onDeleteErsatzteil: _firestoreService.deleteErsatzteil,
                              onTeilVerbauen: _firestoreService.addVerbautesTeil,
                              onDeleteVerbautesTeil: _firestoreService.deleteVerbautesTeil,
                              onUpdateVerbautesTeil: _firestoreService.updateVerbautesTeil,
                              onTransfer: _firestoreService.transferErsatzteil,
                              onBookIn: _firestoreService.bookInErsatzteil,
                              onAddKunde: _firestoreService.addKundeAndStandort,
                              onUpdateKunde: _firestoreService.updateKunde,
                              onDeleteKunde: _firestoreService.deleteKunde,
                              onImportKunden: _firestoreService.importKunden,
                              onAddStandort: _firestoreService.addStandort,
                              onUpdateStandort: _firestoreService.updateStandort,
                              onDeleteStandort: _firestoreService.deleteStandort,
                              onAssignGeraet: _firestoreService.assignGeraetToKunde,
                              onAddGeraetForKunde: _firestoreService.addGeraetForKunde,
                              onAddGeraetForKundeOhneStandort:
                              _firestoreService.addGeraetForKundeOhneStandort,
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
