import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:siren/selectAirpot.dart';
import 'package:siren/tabpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'ApiServices.dart'; // Ensure this matches your file name
import 'flightJson.dart';
import 'dart:async'; // Added for Timer

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully!");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }

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
  String? selectedAirport = prefs.getString('selected_airport') ?? 'NUF';

  // Silently call API and update Firebase when app opens
  ApiService().fetchFlight(selectedAirport).catchError((e) {
    print("Error during initial API call: $e");
  });

  runApp(MyApp(
    isFirstTime: isFirstTime,
    selectedAirport: selectedAirport,
  ));
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