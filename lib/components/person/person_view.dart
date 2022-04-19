import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/components/slide_menu/slide_menu_logic.dart';
import 'package:sirc/utils/size_extension.dart';
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.dp),
                child: Image.network(
                  "https://img2.doubanio.com/view/group_topic/l/public/p486842201.webp",
                  width: 100.dp,
                  height: 100.dp,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10.dp, 0, 8.dp),
              child: Text("JI,XIAOYONG",
                  style: TextStyle(fontSize: 20.sp, color: Colors.black)),
            ),
            Text("Total Spending",
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
                  var data = state.moneyOperateList[index];
                  var textColor =
                      currentIndex == index ? Colors.white : Colors.black;
                  return GestureDetector(
                    onTap: () {
                      logic.onClick(index);
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50.dp),
                            child: Container(
                              color: Colors.white,
                              child: Image.network(data.userIcon!,
                                  width: 50.dp, height: 50.dp),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.dp),
                            child: Text(
                                "${index % 3 == 0 ? "-" : "+"} \$${(data.moneyAmount!).toStringAsFixed(2)}",
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
                  const TitleText(text: "General Information"),
                  ...state.generalInformationList.map((item) {
                    var index = state.generalInformationList.indexOf(item);
                    return Container(
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
                          if (index != state.generalInformationList.length - 1)
                            Container(
                              height: 1,
                              margin: EdgeInsets.only(top: 10.dp),
                              color: Colors.grey.withOpacity(0.2),
                            )
                        ],
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