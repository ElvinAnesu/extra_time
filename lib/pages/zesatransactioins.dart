import 'dart:convert';

import 'package:extra_time/helper/helperfunctions.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ZesaTransactionsScreen extends StatefulWidget {
  const ZesaTransactionsScreen({super.key});

  @override
  State<ZesaTransactionsScreen> createState() => _ZesaTransactionsScreenState();
}

class _ZesaTransactionsScreenState extends State<ZesaTransactionsScreen> {
  final TextEditingController controlleremail = TextEditingController();
  final TextEditingController controllerpassword = TextEditingController();
  double usdsales = 0;
  double zigsales = 0;
  bool isloading = false;
  var _transactions = [];

  @override
  void initState() {
    super.initState();
    getTransactions(); // Call method to fetch data when widget initializes
  }

  Future<void> getTransactions() async {
    setState(() {
      isloading = true;
    });
    var userid = await HelperFunctions.getUserId();
    try {
      var url =
          "https://extratimedashboard.vercel.app/api/transactions/$userid";
      final uri = Uri.parse(url);
      var response =
          await http.get(uri, headers: {"Content-Type": "application/json"});
      final body = response.body;
      final data = await jsonDecode(body);

      if (data['success']) {
        var alltransactions = data['transactions'];
        double ussales = 0;
        double zgsales = 0;
        for (var transaction in alltransactions) {
          if (transaction['currency'] == "USD") {
            ussales = ussales + double.parse(transaction['amount']);
          } else if (transaction['currency'] == "ZIG") {
            zgsales = zgsales + double.parse(transaction['amount']);
          }
        }
        setState(() {
          usdsales = ussales;
          zigsales = zgsales;
          _transactions = data['transactions'];
          isloading = false;
        });
      } else {
        Fluttertoast.showToast(
            msg: data['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          isloading = false;
        });
      }
    } catch (error) {
      setState(() {
        isloading = false;
      });
      Fluttertoast.showToast(
          msg: "Connection error. Please check your internet connection",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void clearTransactions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supervisor Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: controlleremail,
                  decoration: const InputDecoration(
                    hintText: 'Supervisor email',
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
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () async {
                if (controlleremail.text.isNotEmpty &&
                    controllerpassword.text.isNotEmpty) {
                  var userid = await HelperFunctions.getUserId();
                  var supervisoremail = controlleremail.text;
                  var supervisorpassword = controllerpassword.text;
                  try {
                    const url =
                        "https://extratimedashboard.vercel.app/api/transactions";
                    final uri = Uri.parse(url);
                    var response = await http.post(uri,
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "supervisoremail": supervisoremail,
                          "supervisorpassword": supervisorpassword,
                          "userid": userid
                        }));

                    final body = response.body;

                    final data = await jsonDecode(body);

                    if (data['success']) {
                      Fluttertoast.showToast(
                          msg: data["message"],
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    } else {
                      Fluttertoast.showToast(
                          msg: data["message"],
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    }
                  } catch (error) {
                    Fluttertoast.showToast(
                        msg: error.toString(),
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
                } else {
                  Fluttertoast.showToast(
                      msg: "All fields are required!",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
                // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "My Sales",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 2, 26, 46),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text("USD Sales: $usdsales"),
              const SizedBox(
                height: 10,
              ),
              Text("ZIG Sales: $zigsales"),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 26, 46),
                  ),
                  onPressed: clearTransactions,
                  child: const Text(
                    'Clear Sales',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            "${_transactions[index]['currency']} ${_transactions[index]['amount']} ${_transactions[index]['transaction']}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: Text(_transactions[index]['createdAt']),
                        );
                      },
                    ),
                    if (isloading)
                      const Center(child: (CircularProgressIndicator()))
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
