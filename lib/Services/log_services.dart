import 'package:http/http.dart' as http;
import 'dart:convert';

class LogService {
  final String baseUrl =
      'http://192.168.1.7:8000/api'; // Sesuaikan dengan URL API Anda

  Future<List<dynamic>> fetchLogsByDate(String date) async {
    final response = await http.get(Uri.parse('$baseUrl/logs/$date'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['logs'];
      return data;
    } else {
      throw Exception('Failed to load logs');
    }
  }
}
