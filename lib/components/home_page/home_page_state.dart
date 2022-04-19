import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sirc/bean/pair.dart';
import 'package:sirc/mock/mock_utils.dart';
import 'package:sirc/widgets/bank_card_widget.dart';

class HomePageState {
  var currentBankIndex = 0.obs;

  final List<Pair<String, double>> dataChange = MockUtils.dataChange.obs;

  final List<BankCardWidget> banks = [
    BankCardWidget(
      bankName: "CNSS".tr,
      cardNumber: "8932 6283 3243 3232",
      backgroundColors: [Colors.blue, Colors.purpleAccent],
    ),
    BankCardWidget(
      bankName: "DXSS".tr,
      cardNumber: "8932 3223 3243 3232",
      backgroundColors: [Colors.orange, Colors.redAccent],
    ),
    BankCardWidget(
      bankName: "CID".tr,
      cardNumber: "8932 3283 3323 3232",
      backgroundColors: [Colors.green, Colors.greenAccent],
    ),
  ];
}
