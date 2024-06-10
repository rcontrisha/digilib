import 'package:digilib/Modules/Master/Daftar%20Buku/detail_buku.dart';
import 'package:digilib/Services/book_services.dart';
import 'package:digilib/Services/pinjam_services.dart'; // Import pinjam_services.dart
import 'package:digilib/Widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CariBuku extends StatefulWidget {
  @override
  _CariBukuState createState() => _CariBukuState();
}

class _CariBukuState extends State<CariBuku> {
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _filteredBooks = [];
  bool _isLoading = true;
  String _error = '';
  late SharedPreferences _prefs;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    // Mendapatkan nilai user_id dari Shared Preferences
    _userId = _prefs.getString('userID') ?? '';
    print(_userId);
  }

  Future<void> _fetchBooks() async {
    try {
      final books = await fetchBooks();
      setState(() {
        _books = books;
        _filteredBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error fetching books: $e';
        _isLoading = false;
      });
    }
  }

  void _filterBooks(String query) {
    final filtered = _books
        .where((book) =>
            book['judul'].toLowerCase().contains(query.toLowerCase()) ||
            book['pengarang'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredBooks = filtered;
    });
  }

  void _pinjamBuku(Map<String, dynamic> book) async {
    try {
      // Kirim permintaan peminjaman buku ke backend
      await PinjamService.addPeminjaman({
        'book_id': book['id_buku'],
        'user_id': _userId,
      });

      // Tampilkan Snackbar untuk informasi peminjaman berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil meminjam buku: ${book['judul']}'),
          duration: Duration(seconds: 2), // Atur durasi Snackbar
        ),
      );
    } catch (e) {
      // Tampilkan Snackbar untuk informasi peminjaman gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal meminjam buku: $e'),
          duration: Duration(seconds: 2), // Atur durasi Snackbar
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pencarian Buku'),
      ),
      drawer: Sidebar(),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) {
                _filterBooks(query);
              },
              decoration: InputDecoration(
                labelText: 'Cari Buku',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(child: Text(_error))
                    : ListView.builder(
                        itemCount: _filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = _filteredBooks[index];
                          return ListTile(
                            title: Text(book['judul']),
                            subtitle: Text('Penulis: ${book['pengarang']}'),
                            trailing: IconButton(
                              icon: Icon(Icons.library_books),
                              onPressed: () {
                                _pinjamBuku(book);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BookDetailScreen(book: book),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
