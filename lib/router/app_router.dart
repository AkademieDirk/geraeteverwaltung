// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekte/screens/kunden/kunden_screen.dart';

// === Deine echten Screens (bitte anpassen, falls Namen/Pfade anders sind) ===
import '../screens/bestandsliste_screen.dart';
import '../screens/geraeteaufnahme/geraeteaufnahme_screen.dart';
import '../screens/kunden_screen.dart';

/// Zentraler GoRouter für deine Web-App.
/// Vorteile: saubere URLs, Back-Button im Browser, Deep Links.
final GoRouter appRouter = GoRouter(
  // Auf welche URL die App beim Start geht:
  initialLocation: '/geraete',

  routes: [
    // Start/Redirect auf Geräteübersicht (optional zusätzlich zur initialLocation)
    GoRoute(
      name: 'home',
      path: '/',
      redirect: (context, state) => '/geraete',
    ),

    // Geräte-Liste
    GoRoute(
      name: 'geraete_liste',
      path: '/geraete',
      builder: (context, state) => BestandslisteScreen(
        // Falls dein Screen Parameter braucht, hier einsetzen
        // z. B. Filter aus Query: state.uri.queryParameters['modell']
      ),
      routes: [
        // Neues Gerät anlegen
        GoRoute(
          name: 'geraet_neu',
          path: 'neu',
          builder: (context, state) => GeraeteAufnahmeScreen(
            // Modus "neu" – passe Props an deinen Konstruktor an
            // z. B. existingId: null
          ),
        ),
        // Gerät bearbeiten/Details per ID: /geraete/123
        GoRoute(
          name: 'geraet_detail',
          path: ':id',
          builder: (context, state) {
            final String id = state.pathParameters['id']!;
            return GeraeteAufnahmeScreen(
              // Modus "bearbeiten" – reiche die ID weiter
              // z. B. existingId: id
            );
          },
        ),
      ],
    ),

    // Kunden-Ansicht
    GoRoute(
      name: 'kunden',
      path: '/kunden',
      builder: (context, state) => const KundenScreen(),
    ),
  ],
);
