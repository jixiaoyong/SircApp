import 'package:material_ui/material_ui.dart';
import 'package:sirc/core/layout/app_layout.dart';

/// 根据窗口宽度切换来源区域 [primary] 与详情区域 [detail] 的通用布局。
///
/// 窗口逻辑宽度达到 840 时使用宽屏布局；有详情时两区域平分局部可用宽度
/// （扣除 1 逻辑像素分隔线），无详情时来源区域占满局部宽度。
/// 分栏宽度由父级约束决定，不用局部宽度重新判断窗口断点。
///
/// [detail] 可以是任意 Widget；在 GoRouter 的 ShellRoute 中，通常传入
/// Shell 内部的 Navigator 子树，而不一定是单个详情页面。
/// 跨断点移动详情子树时保留其状态，来源区域位于该详情 Navigator 之外。
class AdaptiveDetailLayout extends StatefulWidget {
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
  ///
  /// 宽屏为 false 时只显示来源区域；窄屏是否使用此值控制区域切换，
  /// 取决于 [keepPrimaryMounted]。它不要求 [detail] 是某种特定页面。
  final bool hasDetail;

  /// 来源区域的任意 Widget，例如列表或个人信息页，必须显式传入。
  ///
  /// 宽屏始终显示；窄屏仅在 [keepPrimaryMounted] 为 true 且无详情时显示。
  /// false 策略下的窄屏来源根页应由调用方放入 [detail] 子树中。
  final Widget primary;

  /// 详情区域的任意 Widget，必须显式传入，也可包含 Navigator 子树。
  ///
  /// 宽屏或保留来源挂载的窄屏中，无详情时使用 Offstage 隐藏而非销毁；
  /// 不保留来源挂载的窄屏中始终直接显示，包含来源根页时亦如此。
  final Widget detail;

  /// 来源窗格 SizedBox 的标识，供测试或外部定位，不改变详情子树的 key。
  ///
  /// 保留既有默认值；依赖特定窗格标识的调用方应显式传入原有 key。
  final Key primaryPaneKey;

  /// 窄屏时是否继续挂载来源区域，默认为 false；不影响宽屏策略。
  ///
  /// true 时始终挂载两个区域：有详情则 Offstage 隐藏来源区域，
  /// 无详情则 Offstage 隐藏详情区域，隐藏均不代表销毁。
  /// false 时窄屏直接返回 [detail]，不挂载 [primary]，且不根据
  /// [hasDetail] 隐藏详情；来源根页需由调用方在详情子树中提供。
  final bool keepPrimaryMounted;

  @override
  State<AdaptiveDetailLayout> createState() => _AdaptiveDetailLayoutState();
}

class _AdaptiveDetailLayoutState extends State<AdaptiveDetailLayout> {
  // 跨断点移动详情子树（也可以是 Navigator）时保留页面与输入状态。
  final _detailKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final hasDetail = widget.hasDetail;
    // 若详情含 Navigator，其 ModalBarrier 不应屏蔽来源窗格的语义。
    final detail = Semantics(
      container: true,
      explicitChildNodes: true,
      child: KeyedSubtree(key: _detailKey, child: widget.detail),
    );
    final isWide = AppLayout.isWideWindow(context);
    if (!isWide && !widget.keepPrimaryMounted) return detail;
    return LayoutBuilder(
      builder: (context, constraints) {
        final showPrimary = isWide || !hasDetail;
        final primaryWidth = !showPrimary
            ? 0.0
            : isWide && hasDetail
            ? (constraints.maxWidth - 1) / 2
            : constraints.maxWidth;
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
              width: isWide && hasDetail ? 1 : 0,
              child: const VerticalDivider(width: 1),
            ),
            Expanded(
              child: Offstage(offstage: !hasDetail, child: detail),
            ),
          ],
        );
      },
    );
  }
}
