import 'package:flutter/material.dart';
import 'package:digilib/Services/group_services.dart';
import 'package:digilib/Widgets/sidebar.dart';

class GroupUser extends StatefulWidget {
  @override
  _GroupUserState createState() => _GroupUserState();
}

class _GroupUserState extends State<GroupUser> {
  late Future<List<Map<String, dynamic>>> _futureGroups;
  List<Map<String, dynamic>> _groups = []; // Simpan grup secara lokal

  @override
  void initState() {
    super.initState();
    _futureGroups = GroupServices.fetchGroups();
  }

  void _refreshGroups() {
    setState(() {
      _futureGroups = GroupServices.fetchGroups();
      _futureGroups.then((groups) {
        _groups = groups;
      });
    });
  }

  String _generateNewGroupId() {
    if (_groups.isEmpty) {
      return 'GRP0001';
    } else {
      final lastGroupId = _groups.last['id_group_user'];
      final newGroupIdNum = int.parse(lastGroupId.substring(3)) + 1;
      return 'GRP${newGroupIdNum.toString().padLeft(4, '0')}';
    }
  }

  void _showGroupDialog({Map<String, dynamic>? group}) {
    final TextEditingController deskController = TextEditingController(
        text: group != null ? group['desk_group_user'] : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(group != null ? 'Edit Group' : 'Tambah Group'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: deskController,
                  decoration: InputDecoration(labelText: 'Deskripsi Group'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final groupData = {
                    'id_group_user': group != null
                        ? group['id_group_user']
                        : _generateNewGroupId(),
                    'desk_group_user': deskController.text,
                  };
                  if (group != null) {
                    await GroupServices.editGroup(
                        group['id_group_user'], groupData);
                  } else {
                    await GroupServices.createGroup(groupData);
                    _groups
                        .add(groupData); // Tambahkan grup baru ke daftar lokal
                  }
                  _refreshGroups();
                  Navigator.pop(context);
                } catch (e) {
                  print('Error: $e');
                  // Handle error
                }
              },
              child: Text(group != null ? 'Simpan' : 'Tambah'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group User'),
      ),
      drawer: Sidebar(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureGroups,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> groups = snapshot.data ?? [];
            _groups =
                groups; // Update daftar grup lokal setiap kali data dimuat
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return ListTile(
                  title: Text(group['desk_group_user']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showGroupDialog(group: group);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          try {
                            await GroupServices.deleteGroup(
                                group['id_group_user']);
                            _refreshGroups();
                          } catch (e) {
                            print('Error: $e');
                            // Handle error
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showGroupDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
