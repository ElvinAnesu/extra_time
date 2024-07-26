import 'dart:convert';
import 'package:extra_time/helper/helperfunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class BuyZesaScreen extends StatefulWidget {
  const BuyZesaScreen({super.key});

  @override
  State<BuyZesaScreen> createState() => _BuyZesaScreenState();
}

class _BuyZesaScreenState extends State<BuyZesaScreen> {
  final List<bool> _isSelected = [true, false];
  final TextEditingController _controllernumber = TextEditingController();
  final TextEditingController _controlleramt = TextEditingController();
  bool _isLoading = false;
  var channel = const MethodChannel("printerChannel");
  String issuedtoken = "";
  bool showvoucher = false;

  void clear() {
    _controlleramt.clear();
    _controllernumber.clear();
  }

  void _confirmTransaction() {
    String currency = _isSelected[0] ? 'USD' : 'ZIG';
    if (_controllernumber.text.isNotEmpty && _controlleramt.text.isNotEmpty) {
      double? amount = double.tryParse(_controlleramt.text);
      String number = _controllernumber.text;

      if (amount! < 5 && currency == 'USD') {
        Fluttertoast.showToast(
            msg: "Minimum USD amount is USD5.00",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (amount < 58 && currency == 'ZIG') {
        Fluttertoast.showToast(
            msg: "Minimum ZIG amount is ZIG58.00",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        _sellZesa(number, currency, amount);
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

  Future<void> logTransaction(currency, extras, amount) async {
    var userid = await HelperFunctions.getUserId();
    var username = await HelperFunctions.getUserName();
    try {
      var url =
          "https://extratimedashboard.vercel.app/api/transactions/$userid";
      final uri = Uri.parse(url);

      var response = await http.post(uri,
          headers: {"Content-Type": "apppication/json"},
          body: jsonEncode({
            "transaction": "Pinless airtime",
            "username": username,
            "userid": userid,
            "currency": currency,
            "amount": amount,
            "issuccessful": true,
            "extras": extras
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
          msg: error.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> _sellZesa(String number, String currency, double amount) async {
    setState(() {
      _isLoading = true;
    });
    double amountincents = amount * 100;
    int integeramount = amountincents.toInt();
    String stringamount = integeramount.toString();
    String refrenceId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final timestampInSeconds = (now / 1000).round();
    String timestamp = timestampInSeconds.toString();
    try {
      const url = "https://test.esolutions.co.zw/billpayments/vend";
      final uri = Uri.parse(url);
      const credentials = 'testz_api_user01:csssbynd';
      final encodedCredentials = base64Encode(utf8.encode(credentials));
      var response = await http.post(uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Basic $encodedCredentials",
          },
          body: jsonEncode({
            "mti": "0200",
            "vendorReference": refrenceId,
            "processingCode": "310000",
            "transmissionDate": timestamp,
            "vendorNumber": "VE19257147501",
            "terminalID": "889898",
            "merchantName": "ZETDC",
            "utilityAccount": number,
            "productName": "ZETDC_PREPAID",
            "amount": stringamount
          }));

      final body = response.body;
      final data = await jsonDecode(body);

      if (data == null) {
        return;
      }

      if (data['narrative'] == "Transaction processed successfully") {
        setState(() {
          _isLoading = false;
        });
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                        "Cutsomer info:${data['customerData']}\nMeter Currency Code:${data['currencyCode']}"),
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
                  child: const Text('Ok'),
                  onPressed: () {
                    // var extras = data["details"];
                    // var currency = data['details']['currency'];
                    // var amount = data['details']['amount'];
                    // clear();
                    // logTransaction(currency, extras, amount);
                    _requestToken(number, currency, stringamount);
                    Navigator.of(context).pop(); // Dismiss the dialog
                  },
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          _isLoading = false;
        });
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
                    Text(data['narrative']),
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
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> _requestToken(
      String number, String currency, String amount) async {
    setState(() {
      _isLoading = true;
    });
    try {
      const url = "https://test.esolutions.co.zw/billpayments/vend";
      final uri = Uri.parse(url);
      const credentials = 'testz_api_user01:csssbynd';
      final encodedCredentials = base64Encode(utf8.encode(credentials));
      String refrenceId = const Uuid().v4();
      final now = DateTime.now().millisecondsSinceEpoch;
      final timestampInSeconds = (now / 1000).round();
      String timestamp = timestampInSeconds.toString();
      var response = await http.post(uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Basic $encodedCredentials",
          },
          body: jsonEncode({
            "mti": "0200",
            "vendorReference": refrenceId,
            "processingCode": "U50000",
            "transmissionDate": timestamp,
            "vendorNumber": "VE20245865801",
            "merchantName": "ZETDC",
            "productName": "ZETDC_PREPAID",
            "utilityAccount": number,
            "aggregator": "POWERTEL",
            "transactionAmount": amount,
            "currencyCode": currency,
            "apiVersion": "02"
          }));

      final body = response.body;
      final data = await jsonDecode(body);

      if (data == null) {
        return;
      }

      if (data['narrative'] == "Transaction processed successfully") {
        List<String> tokendata = data['token'].split('|');
        List<String> fixedcharges = data['fixedCharges'].split('|');
        List<String> arrearsdata = data['arrears'].split('|');

        var token_ = tokendata[0];
        var meter = data['utilityAccount'];
        var kwh = tokendata[1];
        var energy = tokendata[2];
        var debt = arrearsdata.isNotEmpty ? arrearsdata[0] : "0";
        var rea = fixedcharges[2];
        var vat = tokendata[5];
        var currencycode = data['currencyCode'];
        var totalamnt = data['transactionAmount'];

        setState(() {
          _isLoading = false;
          issuedtoken =
              'Tokes: $token_\nMeter: $meter\nKwH: $kwh\nEnergy: $currencycode$energy\nDebt: $currencycode$debt\nREA: $currencycode$rea\nVAT: $currencycode$vat\nTotal Amount: $currencycode$totalamnt\nTendered: $currency$amount';
          showvoucher = true;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
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
                    Text(data['narrative']),
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
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> _printVoucher() async {
    try {
      await channel.invokeMethod("printVoucher", {"token": issuedtoken});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sell Zesa",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 26, 46),
      ),
      body: Builder(builder: (BuildContext context) {
        return _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
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
                      controller: _controllernumber,
                      decoration: const InputDecoration(
                        hintText: 'Meter number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      keyboardType: TextInputType.number,
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
                        onPressed: _confirmTransaction,
                        child: const Text(
                          'Buy Zesa',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    showvoucher
                        ? Column(
                            children: [
                              Text(issuedtoken),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 2, 26, 46),
                                  ),
                                  onPressed: _printVoucher,
                                  child: const Text(
                                    'Print Voucher',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container()
                  ],
                ),
              );
      }),
    );
  }
}
