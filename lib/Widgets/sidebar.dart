import 'package:digilib/Modules/User%20Profile/user_profile.dart';
import 'package:digilib/Services/menu_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sidebar extends StatefulWidget {
  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  late Future<Map<String, IconData>> _iconMapFuture;
  late Future<String?> _userNameFuture;

  @override
  void initState() {
    super.initState();
    _iconMapFuture = _getIconMap();
    _userNameFuture = _getUserName();
  }

  // Method untuk logout
  Future<void> _logout() async {
    // Lakukan proses logout di sini, seperti menghapus data pengguna yang disimpan di SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Hapus data userName dan userGroupID
    await prefs.remove('userName');
    await prefs.remove('userID');
    await prefs.remove('userEmail');
    await prefs.remove('userGroupID');
    // Navigasi ke halaman login
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<Map<String, IconData>> _getIconMap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idGroup = prefs.getString('userGroupID') ?? '';

    try {
      List<Map<String, dynamic>> menus =
          await MenuService.getAllowedMenus(idGroup);
      print("Allowed menus: $menus");

      Map<String, IconData> iconMap = {};
      for (var menu in menus) {
        String iconName = menu['icon_mobile'];
        if (iconName.startsWith('Icons.')) {
          iconName =
              iconName.replaceFirst('Icons.', ''); // Remove 'Icons.' prefix
        }
        iconMap[iconName] = _mapIconNameToIconData(iconName);
      }
      return iconMap;
    } catch (e) {
      // Handle error
      print('Error: $e');
      return {};
    }
  }

  IconData _mapIconNameToIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'folder_copy':
        return Icons.folder_copy;
      case 'group':
        return Icons.group;
      case 'groups':
        return Icons.groups;
      case 'search':
        return Icons.search;
      case 'library_books':
        return Icons.library_books;
      case 'history':
        return Icons.history;
      case 'person':
        return Icons.person;
      case 'logout':
        return Icons.logout;
      case 'book':
        return Icons.book;
      case 'category':
        return Icons.category;
      case 'supervised_user_circle':
        return Icons.supervised_user_circle;
      case 'lock_person':
        return Icons.lock_person;
      case 'archive':
        return Icons.archive;
      // Add more icons as needed
      default:
        return Icons.help; // Default icon if the icon name is not found
    }
  }

  Future<String?> _getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, IconData>>(
        future: _iconMapFuture,
        builder: (context, iconSnapshot) {
          if (iconSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (iconSnapshot.hasError) {
              return Center(child: Text('Error: ${iconSnapshot.error}'));
            } else {
              Map<String, IconData> iconMap = iconSnapshot.data ?? {};
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _getAllowedMenus(),
                builder: (context, menuSnapshot) {
                  if (menuSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (menuSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${menuSnapshot.error}'));
                    } else {
                      List<Map<String, dynamic>> allowedMenus =
                          menuSnapshot.data ?? [];
                      print('Allowed Menus Loaded: $allowedMenus');
                      return FutureBuilder<String?>(
                        future: _userNameFuture,
                        builder: (context, userNameSnapshot) {
                          if (userNameSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            if (userNameSnapshot.hasError) {
                              return Center(
                                  child:
                                      Text('Error: ${userNameSnapshot.error}'));
                            } else {
                              String userName = userNameSnapshot.data ?? 'User';
                              return ListView(
                                padding: EdgeInsets.zero,
                                children: <Widget>[
                                  DrawerHeader(
                                    decoration: BoxDecoration(
                                      color: Colors.teal,
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 30.0,
                                          child: Icon(
                                            Icons.person,
                                            size: 40.0,
                                            color: Colors.teal,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          userName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ..._buildMenuItems(
                                      allowedMenus, iconMap, context),
                                  Divider(
                                      thickness: 2, indent: 10, endIndent: 10),
                                  ListTile(
                                      leading: Icon(
                                        Icons.person,
                                      ),
                                      title: Text(
                                        'Profil User',
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UserProfile()));
                                      }),
                                  ListTile(
                                    leading: Icon(
                                      Icons.logout,
                                      color: Colors.red,
                                    ),
                                    title: Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onTap: _logout,
                                  ),
                                ],
                              );
                            }
                          }
                        },
                      );
                    }
                  }
                },
              );
            }
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getAllowedMenus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idGroup = prefs.getString('userGroupID') ?? '';
    try {
      return MenuService.getAllowedMenus(idGroup);
    } catch (e) {
      // Handle error
      print('Error: $e');
      return [];
    }
  }

  List<Widget> _buildMenuItems(List<Map<String, dynamic>> allowedMenus,
      Map<String, IconData> iconMap, BuildContext context) {
    List<Widget> menuItems = [];
    Map<String, List<Map<String, dynamic>>> subMenuMap = {};

    for (var menu in allowedMenus) {
      List<dynamic> subMenu = menu['subMenu'];
      for (var subMenuItem in subMenu) {
        String? parent = subMenuItem['parent'];
        print('ID Parent: $parent'); // Output: ID Parent: MN0002

        if (parent != null) {
          if (!subMenuMap.containsKey(parent)) {
            subMenuMap[parent] = [];
          }
          subMenuMap[parent]!.add(subMenuItem);
        }
      }
    }

    // Print subMenuMap to check its content
    print('SubMenuMap: $subMenuMap');

    for (var menu in allowedMenus) {
      var parentId = menu['parent'];
      if (parentId == null) {
        // Menu is a top-level menu item
        if (menu['modul'] == 'master' || menu['modul'] == 'user') {
          var children = subMenuMap[menu['id_menu']]?.map((subMenu) {
                print(
                    'Sub-menu for ${menu['desk_menu']}: ${subMenu['desk_menu']}');
                return ListTile(
                  leading: Icon(
                      _mapIconNameToIconData(subMenu['icon_mobile']) ??
                          Icons.help),
                  title: Text(subMenu['desk_menu']),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, subMenu['route']);
                  },
                );
              }).toList() ??
              [];

          print('Children for ${menu['desk_menu']}: $children');
          menuItems.add(ExpansionTile(
            leading:
                Icon(_mapIconNameToIconData(menu['icon_mobile']) ?? Icons.help),
            title: Text(menu['desk_menu']),
            children: children.isNotEmpty
                ? children
                : [ListTile(title: Text('No sub-menu available'))],
          ));
        } else {
          menuItems.add(ListTile(
            leading:
                Icon(_mapIconNameToIconData(menu['icon_mobile']) ?? Icons.help),
            title: Text(menu['desk_menu']),
            onTap: () {
              Navigator.pushReplacementNamed(context, menu['route']);
            },
          ));
        }
      }
    }

    // Print final menuItems to check the complete list
    print('Final Menu Items: $menuItems');

    return menuItems;
  }
}
