import 'package:digilib/Services/book_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Widgets/sidebar.dart';
import '../../Services/log_services.dart'; // Sesuaikan dengan path log_services.dart

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int totalLogsCount = 0;
  late int bookCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchTotalLogsCount();
    _fetchBookCount();
  }

  Future<void> _fetchTotalLogsCount() async {
    try {
      final logService = LogService();
      String selectedDate =
          DateTime.now().toString().substring(0, 10); // Tanggal hari ini
      List<dynamic> logs = await logService.fetchLogsByDate(selectedDate);

      setState(() {
        totalLogsCount = logs.length; // Hitung jumlah total log
      });
    } catch (e) {
      print('Error fetching total logs count: $e');
      // Handle error
    }
  }

  Future<void> _fetchBookCount() async {
    try {
      List<Map<String, dynamic>> books = await fetchBooks();

      setState(() {
        bookCount = books.length; // Menghitung jumlah buku terupload
      });
    } catch (e) {
      print('Error fetching book count: $e');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Tambahkan SingleChildScrollView di sini
          child: Column(
            children: <Widget>[
              FutureBuilder<String>(
                future: _getUserName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text.rich(
                        TextSpan(
                          text: 'Selamat Datang ',
                          style: TextStyle(fontSize: 18.0),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${snapshot.data}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: ' Di Digilib Faiz Software Center',
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildCard('Pengunjung Hari Ini', '$totalLogsCount',
                      Icons.person, Colors.teal),
                  _buildCard(
                      'Buku Terupload', '$bookCount', Icons.book, Colors.pink),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? 'User';
  }

  Widget _buildCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: color,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        width: 150,
        height: 100,
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 30.0,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
