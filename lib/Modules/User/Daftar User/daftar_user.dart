import 'package:flutter/material.dart';
import 'package:digilib/Services/group_services.dart';
import 'package:digilib/Services/user_services.dart';
import 'package:digilib/Widgets/sidebar.dart';

class DaftarUser extends StatefulWidget {
  @override
  _DaftarUserState createState() => _DaftarUserState();
}

class _DaftarUserState extends State<DaftarUser> {
  late Future<List<Map<String, dynamic>>> _futureUsers;
  late List<Map<String, dynamic>> _groupList = [];

  @override
  void initState() {
    super.initState();
    _futureUsers = fetchUsers();
    _loadGroups();
  }

  void _refreshUsers() {
    setState(() {
      _futureUsers = fetchUsers();
    });
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await GroupServices.fetchGroups();
      setState(() {
        _groupList = groups;
      });
    } catch (e) {
      print('Error loading groups: $e');
    }
  }

  void _showUserDialog({Map<String, dynamic>? user}) {
    final TextEditingController idController =
        TextEditingController(text: user != null ? user['id_user'] : '');
    final TextEditingController nameController =
        TextEditingController(text: user != null ? user['nama_user'] : '');
    final TextEditingController emailController =
        TextEditingController(text: user != null ? user['email'] : '');
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController groupController =
        TextEditingController(text: user != null ? user['id_group_user'] : '');
    bool isActive = user != null ? (user['aktif'] == 'Y') : true;

    List<DropdownMenuItem<String>> dropdownItems = _groupList.map((group) {
      return DropdownMenuItem<String>(
        value: group['id_group_user'].toString(),
        child: Text(group['desk_group_user']),
      );
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user != null ? 'Edit User' : 'Tambah User'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Nama User'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    if (user == null)
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                      ),
                    DropdownButtonFormField<String>(
                      value: groupController.text,
                      onChanged: (newValue) {
                        setState(() {
                          groupController.text = newValue!;
                        });
                      },
                      items: dropdownItems,
                      decoration: InputDecoration(labelText: 'Group User'),
                    ),
                    SwitchListTile(
                      title: Text('Aktif'),
                      value: isActive,
                      onChanged: (bool value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
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
                  final userMap = {
                    'nama_user': nameController.text,
                    'email': emailController.text,
                    'id_group_user': groupController.text,
                    'aktif': isActive,
                  };
                  if (user != null) {
                    await editUser(user['id_user'], userMap);
                  } else {
                    userMap['password'] = passwordController.text;
                    await createUser(userMap);
                  }
                  _refreshUsers();
                  Navigator.pop(context);
                } catch (e) {
                  print('Error: $e');
                  // Handle error
                }
              },
              child: Text(user != null ? 'Simpan' : 'Tambah'),
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
        title: Text('Daftar User'),
      ),
      drawer: Sidebar(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> users = snapshot.data ?? [];
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['nama_user']),
                  subtitle: Text(user['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showUserDialog(user: user);
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
                                  'Apakah Anda yakin ingin menghapus pengguna ini?'),
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
                                      await deleteUser(user['id_user']);
                                      _refreshUsers();
                                      Navigator.of(context).pop();
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
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showUserDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
