import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:siren/tabpage.dart';
import 'homePage.dart'; // Replace with your actual home page

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

    // Get the Firebase ID token after successful authentication
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Avidi Siren Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:  const SmsHomePage (), // Your main screen
    );
  }
}
