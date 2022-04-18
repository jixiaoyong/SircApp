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
            child: TitleText(
                text: state.moneyTypes[state.currentClickBtnIndex.value]),
          ),
          ...state.moneyOperateList.map((data) {
            return Container(
              padding: EdgeInsets.all(10.dp),
              margin: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 20.dp),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        offset: const Offset(0, 0),
                        blurRadius: 10.dp,
                        spreadRadius: 10.dp)
                  ],
                  borderRadius: BorderRadius.circular(10.dp)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.network(data.userIcon!, width: 50.dp, height: 50.dp),
                  SizedBox(width: 20.dp),
                  // Notice: Expanded/Flexible only works in Row/Column, not in Stack
                  // otherwise, it will be a bug: 'Incorrect use of ParentDataWidget.'
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(data.moneyActionName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.black,
                            )),
                        Padding(
                          padding: EdgeInsets.only(top: 8.dp),
                          child: Text(data.time!,
                              style: TextStyle(
                                  fontSize: 10.sp, color: Colors.grey)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                      "${state.currentClickBtnIndex == 0 ? "-" : "+"} \$${(data.moneyAmount!).toStringAsFixed(2)}",
                      style: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        ])),
      );
    });
  }
}
