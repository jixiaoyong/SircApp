import 'dart:convert';

import 'package:crypto/crypto.dart';

/*
* @description: 计算md5值
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/

class Md5Utils {
  static String generateMd5(String data) {
    var content = const Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return digest.toString();
  }
}
