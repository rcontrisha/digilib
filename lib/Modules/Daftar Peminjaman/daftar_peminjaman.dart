import 'package:digilib/Services/book_services.dart';
import 'package:digilib/Services/user_services.dart';
import 'package:digilib/Widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:digilib/Services/pinjam_services.dart';
import 'package:http/http.dart' as http;

class DaftarPeminjaman extends StatefulWidget {
  @override
  _DaftarPeminjamanState createState() => _DaftarPeminjamanState();
}

class _DaftarPeminjamanState extends State<DaftarPeminjaman> {
  late Future<List<Map<String, dynamic>>> _peminjamanFuture;

  @override
  void initState() {
    super.initState();
    _peminjamanFuture = _fetchPeminjaman();
  }

  Future<List<Map<String, dynamic>>> _fetchPeminjaman() async {
    int retries = 0;
    int maxRetries = 5;
    int delay = 1; // Initial delay in seconds

    while (true) {
      try {
        final List<Map<String, dynamic>> peminjaman =
            await PinjamService.fetchPeminjaman();
        // Ambil informasi buku dan pengguna untuk setiap entri peminjaman
        final List<Future<Map<String, dynamic>>> futurePeminjamanInfo =
            peminjaman.map((peminjamanItem) async {
          final bookInfo = await getBookInfo(peminjamanItem['book_id']);
          final userInfo = await getUserInfo(peminjamanItem['user_id']);
          return {
            'judul': bookInfo['judul'],
            'nama_peminjam': userInfo['nama_user'],
            'borrowed_at': peminjamanItem['borrowed_at'],
            'returned_at': peminjamanItem['returned_at'],
            'status_pengembalian': peminjamanItem['status_pengembalian'],
            'id_peminjaman': peminjamanItem['id'], // Tambahkan ID peminjaman
          };
        }).toList();
        // Tunggu sampai semua informasi selesai diambil
        final List<Map<String, dynamic>> peminjamanInfo =
            await Future.wait(futurePeminjamanInfo);
        return peminjamanInfo;
      } catch (e) {
        if (e is http.ClientException && e.message.contains('429')) {
          // Hit the rate limit, apply exponential backoff
          retries++;
          if (retries > maxRetries) {
            throw Exception(
                'Failed to fetch peminjaman info after $maxRetries retries: $e');
          }
          await Future.delayed(Duration(seconds: delay));
          delay *= 2; // Exponential backoff
        } else {
          throw Exception('Failed to fetch peminjaman info: $e');
        }
      }
    }
  }

  // Fungsi untuk mengubah status peminjaman menjadi "Dikembalikan"
  // Fungsi untuk mengembalikan buku dengan memberikan waktu pengembalian
  Future<void> _kembalikanBuku(int idPeminjaman) async {
    try {
      // Kirim permintaan untuk mengembalikan buku bersama dengan waktu pengembalian
      await PinjamService.returnPeminjaman(idPeminjaman, DateTime.now());
      // Refresh daftar peminjaman
      setState(() {
        _peminjamanFuture = _fetchPeminjaman();
      });
      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Buku telah berhasil dikembalikan.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error: $e');
      // Tampilkan pesan kesalahan jika gagal mengembalikan buku
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengembalikan buku.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Peminjaman'),
      ),
      drawer: Sidebar(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _peminjamanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> peminjaman = snapshot.data ?? [];
            return ListView.builder(
              itemCount: peminjaman.length,
              itemBuilder: (context, index) {
                final peminjamanItem = peminjaman[index];
                final returnedAt = peminjamanItem['returned_at'];
                final returnedAtText = returnedAt != null ? returnedAt : '-';
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      'Judul: ${peminjamanItem['judul']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          'Peminjam: ${peminjamanItem['nama_peminjam']}',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tanggal Peminjaman: ${peminjamanItem['borrowed_at']}',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Tanggal Pengembalian: $returnedAtText',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Status Pengembalian: ${peminjamanItem['status_pengembalian']}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: peminjamanItem['status_pengembalian'] ==
                            'Dikembalikan'
                        ? ElevatedButton(
                            onPressed: null,
                            child: Text('Kembalikan'),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              _kembalikanBuku(peminjamanItem['id_peminjaman']);
                            },
                            child: Text('Kembalikan'),
                          ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
