import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/widgets/one_title_with_back_button_appbar.dart';

import 'notifications_logic.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(NotificationsLogic());
    final state = Get.find<NotificationsLogic>().state;

    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(
        title: "Notifications".tr,
      ),
      body: SingleChildScrollView(
        child: Obx(() {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.dp, vertical: 10.dp),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Category".tr,
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.dp),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.dp),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: const Offset(0, 1),
                                blurRadius: 2)
                          ]),
                      child: DropdownButton<int>(
                        value: state.currentCategoryIndex.value,
                        items: state.categories.map((e) {
                          return DropdownMenuItem(
                            child: Text(e),
                            value: state.categories.indexOf(e),
                          );
                        }).toList(),
                        onChanged: (value) {
                          logic.setCategory(value ?? 0);
                        },
                        underline: Container(),
                      ),
                    )
                  ],
                ),
                ...state.data.map((item) {
                  final int index = state.data.indexOf(item);
                  final bool isSelected =
                      state.currentExpandIndex.value == index;
                  return Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 15.dp, horizontal: 5.dp),
                    padding:
                        EdgeInsets.symmetric(vertical: 15.dp, horizontal: 5.dp),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.dp),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 5.0,
                              spreadRadius: 1.0,
                              offset: const Offset(0.0, 1.0))
                        ]),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.accents.elementAt(
                                Colors.accents.length % (3 * index + 3)),
                            child: Icon(
                              item.first,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(item.second),
                          trailing: Icon(isSelected
                              ? Icons.keyboard_arrow_up_outlined
                              : Icons.keyboard_arrow_down_outlined),
                          onTap: () {
                            logic.setIndexExpand(index);
                          },
                        ),
                        if (isSelected)
                          ...item.third.map((subItem) {
                            final int subIndex = item.third.indexOf(subItem);
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.dp),
                              child: ListTile(
                                leading: Container(
                                  width: 60.dp,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(10.dp),
                                      color: Colors.blueAccent
                                          .withOpacity(1 / (subIndex + 1))),
                                  child: Center(
                                    child: NetworkWebImage(
                                      subItem.userIcon ?? "",
                                      size: Size(40.dp, 40.dp),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(subItem.moneyActionName ?? ""),
                                trailing: Text(
                                  "\$${subItem.moneyAmount?.toStringAsFixed(2) ?? ""}",
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  );
                })
              ],
            ),
          );
        }),
      ),
    );
  }
}
