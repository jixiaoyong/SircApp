import 'package:get/get.dart';
import 'package:sirc/widgets/line_graph.dart';

import 'history_state.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class HistoryLogic extends GetxController {
  final HistoryState state = HistoryState();

  final List<Pair<String, double>> dataChange = [
    Pair("Mon", 0.3),
    Pair("Tues", 0.5),
    Pair("Wed", 0.1),
    Pair("Thur", 0.6),
    Pair("Fri", 0.9),
    Pair("Satu", 0.2),
    Pair("Sun", 0.8),
  ].obs;

  void setSelectMonth(String e) {
    state.selectMonth.value = e;
  }
}
