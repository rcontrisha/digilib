import 'dart:convert';
import 'package:http/http.dart' as http;

class KategoriService {
  static const String baseUrl = 'http://192.168.1.7:8000/api';

  // Fetch all categories
  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/kategori'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Fetch category by id
  static Future<Map<String, dynamic>> fetchCategoryById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/kategori/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load category');
    }
  }

  // Create new category
  static Future<Map<String, dynamic>> createCategory(
      Map<String, dynamic> category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kategori'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(category),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create category');
    }
  }

  // Update category
  static Future<Map<String, dynamic>> updateCategory(
      String id, Map<String, dynamic> category) async {
    final response = await http.put(
      Uri.parse('$baseUrl/kategori/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(category),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update category');
    }
  }

  // Delete category
  static Future<void> deleteCategory(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/kategori/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete category');
    }
  }
}
