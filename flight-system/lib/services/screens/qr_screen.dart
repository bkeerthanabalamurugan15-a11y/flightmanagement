import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';

class QRScreen extends StatefulWidget { const QRScreen({super.key}); @override State<QRScreen> createState()=>_QRState(); }
class _QRState extends State<QRScreen> {
  String? aadhaar; String? qr;
  @override void didChangeDependencies() {
    super.didChangeDependencies();
    aadhaar = ModalRoute.of(context)!.settings.arguments as String?;
    _load();
  }
  Future<void> _load() async {
    final content = await ApiService.boardingPass(aadhaar ?? '');
    setState(()=>qr = content);
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boarding Pass')),
      body: Center(child: qr==null ? const CircularProgressIndicator() :
        Column(mainAxisSize: MainAxisSize.min, children: [
          QrImageView(data: qr!, version: QrVersions.auto, size: 220, backgroundColor: Colors.white),
          const SizedBox(height: 12),
          Text('Scan at gate • ${aadhaar ?? ''}'),
        ])),
    );
  }
}