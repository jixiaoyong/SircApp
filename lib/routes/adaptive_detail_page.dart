import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../core/layout/app_layout.dart';

/// 按窗口宽度创建详情 Page：宽屏无转场，窄屏使用 Material 平台转场。
///
/// 在 pageBuilder 中传入稳定的路由 [key] 与业务 [child]；本入口不处理 URL、
/// 来源返回或左右分栏。同 key 跨断点更新复用统一 Route，并读取最新 Page 配置；
/// 配合布局层的 GlobalKey 保留详情子树，不保证 pop、替换或 key 改变后仍保留状态。
Page<void> createAdaptiveDetailPage({
  required BuildContext context,
  required LocalKey key,
  required Widget child,
}) => AppLayout.isWideWindow(context)
    ? _AdaptiveDetailNoTransitionPage(key: key, child: child)
    : _AdaptiveDetailMaterialPage(key: key, child: child);

/// 窄屏详情的 Page 配置，与宽屏 Page 共用可更新的 Route。
///
/// 同 key 跨类型更新可复用 Route，配合布局的 GlobalKey 保留跨断点子树状态；
/// 不保证页面被弹出、替换或 key 改变后仍保留状态。
class _AdaptiveDetailMaterialPage extends MaterialPage<void> {
  const _AdaptiveDetailMaterialPage({required super.key, required super.child});

  /// 允许同 key 的两种自适应 Page 互相更新，避免仅因类型变化重建 Route。
  @override
  bool canUpdate(Page<dynamic> other) =>
      (other is _AdaptiveDetailMaterialPage ||
          other is _AdaptiveDetailNoTransitionPage) &&
      key == other.key;

  /// 创建共用 Route，使后续切换 Page 类型时仍可更新同一个路由实例。
  @override
  Route<void> createRoute(BuildContext context) =>
      _adaptiveDetailPageRoute(this);
}

/// 宽屏详情的无转场 Page 配置，与窄屏 Page 共用 Route 更新机制。
class _AdaptiveDetailNoTransitionPage extends NoTransitionPage<void> {
  const _AdaptiveDetailNoTransitionPage({
    required super.key,
    required super.child,
  });

  /// 允许同 key 的两种自适应 Page 互相更新，支持从宽屏切回窄屏。
  @override
  bool canUpdate(Page<dynamic> other) =>
      (other is _AdaptiveDetailMaterialPage ||
          other is _AdaptiveDetailNoTransitionPage) &&
      key == other.key;

  /// 创建共用 Route，使后续切换 Page 类型时仍可更新同一个路由实例。
  @override
  Route<void> createRoute(BuildContext context) =>
      _adaptiveDetailPageRoute(this);
}

/// 为两种详情 Page 创建统一 Route，并在构建时读取其最新 Page 配置。
///
/// Navigator 复用 Route 时会更新 settings；不能捕获初始 [page] 的 child，
/// 否则跨断点更新后仍可能构建旧页面内容。
Route<void> _adaptiveDetailPageRoute(Page<void> page) {
  late final MaterialPageRoute<void> route;
  route = _AdaptiveDetailPageRoute(
    settings: page,
    builder: (context) {
      final settings = route.settings;
      return settings is MaterialPage<void>
          ? settings.child
          : (settings as NoTransitionPage<void>).child;
    },
  );
  return route;
}

/// 根据当前 settings 切换详情转场，不负责左右分栏或来源区域的挂载。
class _AdaptiveDetailPageRoute extends MaterialPageRoute<void> {
  _AdaptiveDetailPageRoute({required super.settings, required super.builder});

  /// 宽屏入场时长为零；窄屏沿用 MaterialPageRoute 的默认时长。
  @override
  Duration get transitionDuration => settings is NoTransitionPage<void>
      ? Duration.zero
      : super.transitionDuration;

  /// 退场采用与当前入场相同的时长策略。
  @override
  Duration get reverseTransitionDuration => transitionDuration;

  /// 宽屏直接返回内容；窄屏委托 Material 的平台转场实现。
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => settings is NoTransitionPage<void>
      ? child
      : super.buildTransitions(context, animation, secondaryAnimation, child);
}
