import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/results_screen.dart';
import 'screens/qr_screen.dart';
import 'screens/admin_dashboard_screen.dart';

void main() => runApp(const SasthaApp());

class SasthaApp extends StatelessWidget {
  const SasthaApp({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F8CFF)),
      useMaterial3: true, fontFamily: 'Inter',
    );
    return MaterialApp(
      title: 'SASTHA Airlines',
      theme: theme,
      routes: {
        '/': (_) => const HomeScreen(),
        '/search': (_) => const SearchScreen(),
        '/results': (_) => const ResultsScreen(),
        '/qr': (_) => const QRScreen(),
        '/admin': (_) => const AdminDashboardScreen(),
      },
    );
  }
}