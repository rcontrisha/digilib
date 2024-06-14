import 'dart:convert';
import 'package:http/http.dart' as http;

class AksesService {
  static const String baseUrl = 'http://192.168.1.7:8000/api';

  static Future<List<Map<String, dynamic>>> fetchGroupMenus(
      String idGroupMenu) async {
    final response =
        await http.get(Uri.parse('$baseUrl/akses-group/$idGroupMenu'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load group menus');
    }
  }

  static Future<void> updateGroupMenu(
      String idGroupMenu, Map<String, dynamic> newData) async {
    final url = Uri.parse('$baseUrl/akses-group/$idGroupMenu');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update group menu');
    }
  }

  static Future<void> createGroupMenu(Map<String, dynamic> newData) async {
    final url = Uri.parse('$baseUrl/akses-group');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newData),
    );
    print(response.statusCode);

    if (response.statusCode != 201) {
      throw Exception('Failed to create group menu');
    }
  }

  static Future<void> deleteGroupMenu(String idGroupUser, String idMenu) async {
    final url = Uri.parse('$baseUrl/akses-group');

    // Set header dengan ID grup user dan ID grup menu
    Map<String, String> headers = {
      'id_group_user': idGroupUser,
      'id_menu': idMenu,
    };

    final response = await http.delete(
      url,
      headers: headers,
    );

    print(response.body);

    if (response.statusCode != 204) {
      throw Exception('Failed to delete group menu');
    }
  }
}
