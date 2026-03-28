import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget { const AdminDashboardScreen({super.key}); @override State<AdminDashboardScreen> createState()=>_AdminState(); }
class _AdminState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? stats;
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async { final s = await ApiService.stats(); setState(()=>stats = s); }
  @override Widget build(BuildContext context) {
    final classStats = stats?['class_stats'] as List<dynamic>? ?? [];
    final statusStats = stats?['status_stats'] as List<dynamic>? ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Flight statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: [
            _StatBox(title: 'By Class', items: classStats.map((e)=>'${e['class']}: ${e['count']}').join(' • ')),
            _StatBox(title: 'By Status', items: statusStats.map((e)=>'${e['status']}: ${e['count']}').join(' • ')),
          ]),
        ]),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title, items; const _StatBox({required this.title, required this.items});
  @override Widget build(BuildContext context) {
    return Container(width: 320, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(blurRadius: 12, color: Color(0x11000000))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(items, style: const TextStyle(color: Colors.grey)),
      ]));
  }
}