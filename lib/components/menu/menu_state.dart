import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sirc/widgets/line_graph.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class MenuState {
  final List<Pair<IconData, String>> menuItems = [
    Pair(Icons.language_outlined, "Language"),
    Pair(Icons.lock_outlined, "Change Password"),
    Pair(Icons.fingerprint_outlined, "Fingerprint Login"),
    Pair(Icons.credit_card_outlined, "Add Card"),
  ];
}
