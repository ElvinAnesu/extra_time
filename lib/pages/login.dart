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
  final TextEditingController controllerphone = TextEditingController();
  final TextEditingController controllerpin = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    Future<void> login(String phonenumber, String pin) async {
      try {
        const url = "https://extratimedashboard.vercel.app/api/auth/agent";
        final uri = Uri.parse(url);
        var response = await http.post(uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"phonenumber": phonenumber, "pin": pin}));
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
            msg: "Connection failed please check your internet connection",
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
      if (controllerphone.text.isNotEmpty && controllerpin.text.isNotEmpty) {
        var email = controllerphone.text;
        var password = controllerpin.text;
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
      body: Stack(
        children: [
          Opacity(
            opacity: isLoading ? 0.5 : 1.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 20, right: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/logo.png"),
                    const SizedBox(height: 20),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: controllerphone,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        hintText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      obscureText: true,
                      controller: controllerpin,
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        hintText: 'Pin',
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
                        onPressed: isLoading ? () {} : loginUser,
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
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
