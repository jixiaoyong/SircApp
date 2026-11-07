import 'package:flutter/material.dart';
import '../core/localization/app_locale.dart';
import '../core/router/nav_keys.dart';

/*
* @description: toast utils
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 6/26/2022
*/
class Toast {
  static const int lengthShort = 1;
  static const int lengthLong = 2;

  /// 保留方法签名以向下兼容
  static init(BuildContext context) {}

  /// 显示toast
  /// @param msg: 显示的文字
  /// @param duration: 显示时间 单位秒
  /// @param gravity: 显示位置
  static show(
    String msg, {
    int duration = lengthLong,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xCC000000),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          duration: Duration(seconds: duration),
        ),
      );
    }
  }

  static showDefaultToast() {
    Toast.show("still working on it".tr);
  }
}

enum ToastGravity { BOTTOM, CENTER, TOP }
