import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});
  @override Widget build(BuildContext context) {
    final flights = ModalRoute.of(context)!.settings.arguments as List<dynamic>? ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: ListView.builder(
        itemCount: flights.length,
        itemBuilder: (_, i) {
          final f = flights[i];
          return ListTile(
            title: Text(f['route'] ?? ''),
            subtitle: Text('${f['duration']} • ${f['code']}'),
            trailing: ElevatedButton(onPressed: () async {
              final aadhaar = await _prompt(context, 'Enter Aadhaar');
              if (aadhaar==null || aadhaar.isEmpty) return;
              final res = await ApiService.book(f['code'], aadhaar);
              if (res['success']==true) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booked • PNR ${res['pnr']}')));
                Navigator.pushNamed(context, '/qr', arguments: aadhaar);
              }
            }, child: const Text('Book')),
          );
        },
      ),
    );
  }

  Future<String?> _prompt(BuildContext context, String label) async {
    final ctrl = TextEditingController();
    return showDialog<String>(context: context, builder: (_) {
      return AlertDialog(title: Text(label), content: TextField(controller: ctrl),
        actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: ()=>Navigator.pop(context, ctrl.text), child: const Text('OK'))]);
    });
  }
}