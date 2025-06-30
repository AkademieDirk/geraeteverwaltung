import 'package:flutter/material.dart';
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

// --- Firestore Service ---
// Diese Klasse bündelt alle Datenbank-Operationen an einem Ort.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  // --- Geräte-Operationen ---
  Stream<List<Geraet>> getGeraete() => _db.collection('geraete').snapshots().map((snapshot) => snapshot.docs.map((doc) => Geraet.fromFirestore(doc)).toList());
  Future<void> addGeraet(Geraet geraet) => _db.collection('geraete').add(geraet.toJson());
  Future<void> updateGeraet(Geraet geraet) => _db.collection('geraete').doc(geraet.id).update(geraet.toJson());
  Future<void> deleteGeraet(String geraetId) => _db.collection('geraete').doc(geraetId).delete();

  // --- Ersatzteil-Operationen ---
  Stream<List<Ersatzteil>> getErsatzteile() => _db.collection('ersatzteile').snapshots().map((snapshot) => snapshot.docs.map((doc) => Ersatzteil.fromFirestore(doc)).toList());
  Future<void> addErsatzteil(Ersatzteil ersatzteil) => _db.collection('ersatzteile').add(ersatzteil.toJson());
  Future<void> updateErsatzteil(Ersatzteil ersatzteil) => _db.collection('ersatzteile').doc(ersatzteil.id).update(ersatzteil.toJson());
  Future<void> deleteErsatzteil(String ersatzteilId) => _db.collection('ersatzteile').doc(ersatzteilId).delete();

  // --- Historien-Operationen ---
  Stream<Map<String, List<VerbautesTeil>>> getVerbauteTeile() {
    return _db.collection('historie').snapshots().map((snapshot) {
      Map<String, List<VerbautesTeil>> historie = {};
      for (var doc in snapshot.docs) {
        final seriennummer = doc.id;
        final teileData = doc.data()['teile'] as List<dynamic>? ?? [];
        final teileListe = teileData.map((data) => VerbautesTeil.fromMap(data)).toList();
        historie[seriennummer] = teileListe;
      }
      return historie;
    });
  }

  Future<void> addVerbautesTeil(String seriennummer, Ersatzteil teil, String lager) async {
    final ersatzteilRef = _db.collection('ersatzteile').doc(teil.id);
    final historieRef = _db.collection('historie').doc(seriennummer);
    return _db.runTransaction((transaction) async {
      final ersatzteilSnapshot = await transaction.get(ersatzteilRef);
      if (!ersatzteilSnapshot.exists) throw Exception("Ersatzteil nicht gefunden!");
      final ersatzteilDaten = Ersatzteil.fromFirestore(ersatzteilSnapshot);
      int aktuellerBestand = ersatzteilDaten.lagerbestaende[lager] ?? 0;
      if (aktuellerBestand <= 0) throw Exception("Kein Bestand in Lager '$lager'.");
      transaction.update(ersatzteilRef, {'lagerbestaende.$lager': FieldValue.increment(-1)});
      final verbautesTeil = VerbautesTeil(
          id: _uuid.v4(),
          ersatzteil: teil,
          installationsDatum: DateTime.now(),
          tatsaechlicherPreis: teil.preis,
          herkunftslager: lager
      );
      transaction.set(historieRef, {'teile': FieldValue.arrayUnion([verbautesTeil.toJson()])}, SetOptions(merge: true));
    });
  }

  Future<void> updateVerbautesTeil(String seriennummer, VerbautesTeil geandertesTeil) async {
    final docRef = _db.collection('historie').doc(seriennummer);
    final doc = await docRef.get();
    if (doc.exists) {
      final teileData = doc.data()!['teile'] as List<dynamic>;
      final List<VerbautesTeil> teileListe = teileData.map((data) => VerbautesTeil.fromMap(data)).toList();
      final index = teileListe.indexWhere((t) => t.id == geandertesTeil.id);
      if (index != -1) {
        teileListe[index] = geandertesTeil;
        await docRef.update({'teile': teileListe.map((t) => t.toJson()).toList()});
      }
    }
  }

  Future<void> deleteVerbautesTeil(String seriennummer, VerbautesTeil teil) async {
    final historieRef = _db.collection('historie').doc(seriennummer);
    if (teil.ersatzteil.id.isNotEmpty) {
      final ersatzteilRef = _db.collection('ersatzteile').doc(teil.ersatzteil.id);
      return _db.runTransaction((transaction) async {
        transaction.update(ersatzteilRef, {'lagerbestaende.${teil.herkunftslager}': FieldValue.increment(1)});
        final doc = await transaction.get(historieRef);
        if (doc.exists) {
          final teileData = doc.data()!['teile'] as List<dynamic>? ?? [];
          final List<Map<String, dynamic>> teileMapList = teileData.map((e) => e as Map<String, dynamic>).toList();
          teileMapList.removeWhere((itemMap) => itemMap['id'] == teil.id);
          transaction.update(historieRef, {'teile': teileMapList});
        }
      });
    } else {
      final doc = await historieRef.get();
      if (doc.exists) {
        final teileData = doc.data()!['teile'] as List<dynamic>? ?? [];
        final List<Map<String, dynamic>> teileMapList = teileData.map((e) => e as Map<String, dynamic>).toList();
        teileMapList.removeWhere((itemMap) => itemMap['id'] == teil.id);
        await historieRef.update({'teile': teileMapList});
      }
    }
  }

  Future<void> transferErsatzteil(Ersatzteil teil, String vonLager, String nachLager, int anzahl) async {
    final ersatzteilRef = _db.collection('ersatzteile').doc(teil.id);
    return _db.runTransaction((transaction) async {
      final ersatzteilSnapshot = await transaction.get(ersatzteilRef);
      if (!ersatzteilSnapshot.exists) throw Exception("Ersatzteil nicht mehr gefunden.");
      final ersatzteilDaten = Ersatzteil.fromFirestore(ersatzteilSnapshot);
      int aktuellerVonBestand = ersatzteilDaten.lagerbestaende[vonLager] ?? 0;
      if (aktuellerVonBestand < anzahl) throw Exception("Nicht genügend Bestand im Lager '$vonLager'.");
      transaction.update(ersatzteilRef, {'lagerbestaende.$vonLager': FieldValue.increment(-anzahl), 'lagerbestaende.$nachLager': FieldValue.increment(anzahl)});
    });
  }

  Future<void> bookInErsatzteil(Ersatzteil teil, String lager, int anzahl) {
    final ersatzteilRef = _db.collection('ersatzteile').doc(teil.id);
    return ersatzteilRef.update({'lagerbestaende.$lager': FieldValue.increment(anzahl)});
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerätemanager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return MyHomePage();
        }
        return const LoginScreen();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Geraet>>(
      stream: _firestoreService.getGeraete(),
      builder: (context, geraeteSnapshot) {
        if (geraeteSnapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (geraeteSnapshot.hasError) return Scaffold(body: Center(child: Text('Fehler beim Laden der Geräte: ${geraeteSnapshot.error}')));
        final geraete = geraeteSnapshot.data ?? [];
        return StreamBuilder<List<Ersatzteil>>(
          stream: _firestoreService.getErsatzteile(),
          builder: (context, ersatzteileSnapshot) {
            if (ersatzteileSnapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
            if (ersatzteileSnapshot.hasError) return Scaffold(body: Center(child: Text('Fehler beim Laden der Ersatzteile: ${ersatzteileSnapshot.error}')));
            final ersatzteile = ersatzteileSnapshot.data ?? [];
            return StreamBuilder<Map<String, List<VerbautesTeil>>>(
              stream: _firestoreService.getVerbauteTeile(),
              builder: (context, historieSnapshot) {
                if (historieSnapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
                if (historieSnapshot.hasError) return Scaffold(body: Center(child: Text('Fehler beim Laden der Historie: ${historieSnapshot.error}')));
                final verbauteTeile = historieSnapshot.data ?? {};
                return AuswahlScreen(
                  geraete: geraete,
                  ersatzteile: ersatzteile,
                  verbauteTeile: verbauteTeile,
                  onAddGeraet: _firestoreService.addGeraet,
                  onUpdateGeraet: _firestoreService.updateGeraet,
                  onDeleteGeraet: _firestoreService.deleteGeraet,
                  onAddErsatzteil: _firestoreService.addErsatzteil,
                  onUpdateErsatzteil: _firestoreService.updateErsatzteil,
                  onDeleteErsatzteil: _firestoreService.deleteErsatzteil,
                  onTeilVerbauen: _firestoreService.addVerbautesTeil,
                  onDeleteVerbautesTeil: _firestoreService.deleteVerbautesTeil,
                  onUpdateVerbautesTeil: _firestoreService.updateVerbautesTeil,
                  onTransfer: _firestoreService.transferErsatzteil,
                  onBookIn: _firestoreService.bookInErsatzteil,
                );
              },
            );
          },
        );
      },
    );
  }
}
