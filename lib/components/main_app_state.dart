import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sirc/components/person/person_view.dart';
import 'package:sirc/components/wallet/wallet_view.dart';

import 'history/history_view.dart';
import 'home_page/home_page_view.dart';
import 'menu/menu_view.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class MainAppState {
  final currentIndex = 0.obs;

  Rx<List<BottomNavigationBarItem>> bnbItems = Rx([]);

  MainAppState() {
    bnbItems.value = generateBnbItems();
  }

  List<BottomNavigationBarItem> generateBnbItems() {
    return [
      BottomNavigationBarItem(
          icon: const Icon(
            Icons.home_outlined,
          ),
          label: 'Home'.tr),
      BottomNavigationBarItem(
          icon: const Icon(
            Icons.account_balance_wallet_outlined,
          ),
          label: 'Wallet'.tr),
      BottomNavigationBarItem(
          icon: const Icon(
            Icons.av_timer_outlined,
          ),
          label: 'History'.tr),
      BottomNavigationBarItem(
          icon: const Icon(
            Icons.person_outline_outlined,
          ),
          label: 'Person'.tr),
      BottomNavigationBarItem(
          icon: const Icon(Icons.menu_outlined), label: 'Menu'.tr),
    ];
  }

  List<Widget> homePages = [
    HomePage(),
    WalletPage(),
    HistoryPage(),
    PersonPage(),
    MenuPage(),
  ];
}
