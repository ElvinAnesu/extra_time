import 'dart:convert';

import 'package:extra_time/helper/helperfunctions.dart';
import 'package:extra_time/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController controlleremail = TextEditingController();
  final TextEditingController controllerpassword = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    Future<void> login(String email, String password) async {
      try {
        const url = "https://extratimedashboard.vercel.app/api/login";
        final uri = Uri.parse(url);
        var response = await http.post(uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email, "password": password}));
        final body = response.body;
        final data = await jsonDecode(body);

        if (data['success']) {
          //get user details
          String userid = data['user']['_id'];
          String email = data['user']['email'];
          String role = data['user']['role'];
          String username =
              "${data['user']['firstname']} ${data['user']['surname']}";
          // set sharedpreferances
          await HelperFunctions.setUserLoggedInStatus(true);
          await HelperFunctions.setUserEmailSF(email);
          await HelperFunctions.setUserIdSF(userid);
          await HelperFunctions.setUserRoleSF(role);
          await HelperFunctions.setUsernameSF(username);
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg: data['message'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } catch (error) {
        Fluttertoast.showToast(
            msg: error.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          isLoading = false;
        });
      }
    }

    void loginUser() {
      setState(() {
        isLoading = true;
      });
      if (controlleremail.text.isNotEmpty &&
          controllerpassword.text.isNotEmpty) {
        var email = controlleremail.text;
        var password = controllerpassword.text;
        login(email, password);
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "All fields are required!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 20, right: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/logo.png"),
                    const SizedBox(height: 20),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: controlleremail,
                      decoration: const InputDecoration(
                        hintText: 'User email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      obscureText: true,
                      controller: controllerpassword,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 2, 26, 46),
                        ),
                        onPressed: loginUser,
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
