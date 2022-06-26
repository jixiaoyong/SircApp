import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:toast/toast.dart' as ToastUtils;

/*
* @description: toast utils
* must call Toast.init(context) before use
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 6/26/2022
*/
class Toast {
  /// must call [Toast.init] before use
  static init(BuildContext context) {
    ToastUtils.ToastContext().init(context);
  }

  /// 显示toast
  /// warning: must call [Toast.init] before use
  /// @param msg: 显示的文字
  /// @param duration: 显示时间 单位秒
  /// @param gravity: 显示位置
  static show(String msg,
      {int duration = ToastUtils.Toast.lengthLong,
      ToastGravity gravity = ToastGravity.BOTTOM}) {
    ToastUtils.Toast.show(msg,
        duration: duration, gravity: ToastGravity.BOTTOM.index);
  }

  static showDefaultToast() {
    Toast.show("still working on it".tr);
  }
}

enum ToastGravity { BOTTOM, CENTER, TOP }
