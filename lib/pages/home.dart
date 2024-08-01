import 'package:extra_time/helper/helperfunctions.dart';
import 'package:extra_time/pages/balances.dart';
import 'package:extra_time/pages/buyairtime.dart';
import 'package:extra_time/pages/login.dart';
import 'package:extra_time/pages/transactions.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var labels = ["Econet", "Zesa", "Transactions", "Balances"];
    var images = ["econet.png", "zesa.png", "history.png", "balances.png"];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Extra Time",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () async {
              await HelperFunctions.setUserLoggedInStatus(false);
              await HelperFunctions.setUserEmailSF("");
              await HelperFunctions.setUserRoleSF("");
              await HelperFunctions.setUsernameSF("");
              Navigator.pushReplacement(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 2, 26, 46),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0),
            itemCount: 4,
            itemBuilder: (BuildContext context, index) {
              return GestureDetector(
                onTap: () {
                  switch (index) {
                    case 0:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BuyAirtimeScreen()));
                      break;
                    case 1:
                      Fluttertoast.showToast(
                          msg: "Comming soon",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      break;
                    case 2:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const TransactionsScreen()));
                      break;
                    case 3:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BalancesScreen()));
                      break;
                  }
                },
                child: Card(
                  child: Column(
                    children: [
                      Expanded(child: Image.asset("assets/${images[index]}")),
                      Text(labels[index])
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
