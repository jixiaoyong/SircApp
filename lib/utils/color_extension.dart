import 'package:flutter/material.dart';

/*
* @description: 和颜色有关的拓展
*  使用前需要先导入本类：
* import 'package:xiaojinka/utils/color_extension.dart';
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/17
*/
extension ColorExtension on String {
  // parse #aarrggbb to 0xaarrggbb
  //demo:color: "#cc4A4C4D".hexToColor,
  Color get hexToColor =>
      Color(int.parse(this.substring(1), radix: 16) + 0xFF000000);
}
