import 'package:digilib/Widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:digilib/Services/log_services.dart'; // Sesuaikan dengan path log_services.dart

class LogViewerScreen extends StatefulWidget {
  @override
  _LogViewerScreenState createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  late String selectedDate;
  List<dynamic> logs = [];
  final LogService logService = LogService();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fetchLogs(selectedDate);
  }

  Future<void> _fetchLogs(String date) async {
    try {
      List<dynamic> fetchedLogs = await logService.fetchLogsByDate(date);
      setState(() {
        logs = fetchedLogs;
      });
      print(
          'Fetched logs for date $date: $logs'); // Print logs setelah di-fetch
    } catch (e) {
      print('Error fetching logs: $e');
      // Handle error
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.parse(selectedDate)) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
        _dateController.text = selectedDate;
        print('Selected date: $selectedDate'); // Print tanggal yang dipilih
        _fetchLogs(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Pengunjung'),
      ),
      drawer: Sidebar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Pilih Tanggal',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 20),
            logs.isEmpty
                ? Center(child: Text('Tidak ada user yang login hari ini.'))
                : Expanded(
                    child: ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return ListTile(
                            title: Text(log['nama_user']),
                            subtitle: Text(log['email']),
                            trailing: Text(log['tgl_log']));
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
