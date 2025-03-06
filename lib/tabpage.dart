import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siren/homePage.dart';
import 'package:siren/selectAirpot.dart';
import 'package:siren/selectLanding.dart';

class MyTabbedApp extends StatelessWidget {
  final String? selectedAirport;

  const MyTabbedApp({Key? key, this.selectedAirport}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Siren Controller'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.speaker_group, size: 40), text: 'Siren'),
               Tab(icon: Icon(Icons.mail_outline_outlined, size: 40), text: 'Flight Message'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: SmsHomePage(selectedAirport: selectedAirport.toString(),)),
           // Center(child: SelectionScreen()), 
            Center(child: TogglePage(selectedAirport: selectedAirport.toString(),)), // Correct tab
          ],
        ),
      ),
    );
  }
}
