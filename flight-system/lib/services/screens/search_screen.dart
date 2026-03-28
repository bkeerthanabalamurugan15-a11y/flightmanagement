import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override State<SearchScreen> createState() => _SearchState();
}
class _SearchState extends State<SearchScreen> {
  final fromCtrl = TextEditingController(text: 'MAA');
  final toCtrl = TextEditingController(text: 'DEL');
  DateTime? depart;
  String cls = 'Economy';
  List flights = [];

  Future<void> search() async {
    final params = {"from": fromCtrl.text, "to": toCtrl.text, "depart": depart?.toIso8601String() ?? "", "class": cls};
    final res = await ApiService.searchFlights(params);
    setState(()=>flights = res);
    Navigator.pushNamed(context, '/results', arguments: flights);
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search flights')),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        TextField(controller: fromCtrl, decoration: const InputDecoration(labelText: 'From (MAA)')),
        TextField(controller: toCtrl, decoration: const InputDecoration(labelText: 'To (DEL)')),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () async {
            final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
            setState(()=>depart = picked);
          }, child: Text(depart==null?'Select depart date':depart.toString().split(' ').first)))),
          const SizedBox(width: 8),
          DropdownButton<String>(value: cls, items: const [
            DropdownMenuItem(value: 'Economy', child: Text('Economy')),
            DropdownMenuItem(value: 'Business', child: Text('Business')),
            DropdownMenuItem(value: 'First', child: Text('First')),
          ], onChanged: (v)=>setState(()=>cls=v!)),
        ]),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: search, child: const Text('Search flights')),
      ])),
    );
  }
}