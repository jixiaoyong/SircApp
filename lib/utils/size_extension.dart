/*
* @description: extension class
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/17
*/
extension SizeExtension on num {
  // 保留兼容现有初始化代码；逻辑像素不再使用屏幕缩放系数。
  static double dpScale = 1;

  /// Flutter 逻辑像素，不随窗口宽度缩放。
  /// 用于控件尺寸和间距；自适应宽度应由父级布局约束决定。
  double get dp => toDouble();

  /// 字体逻辑尺寸，不随窗口宽度缩放。
  /// 系统的无障碍字体缩放仍由 Text / MediaQuery 正常处理。
  double get sp => toDouble();
}
