import 'dart:convert';
import 'package:http/http.dart' as http;

class PinjamService {
  static const String baseUrl =
      'http://192.168.1.7:8000/api'; // Sesuaikan dengan URL API Anda

  static Future<List<Map<String, dynamic>>> fetchPeminjaman() async {
    final response = await http.get(Uri.parse('$baseUrl/peminjaman'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch peminjaman');
    }
  }

  static Future<Map<String, dynamic>> addPeminjaman(
      Map<String, dynamic> peminjaman) async {
    final response = await http.post(
      Uri.parse('$baseUrl/peminjaman'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(peminjaman),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add peminjaman');
    }
  }

  static Future<Map<String, dynamic>> updatePeminjaman(
      String id, Map<String, dynamic> peminjaman) async {
    final response = await http.put(
      Uri.parse('$baseUrl/peminjaman/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(peminjaman),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update peminjaman');
    }
  }

  static Future<void> deletePeminjaman(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/peminjaman/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete peminjaman');
    }
  }

  static Future<void> returnPeminjaman(
      int idPeminjaman, DateTime returnedAt) async {
    final response = await http.put(
      Uri.parse('$baseUrl/peminjaman/$idPeminjaman/return'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'returned_at': returnedAt.toIso8601String()
      }), // Kirim waktu pengembalian dalam format ISO 8601
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to return peminjaman');
    }
  }
}
