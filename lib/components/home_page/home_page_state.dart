import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/widgets/line_graph.dart';

class HomePageState {
  var currentBankIndex = 0.obs;

  final List<Pair<String, double>> dataChange = [
    Pair("Mon", 0.3),
    Pair("Tues", 0.5),
    Pair("Wed", 0.1),
    Pair("Thur", 0.6),
    Pair("Fri", 0.9),
    Pair("Satu", 0.2),
    Pair("Sun", 0.8),
  ].obs;

  final List<BankCardWidget> banks = [
    BankCardWidget(
      bankName: "CNSS",
      cardNumber: "8932 6283 3243 3232",
      backgroundColors: [Colors.blue, Colors.purpleAccent],
    ),
    BankCardWidget(
      bankName: "DXSS",
      cardNumber: "8932 3223 3243 3232",
      backgroundColors: [Colors.orange, Colors.redAccent],
    ),
    BankCardWidget(
      bankName: "CID",
      cardNumber: "8932 3283 3323 3232",
      backgroundColors: [Colors.green, Colors.greenAccent],
    ),
  ];
}
