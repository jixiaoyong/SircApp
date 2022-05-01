import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sirc/bean/pair.dart';
import 'package:sirc/mock/mock_utils.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/widgets/jingang_widget.dart';

class HomePageState {
  var currentBankIndex = 0.obs;
  var userAvatar = "".obs;
  var homeAppBarFlexibleWidgetHeight = 0.0.obs;

  late PageController pageController;

  final List<Pair<String, double>> dataChange = MockUtils.dataChange.obs;

  /// fake tab data: (Name,Id)
  final List<Pair<String, int>> tabDatas = [
    Pair("Follow".tr, 0x0),
    Pair("Hot".tr, 0x1),
    Pair("Explore".tr, 0x2)
  ];

  /// all of those icon come form https://icons8.com/, thanks to them
  final list = [
    ImgText("https://img.icons8.com/office/80/000000/bonds.png", "Bonds"),
    ImgText("https://img.icons8.com/office/80/000000/billing.png", "Billing"),
    ImgText("https://img.icons8.com/office/80/000000/cash.png", "Cash"),
    ImgText(
        "https://img.icons8.com/office/80/000000/money-bag.png", "Money Bag"),
    ImgText("https://img.icons8.com/office/80/000000/wallet.png", "Wallet"),
    ImgText("https://img.icons8.com/office/80/000000/bounced-check.png",
        "Bounced Check"),
    ImgText("https://img.icons8.com/office/80/000000/tax.png", "Tax"),
    ImgText("https://img.icons8.com/office/80/000000/purchase-order.png",
        "Purchase Order"),
    ImgText("https://img.icons8.com/office/80/000000/payment-history.png",
        "Payment History"),
    ImgText("https://img.icons8.com/office/80/000000/card-in-use.png",
        "Card In Use"),
    ImgText("https://img.icons8.com/office/80/000000/card-security.png",
        "Card Security"),
    ImgText(
        "https://img.icons8.com/office/80/000000/bank-card-front-side--v1.png",
        "Bank Card Front Side"),
    ImgText("https://img.icons8.com/office/80/000000/bank-card-missing.png",
        "bank card missing"),
    ImgText("https://img.icons8.com/office/80/000000/credit-control.png",
        "Credit Control"),
    ImgText(
        "https://img.icons8.com/office/80/000000/commodity.png", "Commodity"),
  ];

  final List<BankCardWidget> banks = [
    BankCardWidget(
      bankName: "CNSS".tr,
      cardNumber: "8932 6283 3243 3232",
      ownerName: "Juan Perez",
      expirationDate: "02/20",
    ),
    BankCardWidget(
      bankName: "DXSS".tr,
      cardNumber: "8932 3223 3243 3232",
      ownerName: "Juan Perez",
      expirationDate: "12/29",
    ),
    BankCardWidget(
      bankName: "CID".tr,
      cardNumber: "8932 3283 3323 3232",
      ownerName: "Juan Perez",
      expirationDate: "11/22",
    ),
  ];
}
