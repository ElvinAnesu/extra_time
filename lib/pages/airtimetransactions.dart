import 'dart:convert';

import 'package:extra_time/helper/helperfunctions.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AirtimeTransactionsScreen extends StatefulWidget {
  const AirtimeTransactionsScreen({super.key});

  @override
  State<AirtimeTransactionsScreen> createState() =>
      _AirtimeTransactionsScreenState();
}

class _AirtimeTransactionsScreenState extends State<AirtimeTransactionsScreen> {
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
          "https://extratimedashboard.vercel.app/api/airtimetransactions/$userid";
      final uri = Uri.parse(url);
      var response =
          await http.get(uri, headers: {"Content-Type": "application/json"});
      final body = response.body;
      final data = await jsonDecode(body);

      if (data['success']) {
        var alltransactions = [
          for (var transaction in data['transactions'])
            if (!transaction['cleared']) transaction
        ];
        double ussales = 0;
        double zgsales = 0;
        for (var transaction in alltransactions) {
          if (transaction['currency'] == "USD" && transaction['issuccessful']) {
            ussales = ussales + double.parse(transaction['amount']);
          } else if (transaction['currency'] == "ZIG" &&
              transaction['issuccessful']) {
            zgsales = zgsales + double.parse(transaction['amount']);
          }
        }

        if (mounted) {
          setState(() {
            usdsales = ussales;
            zigsales = zgsales;
            _transactions = alltransactions;
            isloading = false;
          });
        }
      } else {
        setState(() {
          isloading = false;
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
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
      Fluttertoast.showToast(
          msg: "Failed to connect. Please check your internet",
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
            child: Stack(
              children: [
                ListBody(
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
                if (isloading)
                  (const Center(
                    child: CircularProgressIndicator(),
                  ))
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
                  if (mounted) {
                    setState(() {
                      isloading = true;
                    });
                  }
                  try {
                    var url =
                        "https://extratimedashboard.vercel.app/api/airtimetransactions/$userid";
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
                      if (mounted) {
                        setState(() {
                          isloading = false;
                        });
                      }
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
                      if (mounted) {
                        setState(() {
                          isloading = false;
                        });
                      }
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
                    if (mounted) {
                      setState(() {
                        isloading = false;
                      });
                    }
                    Fluttertoast.showToast(
                        msg: "Failed to connect. Please check your internet",
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

  String formatTimestamp(String timestampString) {
    final DateFormat inputFormatter =
        DateFormat('yyyy-MM-ddTHH:mm:ss.SSS'); // Corrected format
    final DateTime timestamp = inputFormatter.parse(timestampString);
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (timestamp.day == now.day) {
      return 'today ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (timestamp.day == yesterday.day) {
      return 'yesterday ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      final DateFormat outputFormatter = DateFormat('dd/MM/yy HH:mm');
      return outputFormatter.format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Airtime Sales",
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
              _transactions.isEmpty
                  ? Center(
                      child: !isloading
                          ? const Text("No uncleared transactions found")
                          : Container(),
                    )
                  : Expanded(
                      child: Flexible(
                        child: ListView.separated(
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                                title: Text(
                                  "${_transactions[index]['currency']} ${_transactions[index]['amount']} to ${_transactions[index]['extras'] != null ? _transactions[index]['extras']['reciever'] : null} ",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _transactions[index]['issuccessful']
                                          ? "completed"
                                          : "failed",
                                      style: TextStyle(
                                          color: _transactions[index]
                                                  ['issuccessful']
                                              ? Colors.green
                                              : Colors.red),
                                    ),
                                    Text(formatTimestamp(
                                        _transactions[index]['createdAt'])),
                                  ],
                                ));
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                        ),
                      ),
                    ),
            ],
          ),
        ));
  }
}
