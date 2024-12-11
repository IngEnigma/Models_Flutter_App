import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF256b8e),
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Color(0xFFf3f8fc),
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Logs'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/logs');
            },
          ),
          ListTile(
            leading: const Icon(Icons.linear_scale),
            title: const Text('Linear Model'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/linear');
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_florist),
            title: const Text('Flowers Model'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/flower');
            },
          ),
          ListTile(
            leading: const Icon(Icons.face),
            title: const Text('Faces Model'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/faces');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () {
              Navigator.pop(context);
              Provider.of<MyAppState>(context, listen: false).logout();
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
