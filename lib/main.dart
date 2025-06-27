import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // Import für eindeutige IDs
import 'firebase_options.dart';
import 'screens/auswahl_screen.dart';
import 'models/geraet.dart';
import 'models/ersatzteil.dart';
import 'models/verbautes_teil.dart';

// --- Firestore Service ---
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid(); // Instanz zur ID-Generierung

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

  Future<void> addVerbautesTeil(String seriennummer, Ersatzteil teil) {
    final verbautesTeil = VerbautesTeil(
      id: _uuid.v4(),
      ersatzteil: teil,
      installationsDatum: DateTime.now(),
      tatsaechlicherPreis: teil.preis,
    );
    return _db.collection('historie').doc(seriennummer).set({
      'teile': FieldValue.arrayUnion([verbautesTeil.toJson()])
    }, SetOptions(merge: true));
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

  // --- KORRIGIERTE LÖSCHFUNKTION ---
  Future<void> deleteVerbautesTeil(String seriennummer, VerbautesTeil teil) async {
    final docRef = _db.collection('historie').doc(seriennummer);
    final doc = await docRef.get();

    if (doc.exists) {
      final teileData = doc.data()!['teile'] as List<dynamic>? ?? [];
      // Erstelle eine Liste von Objekten
      final List<VerbautesTeil> teileListe = teileData.map((data) => VerbautesTeil.fromMap(data)).toList();

      // Entferne das Element, das die passende einzigartige ID hat
      teileListe.removeWhere((item) => item.id == teil.id);

      // Schreibe die gesamte, aktualisierte Liste zurück in die Datenbank
      await docRef.update({'teile': teileListe.map((t) => t.toJson()).toList()});
    }
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
    return MaterialApp(title: 'Gerätemanager', theme: ThemeData(primarySwatch: Colors.blue), home: MyHomePage());
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
        if (!geraeteSnapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (geraeteSnapshot.hasError) return Scaffold(body: Center(child: Text('Fehler: ${geraeteSnapshot.error}')));
        final geraete = geraeteSnapshot.data!;

        return StreamBuilder<List<Ersatzteil>>(
          stream: _firestoreService.getErsatzteile(),
          builder: (context, ersatzteileSnapshot) {
            if (!ersatzteileSnapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
            if (ersatzteileSnapshot.hasError) return Scaffold(body: Center(child: Text('Fehler: ${ersatzteileSnapshot.error}')));
            final ersatzteile = ersatzteileSnapshot.data!;

            return StreamBuilder<Map<String, List<VerbautesTeil>>>(
              stream: _firestoreService.getVerbauteTeile(),
              builder: (context, historieSnapshot) {
                if (!historieSnapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
                if (historieSnapshot.hasError) return Scaffold(body: Center(child: Text('Fehler: ${historieSnapshot.error}')));
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
                );
              },
            );
          },
        );
      },
    );
  }
}
