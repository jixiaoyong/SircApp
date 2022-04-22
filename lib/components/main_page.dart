import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/components/main_app_state.dart';
import 'package:sirc/data/common_date.dart';

import 'main_app_logic.dart';
import 'slide_menu/slide_menu_view.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/17
*/
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MainAppLogic _appLogic = GetInstance().putOrFind(() => MainAppLogic());
  final MainAppState _appState = Get.find<MainAppLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var currentIndex = _appState.currentIndex.value;
      return SlideMenuPage(
        screenWidth: CommonData.realScreenWidth,
        child: Scaffold(
          body: IndexedStack(
            children: _appState.homePages,
            index: currentIndex,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: _appState.bnbItems.value,
            onTap: (index) {
              _appLogic.changeIndex(index);
            },
            currentIndex: currentIndex,
            selectedItemColor: Theme.of(context).primaryColorDark,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedItemColor: Theme.of(context).primaryColorLight,
          ),
        ),
      );
    });
  }
}
