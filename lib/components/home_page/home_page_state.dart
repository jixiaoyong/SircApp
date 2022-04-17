import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:sirc/widgets/bank_card_widget.dart';

class HomePageState {
  var currentBankIndex = 0.obs;

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
