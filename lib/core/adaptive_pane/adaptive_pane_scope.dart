import 'package:flutter/widgets.dart';

/// 布局展示模式
enum AdaptiveDisplayMode {
  /// 窄屏单栏模式 (容器宽度 < breakpoint)
  singlePane,

  /// 宽屏双栏模式且正在展示详情 (容器宽度 >= breakpoint 且 detail != null)
  dualPane,

  /// 宽屏双栏模式但当前无详情 (容器宽度 >= breakpoint 且 detail == null)
  dualPaneEmpty,
}

/// 供 [AdaptiveTwoPane] 及其子树查询的自适应环境与状态上下文
class AdaptivePaneScope extends InheritedWidget {
  const AdaptivePaneScope({
    super.key,
    required this.isWide,
    required this.isDuo,
    required this.mode,
    required super.child,
  });

  /// 物理/容器尺寸：当前可用宽度是否达到宽屏断点 (width >= breakpoint)
  final bool isWide;

  /// 视觉分栏状态：此时此刻是否正【同时并排呈现双栏】(isWide == true 且 detail != null)
  final bool isDuo;

  /// 详细呈现模式枚举
  final AdaptiveDisplayMode mode;

  static AdaptivePaneScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdaptivePaneScope>();

  static AdaptivePaneScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No AdaptivePaneScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AdaptivePaneScope oldWidget) =>
      isWide != oldWidget.isWide ||
      isDuo != oldWidget.isDuo ||
      mode != oldWidget.mode;
}
