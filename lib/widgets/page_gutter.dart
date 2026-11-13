import 'package:flutter/widgets.dart';

/// 页面水平留白包装组件，根据当前父容器的可用宽度为内容添加对称边距。
///
/// 留白按组件收到的局部宽度计算，不使用整个屏幕宽度：
/// - 宽度不超过 320 逻辑像素时，使用 [minGutter]（默认每侧 16）。
/// - 宽度从 320 到 560 逻辑像素时，在 [minGutter] 和 [maxGutter] 之间线性增加。
/// - 宽度达到或超过 560 逻辑像素时，使用 [maxGutter]（默认每侧 32）。
///
/// 默认不限制内容最大宽度。设置 [maxWidth] 后，外层内容框最大为该宽度，
/// 并在父容器中水平居中；[maxWidth] 包含两侧留白，窄父容器下内容框随之收缩。
/// 本组件只处理水平留白和可选限宽
class PageGutter extends StatelessWidget {
  const PageGutter({
    super.key,
    required this.child,
    this.maxWidth,
    this.minGutter = 16,
    this.maxGutter = 32,
  });

  final Widget child;
  final double? maxWidth;
  final double minGutter;
  final double maxGutter;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gutter = width.isFinite
            ? (minGutter +
                      (maxGutter - minGutter) *
                          ((width - 320) / (560 - 320)).clamp(0.0, 1.0))
                  .clamp(minGutter, maxGutter)
            : maxGutter;
        final frame = maxWidth == null
            ? width
            : width.isFinite
            ? width.clamp(0.0, maxWidth!)
            : maxWidth!;
        final contentWidth = (frame - gutter * 2).clamp(0.0, frame);
        return Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          child: SizedBox(
            width: frame,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gutter),
              child: SizedBox(width: contentWidth, child: child),
            ),
          ),
        );
      },
    );
  }
}
