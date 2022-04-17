import 'package:flutter_screenutil/flutter_screenutil.dart';

/*
* @description: extension class
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/17
*/
extension SizeExtension on num {
  /// 屏幕适配
  /// 控件大小适配
  /// 需要将设计稿宽度设置为375，然后导入本拓展，直接使用设计稿中的宽高值.dp即可
  /// import 'package:xiaojinka/utils/size_extension.dart';
  double get dp {
    return this.w;
  }

  /// 屏幕适配
  /// 字体大小适配
  /// 需要将设计稿宽度设置为375，然后导入本拓展，直接使用设计稿中的字体大小.sp即可
  /// import 'package:xiaojinka/utils/size_extension.dart';
  double get sp {
    return ScreenUtil().setSp(this);
  }
}
