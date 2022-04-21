import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/widgets/footlights_for_bank_card.dart';

import 'add_card_logic.dart';

/*
* @description: add credit card page
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class AddCardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(AddCardLogic());
    final state = Get.find<AddCardLogic>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Card".tr,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 250.dp,
            child: Stack(
              children: [
                FootlightsForBankCard(),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(35.dp),
                  child: BankCardWidget(
                    bankName: "CNSS".tr,
                    cardNumber: "8932 6283 3243 3232",
                    backgroundColors: const [Colors.blue, Colors.purpleAccent],
                    ownerName: "Juan Perez",
                    expirationDate: "02/20",
                    height: 200.dp,
                    width: 200.dp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
