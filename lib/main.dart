import 'package:digilib/Modules/Daftar%20Peminjaman/daftar_peminjaman.dart';
import 'package:digilib/Modules/Home%20Page/home.dart';
import 'package:digilib/Modules/Kontribusi%20Saya/kontribusi.dart';
import 'package:digilib/Modules/Log%20Pengunjung/log_pengunjung.dart';
import 'package:digilib/Modules/Login%20Screen/login.dart';
import 'package:digilib/Modules/Master/Daftar%20Buku/daftar_buku.dart';
import 'package:digilib/Modules/Master/Daftar%20Kategori/daftar_kategori.dart';
import 'package:digilib/Modules/Pencarian%20Buku/cari_buku.dart';
import 'package:digilib/Modules/User/Akses%20Group/akses_group.dart';
import 'package:digilib/Modules/User/Daftar%20User/daftar_user.dart';
import 'package:digilib/Modules/User/Group%20User/group_user.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digilib',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/caribuku': (context) => CariBuku(),
        '/daftarbuku': (context) => DaftarBuku(),
        '/daftarkategori': (context) => DaftarKategori(),
        '/daftaruser': (context) => DaftarUser(),
        '/groupuser': (context) => GroupUser(),
        '/aksesgroup': (context) => AksesGroup(),
        '/kontribusi': (context) => Kontribusi(),
        '/log': (context) => LogViewerScreen(),
        '/daftarpeminjaman': (context) => DaftarPeminjaman()
      },
    );
  }
}
