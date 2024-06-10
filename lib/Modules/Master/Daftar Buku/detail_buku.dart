import 'package:flutter/material.dart';

class BookDetailScreen extends StatelessWidget {
  final Map<String, dynamic> book;

  BookDetailScreen({required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['judul']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Judul:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(book['judul'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              'Pengarang:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(book['pengarang'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              'Deskripsi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(book['deskripsi'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              'Tahun:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(book['tahun'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              'Penerbit:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(book['penerbit'], style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
