import 'dart:convert';
import 'package:extra_time/helper/helperfunctions.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class BuyAirtimeScreen extends StatefulWidget {
  const BuyAirtimeScreen({super.key});
  @override
  State<BuyAirtimeScreen> createState() => _BuyAirtimeScreenState();
}

class _BuyAirtimeScreenState extends State<BuyAirtimeScreen> {
  final List<bool> _isSelected = [true, false];
  final TextEditingController _controllernumber = TextEditingController();
  final TextEditingController _controlleramt = TextEditingController();
  bool _isLoading = false;

  void clear() {
    _controlleramt.clear();
    _controllernumber.clear();
  }

  void _confirmTransaction() {
    String currency = _isSelected[0] ? 'USD' : 'ZIG';
    if (_controllernumber.text.isNotEmpty && _controlleramt.text.isNotEmpty) {
      double? amount = double.tryParse(_controlleramt.text);
      String number = _controllernumber.text;

      if ((currency == 'USD' && amount! > 50) ||
          (currency == 'USD' && amount! < 0.5)) {
        Fluttertoast.showToast(
            msg: "Amount should be between USD0.5 to USD50",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if ((currency == 'ZIG' && amount! > 500) ||
          (currency == 'ZIG' && amount! > 500)) {
        Fluttertoast.showToast(
            msg: "Amount should be between ZIG5 to ZIG500",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm '),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Buy $currency $amount airtime for $number'),
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
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss the dialog
                    logTransaction(number, currency, amount);
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      Fluttertoast.showToast(
          msg: "All fields are required",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> logTransaction(number, currency, amount) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    var userid = await HelperFunctions.getUserId();
    var username = await HelperFunctions.getUserName();
    try {
      var url = "https://extratimedashboard.vercel.app/api/airtimetransactions";
      final uri = Uri.parse(url);

      var response = await http.post(uri,
          headers: {"Content-Type": "apppication/json"},
          body: jsonEncode({
            "executedby": username,
            "executerid": userid,
            "currency": currency,
            "amount": amount,
            "extras": {"reciever": number}
          }));

      final body = response.body;
      final data = await jsonDecode(body);

      if (data['success']) {
        _sellAirtime(number, currency, amount, data['transaction']['_id']);
      } else {
        Fluttertoast.showToast(
            msg: data["message"],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (error) {
      Fluttertoast.showToast(
          msg: "Failed to connect. Please check your internet connection",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> changeTransactionStatus(var id, var extras) async {
    try {
      var url = "https://extratimedashboard.vercel.app/api/airtimetransactions";
      final uri = Uri.parse(url);

      await http.put(uri,
          headers: {"Content-Type": "apppication/json"},
          body: jsonEncode({
            "_id": id,
            "extras": extras,
          }));
    } catch (_) {}
  }

  Future<void> _sellAirtime(String number, String currency, double amount,
      String transactionid) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      const url =
          "https://bulkairtime.omnicontact.biz/api/v1/obad/gateway/sell";
      final uri = Uri.parse(url);
      var response = await http.post(uri,
          headers: {
            "clientid":
                "API-227HTV-248ZJNP0-07115Z-242YQT-07PX13-15HWNU-1525EK",
            "clientsecret": "u7er2lymp8e8laaf526662285a66f2dea",
            "apikey":
                "viqmllymp8e8lb77986d365ef05ab55ee6a3f28448b71f3269f2858616fa42b",
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            'amount': amount,
            'currency': currency,
            'reciever_number': number,
          }));

      final body = response.body;
      final data = await jsonDecode(body);

      if (data['success']) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        changeTransactionStatus(transactionid, data['details']);
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(data['message']),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    setState(() {
                      _isLoading = false;
                    });
                    clear();
                    Navigator.of(context).pop(); // Dismiss the dialog
                  },
                ),
              ],
            );
          },
        );
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Failed'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(data['message']),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    clear();
                    Navigator.of(context).pop(); // Dismiss the dialog
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      Fluttertoast.showToast(
          msg: "Failed to connect. Please check your internet connection",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Sell Airtime",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 26, 46),
      ),
      body: Builder(builder: (BuildContext context) {
        return Stack(
          children: [
            Opacity(
              opacity: _isLoading ? 0.5 : 1.0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ToggleButtons(
                        isSelected: _isSelected,
                        onPressed: (int index) {
                          setState(() {
                            // Toggle the state of the selected index
                            for (int buttonIndex = 0;
                                buttonIndex < _isSelected.length;
                                buttonIndex++) {
                              if (buttonIndex == index) {
                                _isSelected[buttonIndex] = true;
                              } else {
                                _isSelected[buttonIndex] = false;
                              }
                            }
                          });
                        },
                        children: const <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('USD'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('ZIG'),
                          ),
                        ]),
                    const SizedBox(height: 10),
                    TextField(
                      keyboardType: TextInputType.number,
                      enabled: !_isLoading,
                      controller: _controllernumber,
                      decoration: const InputDecoration(
                        hintText: 'Receiver number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      keyboardType: TextInputType.number,
                      enabled: !_isLoading,
                      controller: _controlleramt,
                      decoration: const InputDecoration(
                        hintText: 'Amount',
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
                        onPressed: _isLoading ? () {} : _confirmTransaction,
                        child: const Text(
                          'Sell Airtime',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        );
      }),
    );
  }
}
