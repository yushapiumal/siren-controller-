import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:siren/selectAirpot.dart';
import 'package:siren/tabpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
 // Replace with your actual home page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully!");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }

  await Firebase.initializeApp();
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: "avidi@go.digitable.io",
      password: "Y&Hhas6567%yg",
    );
    print("User authenticated successfully!");

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String idToken = await user.getIdToken();
      print("Firebase ID Token: $idToken");
    } else {
      print("No user is currently authenticated.");
    }
  } catch (e) {
    print("Failed to authenticate: $e");
  }

  final prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('first_time') ?? true;
  String? selectedAirport = prefs.getString('selected_airport');

  runApp(MyApp(isFirstTime: isFirstTime, selectedAirport: selectedAirport));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  final String? selectedAirport;

  const MyApp({Key? key, required this.isFirstTime, this.selectedAirport})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Avidi Siren Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: isFirstTime ? SelectionScreen() : MyTabbedApp(selectedAirport: selectedAirport),
    );
  }
}
