import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: MyTabbedApp(),
  ));
}

class MyTabbedApp extends StatelessWidget {
  const MyTabbedApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tab View with Icons'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.home, size: 20),
                text: 'Home',
              ),
              Tab(
                icon: Icon(Icons.settings, size: 20),
                text: 'Settings',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Home Tab Content')),
            Center(child: Text('Settings Tab Content')),
          ],
        ),
      ),
    );
  }
}
