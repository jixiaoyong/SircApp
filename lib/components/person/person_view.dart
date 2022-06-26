import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/components/slide_menu/slide_menu_logic.dart';
import 'package:sirc/utils/number_extension.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/widgets/title_text.dart';

import 'person_logic.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class PersonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(PersonLogic());
    final state = Get.find<PersonLogic>().state;
    final slideMenuLogic = Get.find<SlideMenuLogic>();

    return SingleChildScrollView(
        child: SafeArea(
            child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16.dp),
      child: Obx(() {
        var currentIndex = state.currentIndex.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      slideMenuLogic.onMenuTap?.call(true);
                    },
                    icon: const Icon(Icons.more_horiz_rounded))
              ],
            ),
            Padding(
                padding: EdgeInsets.only(top: 20.dp),
                child: GestureDetector(
                  onTap: () => slideMenuLogic.onMenuTap?.call(true),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.dp),
                    child: NetworkWebImage(
                      state.userAvatar.value,
                      size: Size(100.dp, 100.dp),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                )),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10.dp, 0, 8.dp),
              child: Text(state.userName.value,
                  style: TextStyle(fontSize: 20.sp, color: Colors.black)),
            ),
            Text("Total Spending".tr,
                style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
            Padding(
              padding: EdgeInsets.only(top: 10.dp, bottom: 30.dp),
              child: Text("\$90,960",
                  style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.deepPurpleAccent,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 200.dp,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  var heroTag = "heroTag_$index";
                  var data = state.moneyOperateList[index];
                  var textColor =
                      currentIndex == index ? Colors.white : Colors.black;
                  return GestureDetector(
                    onTap: () {
                      logic.onClick(index, heroTag);
                    },
                    child: Container(
                      height: 200.dp,
                      width: 150.dp,
                      margin: EdgeInsets.symmetric(
                          vertical: 15.dp, horizontal: 10.dp),
                      padding: EdgeInsets.all(10.dp),
                      decoration: BoxDecoration(
                          color: currentIndex == index
                              ? Colors.blue
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10.dp),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10.dp,
                                offset: const Offset(0, 5),
                                spreadRadius: 0.5)
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: heroTag,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50.dp),
                              child: NetworkWebImage(
                                data.userIcon!,
                                size: Size.square(50.dp),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.dp),
                            child: Text(data.moneyAmount.toFormatedMoneyStr,
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    color: textColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const Spacer(),
                          Text(data.moneyActionName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: textColor,
                              )),
                          Padding(
                            padding: EdgeInsets.only(top: 2.dp),
                            child: Text(data.time!,
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: textColor.withOpacity(0.8))),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                scrollDirection: Axis.horizontal,
                itemCount: state.moneyOperateList.length,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.dp, vertical: 20.dp),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleText(text: "General Information".tr),
                  ...state.generalInformationList.value.map((item) {
                    var index =
                        state.generalInformationList.value.indexOf(item);
                    return GestureDetector(
                      onTap: () {
                        logic.onClickInformation(
                          index,
                        );
                      },
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                            vertical: 10.dp, horizontal: 20.dp),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius:
                                            BorderRadius.circular(5.dp)),
                                    padding: EdgeInsets.all(5.dp),
                                    child: Icon(item.first)),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.dp),
                                  child: Text(item.second),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_forward_ios_rounded)
                              ],
                            ),
                            if (index !=
                                state.generalInformationList.value.length - 1)
                              Container(
                                height: 1,
                                margin: EdgeInsets.only(top: 10.dp),
                                color: Colors.grey.withOpacity(0.2),
                              )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.dp),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10.dp,
                      spreadRadius: .6.dp,
                    )
                  ]),
            )
          ],
        );
      }),
    )));
  }
}
