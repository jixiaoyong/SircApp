import 'package:material_ui/material_ui.dart';
import 'package:sirc/core/layout/app_layout.dart';

import 'adaptive_navigation_adapter.dart';
import 'adaptive_pane_scope.dart';

/// 纯 Flutter 原生通用双栏自适应组件
///
/// 特性：
/// 1. 零依赖：纯基于 Flutter 官方 Widget，不依赖任何第三方状态管理或特定路由；
/// 2. 任意 Primary：主区域支持普通列表、表单，也支持完整的复合型页面（如 HomePage 仪表盘）；
/// 3. 动态无损拉伸：桌面窗口拖拽拉宽/拉窄时，通过持久 GlobalKey 保留详情子树输入框内容、焦点与滚动位置；
/// 4. 路由可插拔：通过 [AdaptiveNavigationAdapter] 自由对接原生 Navigator、GoRouter、GetX 等；
/// 5. 双维度语义：通过 [AdaptivePaneScope] 向子树同时暴露物理尺寸 [isWide] 与视觉分栏状态 [isDuo]；
/// 6. 统一架构：完整支持独立组件模式与全局路由器（如 GoRouter ShellRoute）双模式驱动。
class AdaptiveTwoPane extends StatefulWidget {
  const AdaptiveTwoPane({
    super.key,
    required this.primary,
    this.detail,
    this.hasDetail,
    this.breakpoint = 840.0,
    this.primaryFraction = 0.5,
    this.minPrimaryWidth = 320.0,
    this.maxPrimaryWidth,
    this.divider = const VerticalDivider(width: 1, thickness: 1),
    this.placeholder,
    this.primaryPaneKey = const ValueKey('duo-pane'),
    this.keepPrimaryMounted = true,
    this.useWindowBreakpoint = false,
    this.navigationAdapter = const DefaultNativeNavigationAdapter(),
    this.onDismissDetail,
  });

  /// 主区域（左侧主视图，例如列表、个人中心或复合首页）
  final Widget primary;

  /// 详情区域（右侧从视图；为空时在宽屏显示 [placeholder]，在窄屏只显示 [primary]）
  final Widget? detail;

  /// 外部显式指定的详情存在状态（若提供则优先于 `detail != null`，常用于路由统一调度）
  final bool? hasDetail;

  /// 自适应断点逻辑像素宽度，默认 840
  final double breakpoint;

  /// 宽屏下主区域所占比例，默认 0.5（左右各半）
  final double primaryFraction;

  /// 主区域在宽屏下的最小宽度保证
  final double minPrimaryWidth;

  /// 主区域在宽屏下的最大宽度限制（可选）
  final double? maxPrimaryWidth;

  /// 宽屏左右两栏之间的分割组件
  final Widget? divider;

  /// 宽屏下无详情时的占位视图
  final Widget? placeholder;

  /// 来源窗格 SizedBox 标识，供语义与测试定位
  final Key primaryPaneKey;

  /// 窄屏时是否在 DOM 中保留挂载来源窗格（Offstage 隐藏而不销毁）
  final bool keepPrimaryMounted;

  /// 是否以顶层窗口宽度作为断点依据（适配特定全屏测试与全局上下文）
  final bool useWindowBreakpoint;

  /// 窄屏全屏模式下的路由适配器（默认基于原生 Navigator）
  final AdaptiveNavigationAdapter navigationAdapter;

  /// 当在窄屏关闭详情或由全屏返回时触发，用于通知上层清空选中项
  final VoidCallback? onDismissDetail;

  @override
  State<AdaptiveTwoPane> createState() => _AdaptiveTwoPaneState();
}

class _AdaptiveTwoPaneState extends State<AdaptiveTwoPane> {
  // 持久化 GlobalKey 保证详情子树在宽屏窗格与窄屏全屏 Route 之间搬移时，
  // Element 树不被销毁重建，保留输入框文本、滚动位置与控制器状态。
  final GlobalKey _detailKey = GlobalKey(debugLabel: 'adaptive-two-pane-detail-subtree');

  bool _isRouteOpen = false;
  bool? _lastIsWide;

  @override
  Widget build(BuildContext context) {
    final hasDetail = widget.hasDetail ?? (widget.detail != null);

    if (widget.useWindowBreakpoint &&
        !AppLayout.isWideWindow(context) &&
        !widget.keepPrimaryMounted) {
      return AdaptivePaneScope(
        isWide: false,
        isDuo: false,
        mode: AdaptiveDisplayMode.singlePane,
        child: _buildDetailSubtree(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = widget.useWindowBreakpoint
            ? AppLayout.isWideWindow(context)
            : (constraints.maxWidth >= widget.breakpoint);
        final isDuo = isWide && hasDetail;

        final mode = isWide
            ? (hasDetail
                ? AdaptiveDisplayMode.dualPane
                : AdaptiveDisplayMode.dualPaneEmpty)
            : AdaptiveDisplayMode.singlePane;

        if (widget.hasDetail == null) {
          _scheduleBreakpointTransition(isWide, hasDetail);
        }

        return AdaptivePaneScope(
          isWide: isWide,
          isDuo: isDuo,
          mode: mode,
          child: isWide
              ? _buildWideLayout(constraints, isWide, hasDetail)
              : _buildNarrowLayout(constraints, isWide, hasDetail),
        );
      },
    );
  }

  void _scheduleBreakpointTransition(bool isWide, bool hasDetail) {
    if (_lastIsWide == null) {
      _lastIsWide = isWide;
      return;
    }

    if (_lastIsWide != isWide) {
      final wasWide = _lastIsWide!;
      _lastIsWide = isWide;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // 场景 1：窄屏拉伸为宽屏，若之前通过路由在窄屏全屏打开了详情页，安全退出全屏路由
        if (isWide && !wasWide && _isRouteOpen) {
          _isRouteOpen = false;
          widget.navigationAdapter.popDetail(context);
        }
        // 场景 2：宽屏拉窄为窄屏，若此前已有展开的详情，自动以全屏路由推入，保证详情不突兀丢失
        else if (!isWide && wasWide && hasDetail && !_isRouteOpen) {
          _pushDetailRoute();
        }
      });
    }
  }

  void _pushDetailRoute() {
    _isRouteOpen = true;
    widget.navigationAdapter.pushDetail(
      context,
      PopScope(
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) {
            _isRouteOpen = false;
            widget.onDismissDetail?.call();
          }
        },
        child: _buildDetailSubtree(),
      ),
    );
  }

  Widget _buildWideLayout(
    BoxConstraints constraints,
    bool isWide,
    bool hasDetail,
  ) {
    final showPrimary = isWide || !hasDetail;
    final showSplit = hasDetail || widget.placeholder != null;

    final double primaryWidth;
    if (showSplit) {
      final dividerWidth = widget.divider != null ? 1.0 : 0.0;
      double w = (constraints.maxWidth - dividerWidth) * widget.primaryFraction;
      if (widget.minPrimaryWidth > 0 && constraints.maxWidth >= widget.minPrimaryWidth * 2) {
        if (w < widget.minPrimaryWidth) w = widget.minPrimaryWidth;
      }
      if (widget.maxPrimaryWidth != null && w > widget.maxPrimaryWidth!) {
        w = widget.maxPrimaryWidth!;
      }
      primaryWidth = w;
    } else {
      primaryWidth = constraints.maxWidth;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Offstage(
          offstage: !showPrimary,
          child: SizedBox(
            key: widget.primaryPaneKey,
            width: showPrimary ? primaryWidth : constraints.maxWidth,
            child: HeroMode(enabled: !hasDetail, child: widget.primary),
          ),
        ),
        SizedBox(
          width: showSplit && widget.divider != null ? 1 : 0,
          child: widget.divider ?? const VerticalDivider(width: 1),
        ),
        Expanded(
          child: Offstage(
            offstage: !hasDetail && widget.placeholder == null,
            child: widget.detail != null
                ? _buildDetailSubtree()
                : (widget.placeholder ?? const SizedBox.shrink()),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
    BoxConstraints constraints,
    bool isWide,
    bool hasDetail,
  ) {
    if (widget.hasDetail != null) {
      if (!widget.keepPrimaryMounted) {
        return _buildDetailSubtree();
      }
      final showPrimary = !hasDetail;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Offstage(
            offstage: !showPrimary,
            child: SizedBox(
              key: widget.primaryPaneKey,
              width: constraints.maxWidth,
              child: HeroMode(enabled: !hasDetail, child: widget.primary),
            ),
          ),
          Expanded(
            child: Offstage(
              offstage: !hasDetail,
              child: _buildDetailSubtree(),
            ),
          ),
        ],
      );
    }

    // 默认独立组件模式：窄屏展示 primary，详情由路由推入
    return widget.primary;
  }

  Widget _buildDetailSubtree() {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: KeyedSubtree(
        key: _detailKey,
        child: widget.detail ?? const SizedBox.shrink(),
      ),
    );
  }
}
