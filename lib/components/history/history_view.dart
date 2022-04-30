import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/components/slide_menu/slide_menu_logic.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/line_graph.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/widgets/title_text.dart';

import 'history_logic.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(HistoryLogic());
    final state = Get.find<HistoryLogic>().state;
    var slideMenuLogic = Get.find<SlideMenuLogic>();

    return Obx(() {
      return SingleChildScrollView(
          child: SafeArea(
              child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.dp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TitleText(text: "History".tr),
                Expanded(child: Container()),
                Padding(
                    padding: EdgeInsets.only(right: 10.dp),
                    child: GestureDetector(
                      onTap: () => slideMenuLogic.onMenuTap?.call(true),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50.dp),
                        child: NetworkWebImage(
                          state.userAvatar.value,
                          size: Size(50.dp, 50.dp),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ))
              ],
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20.dp),
                      child: Text("\$ 35.269",
                          style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurpleAccent)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5.dp),
                      child: RichText(
                          text: TextSpan(
                              text: "+20%",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold),
                              children: [
                            TextSpan(
                                text: " Last Month".tr,
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal))
                          ])),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.dp),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(15.dp)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade400,
                            blurRadius: 5.dp,
                            spreadRadius: 2.dp)
                      ]),
                  child: DropdownButton<String>(
                    items: state.monthEnglishNameList.map((e) {
                      return DropdownMenuItem<String>(
                        child: Text(e),
                        value: e,
                      );
                    }).toList(),
                    value: state.selectMonth.value,
                    onChanged: (e) {
                      logic.setSelectMonth(e!);
                    },
                    underline: Container(),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.dp, horizontal: 10.dp),
              child: SizedBox(
                height: 200.dp,
                width: double.infinity,
                child: LineGraph(
                  data: state.dataChange,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.dp, vertical: 20.dp),
              padding: EdgeInsets.symmetric(horizontal: 10.dp, vertical: 5.dp),
              height: 50.dp,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                  ),
                  borderRadius: BorderRadius.circular(10.dp)),
              child: TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search".tr,
                    suffixIcon: Icon(Icons.search)),
              ),
            ),
            ...state.moneyOperateList.map((data) {
              return Container(
                padding: EdgeInsets.all(10.dp),
                margin:
                    EdgeInsets.symmetric(vertical: 10.dp, horizontal: 10.dp),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12.withOpacity(0.1),
                          offset: const Offset(0, 0),
                          blurRadius: 10.dp,
                          spreadRadius: 10.dp)
                    ],
                    borderRadius: BorderRadius.circular(10.dp)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    NetworkWebImage(
                      data.userIcon!,
                      size: Size.square(50.dp),
                    ),
                    SizedBox(width: 10.dp),
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
                    // const Spacer(),
                    Text("+ \$${(data.moneyAmount!).toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      )));
    });
  }
}
