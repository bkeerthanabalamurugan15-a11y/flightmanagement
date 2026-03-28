import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
// For Android emulator
static const base = 'http://10.0.2.2:5000';

// For iOS simulator
// static const base = 'http://localhost:5000';

// For physical device (replace with your machine IP)
// static const base = 'http://192.168.1.5:5000'; 

  static Future<List<dynamic>> searchFlights(Map<String, String> params) async {
    final uri = Uri.parse('$base/api/flights').replace(queryParameters: params);
    final res = await http.get(uri);
    final jsonRes = jsonDecode(res.body);
    return jsonRes['data'] ?? [];
  }

  static Future<Map<String, dynamic>> book(String code, String aadhaar) async {
    final res = await http.post(Uri.parse('$base/api/book'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'flight_code': code, 'aadhaar': aadhaar}));
    return jsonDecode(res.body);
  }

  static Future<String> boardingPass(String aadhaar) async {
    final uri = Uri.parse('$base/api/boarding-pass?aadhar=$aadhaar'); // ensure param name matches
    final res = await http.get(uri);
    final jsonRes = jsonDecode(res.body);
    return jsonRes['qr'];
  }

  static Future<Map<String, dynamic>> stats() async {
    final res = await http.get(Uri.parse('$base/api/stats'));
    return jsonDecode(res.body);
  }
}