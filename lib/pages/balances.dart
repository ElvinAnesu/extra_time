import 'package:flutter/material.dart';

class BalancesScreen extends StatefulWidget {
  const BalancesScreen({super.key});

  @override
  State<BalancesScreen> createState() => _BalancesScreenState();
}

class _BalancesScreenState extends State<BalancesScreen> {
  double usdbalance = 20;
  double zigbalance = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Balances",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 26, 46),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "USD Airtime: ${usdbalance > 10 ? "USD10+" : "USD $usdbalance"}",
            ),
          ),
          const SizedBox(height: 10),
          Center(
              child: Text(
                  "ZIG Airtime: ${zigbalance > 10 ? "USD10+" : "ZIG $zigbalance"}"))
        ],
      ),
    );
  }
}
