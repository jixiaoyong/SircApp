import 'package:flutter/widgets.dart';

/// 路由适配接口：定义组件在窄屏全屏模式下的页面压栈与出栈策略
///
/// 完全解耦具体路由框架（无论是原生 Navigator、GoRouter、GetX、AutoRoute 均可实现本契约）
abstract class AdaptiveNavigationAdapter {
  const AdaptiveNavigationAdapter();

  /// 在窄屏下打开全屏详情页
  void pushDetail(BuildContext context, Widget detailWidget);

  /// 关闭详情页返回主页面
  void popDetail(BuildContext context);
}

/// 默认的原生 Flutter 路由适配器（开箱即用，无需任何第三方路由依赖）
class DefaultNativeNavigationAdapter extends AdaptiveNavigationAdapter {
  const DefaultNativeNavigationAdapter({
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  final Duration transitionDuration;

  @override
  void pushDetail(BuildContext context, Widget detailWidget) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: transitionDuration,
        pageBuilder: (context, animation, secondaryAnimation) => detailWidget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void popDetail(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }
}

/// 委托型路由适配器：允许外部传入纯函数回调（可一行代码对接到 GoRouter、GetX 等）
class DelegateNavigationAdapter extends AdaptiveNavigationAdapter {
  const DelegateNavigationAdapter({
    required this.onPush,
    required this.onPop,
  });

  final void Function(BuildContext context, Widget detailWidget) onPush;
  final void Function(BuildContext context) onPop;

  @override
  void pushDetail(BuildContext context, Widget detailWidget) =>
      onPush(context, detailWidget);

  @override
  void popDetail(BuildContext context) => onPop(context);
}
