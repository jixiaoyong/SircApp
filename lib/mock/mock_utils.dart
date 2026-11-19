import 'dart:math';

import 'package:material_ui/material_ui.dart';

/*
* @description: 认证与网络延迟模拟工具类
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class MockUtils {
  static final Random random = Random(DateTime.now().millisecondsSinceEpoch);

  /// 社交平台图标与主题色配置
  static final List<(IconData, Color)> socialList = [
    (Icons.facebook_outlined, Colors.blue),
    (Icons.fastfood_sharp, Colors.deepOrange),
    (Icons.favorite_outlined, Colors.lightBlueAccent),
  ];
}
