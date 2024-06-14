import 'package:digilib/Widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:digilib/Services/book_services.dart';

class Kontribusi extends StatefulWidget {
  const Kontribusi({super.key});

  @override
  State<Kontribusi> createState() => _KontribusiState();
}

class _KontribusiState extends State<Kontribusi> {
  late Future<List<Map<String, dynamic>>> _futureBooks;
  late String userId; // Variable untuk menyimpan userID

  @override
  void initState() {
    super.initState();
    _fetchUserId(); // Panggil fungsi untuk mengambil userID dari SharedPreferences
  }

  Future<void> _fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userID') ??
        ''; // Mendapatkan userID dari SharedPreferences
    setState(() {
      _futureBooks =
          fetchBooksByUser(userId); // Panggil API dengan userID yang didapatkan
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kontribusi Buku'),
      ),
      drawer: Sidebar(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No books found'));
          } else {
            List<Map<String, dynamic>> books = snapshot.data!;
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return ListTile(
                  title: Text(book['judul']),
                  subtitle: Text(book['deskripsi']),
                  trailing: Text(book['tahun']),
                  // Tambahkan elemen lain sesuai kebutuhan dari data buku
                );
              },
            );
          }
        },
      ),
    );
  }
}
