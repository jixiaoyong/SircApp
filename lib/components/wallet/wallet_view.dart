import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/utils/color_extension.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/expanded_icon_button.dart';
import 'package:sirc/widgets/title_text.dart';

import 'wallet_logic.dart';

/*
* @description: wallet view
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class WalletPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(WalletLogic());
    final state = Get.find<WalletLogic>().state;

    return Obx(() {
      return SafeArea(
        child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 10.dp),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.dp),
                child: Image.network(
                  "https://img2.doubanio.com/view/group_topic/l/public/p486842201.webp",
                  width: 50.dp,
                  height: 50.dp,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20.dp),
              child: Text("Available Balance",
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: "#ffaab5ff".hexToColor)),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 30.dp, bottom: 45.dp),
              child: Text("\$ ${state.availableBalance}",
                  style: TextStyle(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ExpandedIconButton(
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  logic.onClickBalanceBtn(0);
                },
                height: 50.dp,
                maxWidth: 200.dp,
                colors: [Colors.blue, Colors.blueAccent.shade100],
                text: "Send",
                isExpanded: state.currentClickBtnIndex.value == 0,
              ),
              ExpandedIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () {
                  logic.onClickBalanceBtn(1);
                },
                height: 50.dp,
                maxWidth: 200.dp,
                colors: [Colors.deepPurple, Colors.deepPurpleAccent.shade100],
                text: "Receive",
                isExpanded: state.currentClickBtnIndex.value == 1,
              ),
              ExpandedIconButton(
                icon: Icons.more_horiz_rounded,
                onPressed: () {
                  logic.onClickBalanceBtn(2);
                },
                height: 50.dp,
                maxWidth: 200.dp,
                colors: [Colors.orange, Colors.amber.shade400],
                text: "Total",
                isExpanded: state.currentClickBtnIndex.value == 2,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.dp),
            child: const TitleText(text: "Last Send"),
          )
        ])),
      );
    });
  }
}
