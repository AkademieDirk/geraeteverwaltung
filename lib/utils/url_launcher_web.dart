// lib/utils/url_launcher_web.dart

// Importiere die benötigten APIs.
// 'dart:js_interop' und 'package:web' werden nur relevant,
// wenn für die Web-Plattform kompiliert wird.
import 'package:flutter/foundation.dart' show kIsWeb;
// dart:js_interop ist nicht direkt für package:web notwendig,
// da package:web bereits die JS-Interop-Schicht abstrahiert.
// import 'dart:js_interop'; // Diese Zeile kann entfernt werden, da package:web sie nicht direkt benötigt.
import 'package:web/web.dart' as web; // Nicht bedingt importieren


// Diese Funktion wird in ServiceScreen aufgerufen.
// Ihr Verhalten ist bedingt durch `kIsWeb`.
void openUrlInNewTabWeb(String url) {
  if (kIsWeb) {
    // Dieser Block wird NUR im Web ausgeführt.
    // package:web's window.open erwartet Dart Strings, keine JSString.
    web.window.open(url, '_blank'); // <--- KORREKTUR HIER: `.toJS` entfernt
  } else {
    // Dieser Block wird NUR auf Nicht-Web-Plattformen ausgeführt.
    // Hier tun wir nichts, da url_launcher im ServiceScreen für diese Fälle zuständig ist.
    // print('openUrlInNewTabWeb wurde auf einer Nicht-Web-Plattform aufgerufen, tut aber nichts.');
  }
}