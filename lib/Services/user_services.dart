import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://192.168.1.7:8000/api';

Future<List<Map<String, dynamic>>> fetchUsers() async {
  final response = await http.get(Uri.parse('$baseUrl/users'));

  if (response.statusCode == 200) {
    List<dynamic> body = jsonDecode(response.body);
    return body.map((dynamic item) => item as Map<String, dynamic>).toList();
  } else {
    throw Exception('Failed to load users');
  }
}

Future<Map<String, dynamic>> getUserInfo(String userId) async {
  final url = Uri.parse(
      'http://192.168.1.7:8000/api/users/$userId'); // Ganti dengan URL API yang sesuai
  final response = await http.get(url);
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return data;
  } else {
    throw Exception('Failed to load user info');
  }
}

Future<void> createUser(Map<String, dynamic> user) async {
  user['aktif'] = user['aktif'] ? 'Y' : 'N';
  final response = await http.post(
    Uri.parse('$baseUrl/users'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(user),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to create user');
  }
}

Future<void> editUser(String id, Map<String, dynamic> user) async {
  user['aktif'] = user['aktif'] ? 'Y' : 'N';
  final response = await http.put(
    Uri.parse('$baseUrl/users/$id'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(user),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update user');
  }
}

Future<void> deleteUser(String id) async {
  final response = await http.delete(Uri.parse('$baseUrl/users/$id'));

  if (response.statusCode != 200) {
    throw Exception('Failed to delete user');
  }
}
