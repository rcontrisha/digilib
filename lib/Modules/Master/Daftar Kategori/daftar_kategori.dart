import 'package:flutter/material.dart';
import 'package:digilib/Services/kategori_services.dart';
import 'package:digilib/Widgets/sidebar.dart';

class DaftarKategori extends StatefulWidget {
  @override
  _DaftarKategoriState createState() => _DaftarKategoriState();
}

class _DaftarKategoriState extends State<DaftarKategori> {
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await KategoriService.fetchCategories();
      setState(() {
        _categories = categories;
        _filteredCategories = categories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void _filterCategories(String query) {
    final filtered = _categories
        .where((category) => category['desk_kategori']
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredCategories = filtered;
    });
  }

  void _showAddDialog() {
    final TextEditingController _deskKategoriController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Kategori'),
        content: TextFormField(
          controller: _deskKategoriController,
          decoration: InputDecoration(labelText: 'Deskripsi Kategori'),
        ),
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
                final String lastCategoryId = _categories.isNotEmpty
                    ? _categories.last['id_kategori']
                    : 'KAT0000';
                int lastId = int.parse(lastCategoryId
                    .substring(3)); // Ambil angka dari id terakhir
                int newId = lastId + 1; // Tambahkan 1 ke id terakhir
                String newCategoryId =
                    'KAT${newId.toString().padLeft(4, '0')}'; // Format id kategori baru

                final Map<String, dynamic> newCategory = {
                  'id_kategori': newCategoryId, // Tambahkan id kategori baru
                  'desk_kategori': _deskKategoriController.text,
                };

                await KategoriService.createCategory(newCategory);

                Navigator.of(context).pop();
                _fetchCategories();
              } catch (e) {
                print('Error: $e');
                // Handle error
              }
            },
            child: Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> category) {
    final TextEditingController _deskKategoriController = TextEditingController(
      text: category['desk_kategori'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Kategori'),
        content: TextFormField(
          controller: _deskKategoriController,
          decoration: InputDecoration(labelText: 'Deskripsi Kategori'),
        ),
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
                final Map<String, dynamic> newCategory = {
                  'desk_kategori': _deskKategoriController.text,
                };

                await KategoriService.updateCategory(
                    category['id_kategori'], newCategory);

                Navigator.of(context).pop();
                _fetchCategories();
              } catch (e) {
                print('Error: $e');
                // Handle error
              }
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Kategori'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddDialog();
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
              onChanged: (query) => _filterCategories(query),
              decoration: InputDecoration(
                labelText: 'Cari Kategori',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCategories.length,
              itemBuilder: (context, index) {
                final category = _filteredCategories[index];
                return ListTile(
                  title: Text(category['desk_kategori']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditDialog(category);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Konfirmasi'),
                              content: Text(
                                  'Apakah Anda yakin ingin menghapus kategori ini?'),
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
                                      await KategoriService.deleteCategory(
                                          category['id_kategori']);
                                      Navigator.of(context).pop();
                                      _fetchCategories();
                                    } catch (e) {
                                      print('Error: $e');
                                      // Handle error
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
