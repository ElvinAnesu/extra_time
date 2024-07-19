import 'package:extra_time/helper/helperfunctions.dart';
import 'package:extra_time/pages/home.dart';
import 'package:extra_time/pages/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isloggedin = false;

  @override
  void initState() {
    super.initState();
    isUserLoggedin();
  }

  isUserLoggedin() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          isloggedin = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Set primary color swatch
        primaryColor: Colors.blue, // Set primary color
        // Define other theme properties as needed
      ),
      home:
          Scaffold(body: isloggedin ? const HomeScreen() : const LoginScreen()),
    );
  }
}
