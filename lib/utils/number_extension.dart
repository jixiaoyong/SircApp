/*
 * @Author: jixiaoyong
 * @Email: jixiaoyong1995@gmail.com
 * @Date: 22/04/30
 * @LastEditors: jixiaoyong
 * @LastEditTime: 22/04/30
 * @FilePath: /SircApp/lib/utils/number_extension.dart
 * @Description: 
 * 
 * Copyright (c) 2022 by jixiaoyong, All Rights Reserved. 
 */
extension NumberExt on num? {
  /// 保留两位小数
  String get toFormatedMoneyStr =>
      "${(this ?? 0) >= 0 ? "+" : "-"} \$${(this ?? 0).abs().toStringAsFixed(2)}";
}
