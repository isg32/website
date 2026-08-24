import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/providers.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/login/login_screen.dart';

/// Editorial black/white theme mirroring the public site (Newsreader serif
/// for display text, IBM Plex Mono for meta labels).
ThemeData buildAdminTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.black, brightness: Brightness.light),
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
  );

  return base.copyWith(
    textTheme: base.textTheme
        .apply(fontFamily: GoogleFonts.ibmPlexMono().fontFamily)
        .copyWith(
          headlineLarge: GoogleFonts.newsreader(fontSize: 32, fontWeight: FontWeight.w500),
          headlineMedium: GoogleFonts.newsreader(fontSize: 26, fontWeight: FontWeight.w500),
          headlineSmall: GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w500),
          titleLarge: GoogleFonts.newsreader(fontSize: 20, fontWeight: FontWeight.w500),
        ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFFAFAFA),
      foregroundColor: Colors.black,
      elevation: 0,
      titleTextStyle: GoogleFonts.newsreader(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return MaterialApp(
      title: 'ISG-32 Admin',
      debugShowCheckedModeBanner: false,
      theme: buildAdminTheme(),
      home: session.when(
        data: (isSignedIn) => isSignedIn ? const DashboardScreen() : const LoginScreen(),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => const LoginScreen(),
      ),
    );
  }
}
