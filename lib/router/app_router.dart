// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Diese beiden Widgets kommen aus deinem Projekt.
// Falls deine Pfade/Klassen anders heißen, bitte hier anpassen:
import '../screens/login_screen.dart';
import '../main.dart' show MyHomePage, AuthGate;

/// Gemeinsames Layout für eingeloggte Bereiche.
/// Entfernt "home" aus der Breadcrumb-Anzeige.
/// Auf exakt "/home" wird die AppBar GAR NICHT angezeigt (mehr Platz).
class AppScaffold extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const AppScaffold({
    super.key,
    required this.state,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final segments = state.uri.pathSegments; // z. B. ["geraete","123"]

    // 1) Für "/home" KEINE AppBar anzeigen
    final isExactlyHome = segments.length == 1 && segments.first == 'home';
    if (isExactlyHome) {
      return Scaffold(body: child);
    }

    // 2) Breadcrumbs bauen – Segment "home" vollständig ausblenden
    final filtered = segments.where((s) => s != 'home' && s.isNotEmpty).toList();
    final List<Widget> crumbs = <Widget>[];

    if (filtered.isNotEmpty) {
      String acc = '';
      for (int i = 0; i < filtered.length; i++) {
        final seg = filtered[i];
        acc += '/$seg';
        final last = i == filtered.length - 1;
        final label = _format(seg);
        crumbs.add(
          last
              ? Text(label, style: const TextStyle(fontWeight: FontWeight.bold))
              : InkWell(onTap: () => context.go(acc), child: Text(label)),
        );
        if (!last) crumbs.add(const Text(' / '));
      }
    }

    return Scaffold(
      appBar: filtered.isEmpty
          ? null // falls nichts übrig ist, keine AppBar zeigen
          : AppBar(title: Wrap(children: crumbs)),
      body: child,
    );
  }

  // Helper: Zahlen (IDs) unverändert, Text mit großem Anfangsbuchstaben
  static String _format(String seg) {
    if (int.tryParse(seg) != null) return seg;
    return seg.isEmpty ? seg : '${seg[0].toUpperCase()}${seg.substring(1)}';
  }
}

/// GoRouter-Konfiguration:
/// - "/" und "/login" liegen VOR der Shell (ohne Breadcrumbs)
/// - alles andere in der Shell (Breadcrumbs ohne "home")
final GoRouter appRouter = GoRouter(
  initialLocation: '/', // AuthGate entscheidet, wohin umgeleitet wird
  routes: [
    // Root beobachtet den Auth-Status (dein AuthGate)
    GoRoute(
      path: '/',
      name: 'root',
      builder: (context, state) => const AuthGate(),
    ),

    // Login separat – ohne Breadcrumbs
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Shell: gemeinsames Layout + Breadcrumbs (ohne "home")
    ShellRoute(
      builder: (context, state, child) => AppScaffold(state: state, child: child),
      routes: [
        // Startseite nach Login – zeigt KEINE AppBar (siehe AppScaffold)
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const MyHomePage(),
        ),

        // Beispiel: Geräte (du kannst hier später echte List/Detail-Screens verdrahten)
        GoRoute(
          path: '/geraete',
          name: 'geraete',
          builder: (context, state) => const MyHomePage(),
          routes: [
            GoRoute(
              path: 'neu', // /geraete/neu
              name: 'geraete_neu',
              builder: (context, state) => const MyHomePage(),
            ),
            GoRoute(
              path: ':id', // /geraete/123
              name: 'geraete_detail',
              builder: (context, state) {
                final _ = state.pathParameters['id']!;
                return const MyHomePage();
              },
            ),
          ],
        ),

        // Beispiel: Kunden
        GoRoute(
          path: '/kunden',
          name: 'kunden',
          builder: (context, state) => const MyHomePage(),
        ),
      ],
    ),
  ],
);
