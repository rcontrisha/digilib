import 'package:digilib/Services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:digilib/Widgets/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _userId = ''; // Variabel untuk menyimpan userId dari SharedPreferences

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userID') ??
          ''; // Mengambil userId dari SharedPreferences
      _userNameController.text = prefs.getString('userName') ?? 'Unknown';
      _userEmailController.text =
          prefs.getString('userEmail') ?? 'unknown@example.com';
    });
  }

  Future<void> _updatePassword() async {
    String newPassword = _passwordController.text;

    try {
      print(_userId);
      await editPassword(
          _userId, newPassword); // Menggunakan _userId dari SharedPreferences
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Password berhasil diubah.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Gagal mengubah password: $e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil User'),
      ),
      drawer: Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _userNameController,
              decoration: InputDecoration(
                labelText: 'Nama User',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              enabled: false,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _userEmailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              enabled: false,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updatePassword,
              child: Text('Ubah Password'),
            ),
          ],
        ),
      ),
    );
  }
}
