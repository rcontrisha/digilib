import 'dart:async';
import 'package:digilib/Modules/Master/Daftar%20Buku/detail_buku.dart';
import 'package:digilib/Services/book_services.dart';
import 'package:digilib/Services/kategori_services.dart';
import 'package:digilib/Widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DaftarBuku extends StatefulWidget {
  @override
  _DaftarBukuState createState() => _DaftarBukuState();
}

class _DaftarBukuState extends State<DaftarBuku> {
  final StreamController<List<Map<String, dynamic>>> _streamController =
      StreamController();
  List<Map<String, dynamic>> _allBooks = [];
  List<Map<String, dynamic>> _filteredBooks = [];
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    _fetchBooks();
    _categoriesFuture = KategoriService.fetchCategories();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _fetchBooks() async {
    try {
      List<Map<String, dynamic>> books = await fetchBooks();
      setState(() {
        _allBooks = books;
        _filteredBooks = books;
      });
      _streamController.add(_filteredBooks);
    } catch (e) {
      _streamController.addError(e);
    }
  }

  void _filterBooks(String query) {
    if (query.isEmpty) {
      _filteredBooks = _allBooks;
    } else {
      _filteredBooks = _allBooks
          .where((book) =>
              book['judul'].toLowerCase().contains(query.toLowerCase()) ||
              book['pengarang'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    _streamController.add(_filteredBooks);
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Future<void> _editBookDialog(Map<String, dynamic> book) async {
    TextEditingController judulController =
        TextEditingController(text: book['judul']);
    TextEditingController pengarangController =
        TextEditingController(text: book['pengarang']);
    TextEditingController tahunController =
        TextEditingController(text: book['tahun']);
    TextEditingController deskripsiController =
        TextEditingController(text: book['deskripsi']);
    TextEditingController penerbitController =
        TextEditingController(text: book['penerbit']);
    String selectedCategoryId = book['id_kategori'].toString();

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Edit Buku'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: judulController,
                      decoration: InputDecoration(labelText: 'Judul'),
                    ),
                    TextField(
                      controller: pengarangController,
                      decoration: InputDecoration(labelText: 'Pengarang'),
                    ),
                    TextField(
                      controller: tahunController,
                      decoration: InputDecoration(labelText: 'Tahun'),
                    ),
                    TextField(
                      controller: deskripsiController,
                      decoration: InputDecoration(labelText: 'Deskripsi'),
                    ),
                    TextField(
                      controller: penerbitController,
                      decoration: InputDecoration(labelText: 'Penerbit'),
                    ),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _categoriesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          List<Map<String, dynamic>> categories =
                              snapshot.data ?? [];
                          return DropdownButtonFormField<String>(
                            value: selectedCategoryId,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategoryId = newValue!;
                              });
                            },
                            items: categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category['id_kategori'].toString(),
                                child: Text(category['desk_kategori']),
                              );
                            }).toList(),
                            decoration: InputDecoration(labelText: 'Kategori'),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Simpan'),
                  onPressed: () async {
                    try {
                      // Perform update operation here
                      await editBook(book['id_buku'], {
                        'judul': judulController.text,
                        'pengarang': pengarangController.text,
                        'tahun': tahunController.text,
                        'deskripsi': deskripsiController.text,
                        'penerbit': penerbitController.text,
                        'id_kategori': selectedCategoryId,
                      });
                      // Refresh book list
                      await _fetchBooks();
                      Navigator.of(context).pop();
                    } catch (e) {
                      print('Error: $e');
                      // Handle error saat mengedit buku
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addBookDialog() async {
    TextEditingController judulController = TextEditingController();
    TextEditingController pengarangController = TextEditingController();
    TextEditingController tahunController = TextEditingController();
    TextEditingController deskripsiController = TextEditingController();
    TextEditingController penerbitController = TextEditingController();
    String selectedCategoryId = 'KAT0001'; // Nilai kategori default
    String userId = _prefs.getString('userID') ?? '';

    String lastBookId =
        _allBooks.isNotEmpty ? _allBooks.last['id_buku'] : 'BOOK0000';
    int lastId =
        int.parse(lastBookId.substring(4)); // Ambil angka dari id terakhir
    int newId = lastId + 1; // Tambahkan 1 ke id terakhir
    String newBookId =
        'BOOK${newId.toString().padLeft(4, '0')}'; // Format id buku baru

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Tambah Buku'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: judulController,
                      decoration: InputDecoration(labelText: 'Judul'),
                    ),
                    TextField(
                      controller: pengarangController,
                      decoration: InputDecoration(labelText: 'Pengarang'),
                    ),
                    TextField(
                      controller: tahunController,
                      decoration: InputDecoration(labelText: 'Tahun'),
                    ),
                    TextField(
                      controller: deskripsiController,
                      decoration: InputDecoration(labelText: 'Deskripsi'),
                    ),
                    TextField(
                      controller: penerbitController,
                      decoration: InputDecoration(labelText: 'Penerbit'),
                    ),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _categoriesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          List<Map<String, dynamic>> categories =
                              snapshot.data ?? [];
                          return DropdownButtonFormField<String>(
                            value: selectedCategoryId,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategoryId = newValue!;
                              });
                            },
                            items: categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category['id_kategori'].toString(),
                                child: Text(category['desk_kategori']),
                              );
                            }).toList(),
                            decoration: InputDecoration(labelText: 'Kategori'),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Simpan'),
                  onPressed: () async {
                    try {
                      // Perform add operation here
                      await addBook({
                        'id_buku': newBookId, // Tambahkan id buku baru
                        'judul': judulController.text,
                        'pengarang': pengarangController.text,
                        'tahun': tahunController.text,
                        'deskripsi': deskripsiController.text,
                        'penerbit': penerbitController.text,
                        'tgl_upload': DateTime.now().toString(),
                        'id_user_upload':
                            userId, // Ganti dengan ID pengguna yang sesuai
                        'id_kategori': selectedCategoryId,
                      });
                      // Refresh book list
                      await _fetchBooks();
                      Navigator.of(context).pop();
                    } catch (e) {
                      print('Error: $e');
                      // Handle error saat menambah buku
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Buku'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Panggil dialog tambah buku
              _addBookDialog();
            },
          ),
        ],
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
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<Map<String, dynamic>> books = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return ListTile(
                        title: Text(book['judul']),
                        subtitle: Text('Penulis: ${book['pengarang']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Handle edit buku
                                _editBookDialog(book);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                // Handle hapus buku
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Konfirmasi'),
                                    content: Text(
                                        'Apakah Anda yakin ingin menghapus buku ini?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          try {
                                            await deleteBook(book['id_buku']);
                                            // Refresh halaman setelah hapus buku
                                            await _fetchBooks();
                                            Navigator.of(context).pop();
                                          } catch (e) {
                                            print('Error: $e');
                                            // Handle error saat menghapus buku
                                          }
                                        },
                                        child: Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
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
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
