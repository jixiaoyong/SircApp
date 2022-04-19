import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/mock/mock_utils.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/title_text.dart';

import 'menu_logic.dart';

/*
* @description: Menu
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class MenuPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(MenuLogic());
    final state = Get.find<MenuLogic>().state;

    return SingleChildScrollView(
        child: SafeArea(
            child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10.dp),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TitleText(
                text: "Settings",
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.NOTIFICATIONS);
                },
                child: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined),
                    Positioned(
                      top: 5.dp,
                      right: 1.dp,
                      child: Container(
                        height: 8.dp,
                        width: 8.dp,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10.dp)),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          ...state.menuItems.map((item) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 10.dp),
              padding: EdgeInsets.symmetric(vertical: 12.dp),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.dp),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: const Offset(0, 5),
                        blurRadius: 10.dp)
                  ]),
              child: ListTile(
                title: Text(item.second),
                leading: Container(
                    height: 50.dp,
                    width: 50.dp,
                    decoration: BoxDecoration(
                        color: Colors.accents.elementAt(
                            MockUtils.random.nextInt(Colors.accents.length))
                          ..withOpacity(0.5),
                        borderRadius: BorderRadius.circular(50.dp)),
                    child: Icon(
                      item.first,
                      color: Colors.white,
                    )),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Get.toNamed(item.third);
                },
              ),
            );
          }),
        ],
      ),
    )));
  }
}
