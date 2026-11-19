import 'package:material_ui/material_ui.dart';
import 'package:sirc/core/adaptive_pane/adaptive_two_pane.dart';

/// 根据窗口宽度切换来源区域 [primary] 与详情区域 [detail] 的通用布局。
///
/// 现已基于 [AdaptiveTwoPane] 实现，保持完全向后兼容。
class AdaptiveDetailLayout extends StatelessWidget {
  /// 创建来源与详情自适应布局；[key] 用于匹配并保留布局自身的状态。
  const AdaptiveDetailLayout({
    super.key,
    required this.hasDetail,
    required this.primary,
    required this.detail,
    this.primaryPaneKey = const ValueKey('duo-pane'),
    this.keepPrimaryMounted = false,
  });

  /// 是否存在要展示的详情，控制分栏、区域可见性与来源区域的 Hero。
  final bool hasDetail;

  /// 来源区域的任意 Widget，例如列表或个人信息页，必须显式传入。
  final Widget primary;

  /// 详情区域的任意 Widget，必须显式传入，也可包含 Navigator 子树。
  final Widget detail;

  /// 来源窗格 SizedBox 的标识，供测试或外部定位。
  final Key primaryPaneKey;

  /// 窄屏时是否继续挂载来源区域，默认为 false。
  final bool keepPrimaryMounted;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTwoPane(
      key: key,
      hasDetail: hasDetail,
      primary: primary,
      detail: detail,
      primaryPaneKey: primaryPaneKey,
      keepPrimaryMounted: keepPrimaryMounted,
      useWindowBreakpoint: true,
      minPrimaryWidth: 0,
    );
  }
}
