import 'dart:convert';
import 'package:http/http.dart' as http;

class MenuService {
  static const String baseUrl = 'http://192.168.1.7:8000/api';
  static const String allowedMenusEndpoint = '/allowed-menus';

  static Future<List<Map<String, dynamic>>> getAllowedMenus(
      String idGroup) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl + allowedMenusEndpoint),
        headers: {'idGroup': idGroup},
      );
      if (response.statusCode == 200) {
        // Berhasil mendapatkan daftar menu yang diperbolehkan
        final List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> allowedMenus = [];
        for (var item in data) {
          allowedMenus.add(item as Map<String, dynamic>);
        }
        return allowedMenus;
      } else {
        // Gagal mendapatkan daftar menu yang diperbolehkan
        throw Exception('Failed to load allowed menus');
      }
    } catch (e) {
      // Tangani kesalahan jaringan atau format data yang tidak valid
      throw Exception('Error: $e');
    }
  }
}
