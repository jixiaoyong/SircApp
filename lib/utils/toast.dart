import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
* @description: toast utils
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 6/26/2022
*/
class Toast {
  static const int lengthShort = 1;
  static const int lengthLong = 2;

  /// must call [Toast.init] before use (保留方法签名以向下兼容)
  static init(BuildContext context) {
    // GetX snackbar 无需依赖 BuildContext
  }

  /// 显示toast
  /// @param msg: 显示的文字
  /// @param duration: 显示时间 单位秒
  /// @param gravity: 显示位置
  static show(
    String msg, {
    int duration = lengthLong,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    SnackPosition snackPosition;
    switch (gravity) {
      case ToastGravity.TOP:
        snackPosition = SnackPosition.TOP;
        break;
      case ToastGravity.BOTTOM:
      case ToastGravity.CENTER:
      default:
        snackPosition = SnackPosition.BOTTOM;
        break;
    }

    Get.rawSnackbar(
      messageText: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      snackPosition: snackPosition,
      backgroundColor: const Color(0xCC000000),
      borderRadius: 20,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      duration: Duration(seconds: duration),
      animationDuration: const Duration(milliseconds: 250),
      isDismissible: true,
    );
  }

  static showDefaultToast() {
    Toast.show("still working on it".tr);
  }
}

enum ToastGravity { BOTTOM, CENTER, TOP }
