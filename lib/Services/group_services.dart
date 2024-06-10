import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupServices {
  static const String apiUrl =
      'http://192.168.1.7:8000/api'; // Sesuaikan dengan URL API Anda

  static Future<List<Map<String, dynamic>>> fetchGroups() async {
    final response = await http.get(Uri.parse('$apiUrl/group-users'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load groups');
    }
  }

  static Future<void> createGroup(Map<String, dynamic> groupData) async {
    final response = await http.post(
      Uri.parse('$apiUrl/group-users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(groupData),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create group');
    }
  }

  static Future<void> editGroup(
      String id, Map<String, dynamic> groupData) async {
    final response = await http.put(
      Uri.parse('$apiUrl/group-users/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(groupData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to edit group');
    }
  }

  static Future<void> deleteGroup(String id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/group-users/$id'),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete group');
    }
  }
}
