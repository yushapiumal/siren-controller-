import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siren/homePage.dart';
import 'package:siren/selectAirpot.dart';
import 'package:siren/selectLanding.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // Retrieve SharedPreferences instance
//   final prefs = await SharedPreferences.getInstance();
//   bool isFirstTime = prefs.getBool('first_time') ?? true;
  
//   // Get selectedAirport from SharedPreferences
//   String? selectedAirport = prefs.getString('selected_airport');

//   runApp(MyApp(isFirstTime: isFirstTime, selectedAirport: selectedAirport));
// }

// class MyApp extends StatelessWidget {
//   final bool isFirstTime;
//   final String? selectedAirport;

//   const MyApp({Key? key, required this.isFirstTime, this.selectedAirport}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Avidi Siren Controller',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: isFirstTime ? SelectionScreen() : MyTabbedApp(selectedAirport: selectedAirport),
//     );
//   }
// }

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
            Center(child: SmsHomePage()),
           // Center(child: SelectionScreen()), 
            Center(child: TogglePage(selectedAirport: selectedAirport.toString(),)), // Correct tab
          ],
        ),
      ),
    );
  }
}
