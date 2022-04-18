import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/components/wallet/wallet_view.dart';
import 'package:sirc/utils/logger.dart';

import 'history/history_view.dart';
import 'home_page/home_page_view.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/17
*/
class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _currentIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var index = _currentIndex.value;
      LogUtils.d("the page index: $index");
      return Scaffold(
        body: IndexedStack(
          children: homePages,
          index: index,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: BnbItems,
          onTap: (index) {
            _currentIndex.value = index;
          },
          currentIndex: _currentIndex.value,
          selectedItemColor: Theme.of(context).primaryColorDark,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedItemColor: Theme.of(context).primaryColorLight,
        ),
      );
    });
  }

  List<Widget> homePages = [
    HomePage(),
    WalletPage(),
    HistoryPage(),
    HomePage(),
    HomePage(),
  ];

  List<BottomNavigationBarItem> BnbItems = const [
    BottomNavigationBarItem(
        icon: Icon(
          Icons.home_outlined,
        ),
        label: 'Home'),
    BottomNavigationBarItem(
        icon: Icon(
          Icons.account_balance_wallet_outlined,
        ),
        label: 'Wallet'),
    BottomNavigationBarItem(
        icon: Icon(
          Icons.av_timer_outlined,
        ),
        label: 'History'),
    BottomNavigationBarItem(
        icon: Icon(
          Icons.person_outline_outlined,
        ),
        label: 'Person'),
    BottomNavigationBarItem(icon: Icon(Icons.menu_outlined), label: 'Menu'),
  ];
}
