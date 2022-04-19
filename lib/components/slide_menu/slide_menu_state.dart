import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sirc/widgets/line_graph.dart';

/*
* @description: Slide Menu
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class SlideMenuState {
  final List<Pair<IconData, String>> slideMenuList = [
    Pair(Icons.home_outlined, "Home"),
    Pair(Icons.person_outline, "Profile"),
    Pair(Icons.history_outlined, "History"),
    Pair(Icons.notifications_outlined, "Notifications"),
    Pair(Icons.settings, "Settings"),
    Pair(Icons.help_outline_outlined, "Help & Support"),
  ];
}
