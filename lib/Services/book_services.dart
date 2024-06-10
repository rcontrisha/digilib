import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchBooks() async {
  const String baseUrl =
      'http://192.168.1.7:8000/api'; // Ganti dengan URL API Laravel Anda

  final response = await http.get(Uri.parse('$baseUrl/books'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    List<Map<String, dynamic>> books = data.cast<Map<String, dynamic>>();
    return books;
  } else {
    throw Exception('Failed to load books');
  }
}

Future<Map<String, dynamic>> getBookInfo(String bookId) async {
  final url = Uri.parse(
      'http://192.168.1.7:8000/api/books/$bookId'); // Ganti dengan URL API yang sesuai
  final response = await http.get(url);
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return data;
  } else {
    throw Exception('Failed to load book info');
  }
}

Future<void> addBook(Map<String, dynamic> newBook) async {
  const String baseUrl =
      'http://192.168.1.7:8000/api'; // Ganti dengan URL API Laravel Anda

  final response = await http.post(
    Uri.parse('$baseUrl/books'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(newBook),
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode != 201) {
    throw Exception('Failed to add book');
  }
}

Future<void> editBook(String bookId, Map<String, dynamic> updatedBook) async {
  final url =
      'http://192.168.1.7:8000/api/books/$bookId'; // Ganti dengan URL API yang benar
  final response = await http.put(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(updatedBook),
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode != 200) {
    throw Exception('Failed to edit book');
  }
}

Future<void> deleteBook(String id) async {
  const String baseUrl =
      'http://192.168.1.7:8000/api'; // Ganti dengan URL API Laravel Anda

  final response = await http.delete(Uri.parse('$baseUrl/books/$id'));

  if (response.statusCode != 200) {
    throw Exception('Failed to delete book');
  }
}
