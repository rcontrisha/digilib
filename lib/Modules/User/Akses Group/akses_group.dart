import 'package:flutter/material.dart';
import 'package:digilib/Services/akses_services.dart';
import 'package:digilib/Services/group_services.dart';
import 'package:digilib/Widgets/sidebar.dart';

class AksesGroup extends StatefulWidget {
  @override
  _AksesGroupState createState() => _AksesGroupState();
}

class _AksesGroupState extends State<AksesGroup> {
  late Future<List<Map<String, dynamic>>> _futureGroups;
  String? _editedGroupId;

  @override
  void initState() {
    super.initState();
    _futureGroups = GroupServices.fetchGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Akses Group'),
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
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return ListTile(
                  title: Text(group['desk_group_user']),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.check_circle,
                      color: Colors.teal,
                    ),
                    onPressed: () {
                      _editedGroupId = group['id_group_user'];
                      _showEditDialog(group);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic>? group) {
    if (group != null) {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Edit Group Menu'),
                      SizedBox(height: 16.0),
                      SizedBox(
                        height: 200.0,
                        child: SingleChildScrollView(
                          child: FutureBuilder(
                            future:
                                AksesService.fetchGroupMenus(_editedGroupId!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<Map<String, dynamic>> groupMenus =
                                    snapshot.data ?? [];
                                return ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: groupMenus.length,
                                  itemBuilder: (context, index) {
                                    final groupMenu = groupMenus[index];
                                    return CheckboxListTile(
                                      title: Text(groupMenu['desk_menu']),
                                      value: groupMenu['id_group_user'] != null,
                                      onChanged: (bool? value) async {
                                        print(
                                            'Checkbox onChanged called with value: $value');
                                        if (value == null) {
                                          return;
                                        }

                                        setState(() {
                                          if (value) {
                                            print('Checkbox checked');
                                            groupMenu['id_group_user'] =
                                                _editedGroupId;
                                          } else {
                                            print('Checkbox unchecked');
                                            // Jika checkbox false, maka hapus data dari server
                                            if (groupMenu['id_menu'] != null &&
                                                groupMenu['id_group_user'] !=
                                                    null) {
                                              print(
                                                  'Calling _deleteGroupMenu with id_menu: ${groupMenu['id_menu']} and id_group_user: ${_editedGroupId!}');
                                              _deleteGroupMenu(_editedGroupId!,
                                                  groupMenu['id_menu']);
                                            }
                                            groupMenu['id_group_user'] = null;
                                          }
                                        });

                                        print('Updated groupMenu: $groupMenu');

                                        if (value) {
                                          // Jika checkbox true, maka update data ke server
                                          await _updateGroupMenu(groupMenu);
                                        }
                                      },
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Close'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      print('Group data is null');
    }
  }

  Future<void> _updateGroupMenu(Map<String, dynamic> newData) async {
    try {
      await AksesService.createGroupMenu(newData);
      _refreshGroups();
    } catch (e) {
      print('Error updating group menu: $e');
      // Handle error
    }
  }

  Future<void> _deleteGroupMenu(String idGroupUser, String idMenu) async {
    try {
      await AksesService.deleteGroupMenu(idGroupUser, idMenu);
      _refreshGroups();
    } catch (e) {
      print('Error deleting group menu: $e');
      // Handle error
    }
  }

  void _refreshGroups() {
    setState(() {
      _futureGroups = GroupServices.fetchGroups();
    });
  }
}
