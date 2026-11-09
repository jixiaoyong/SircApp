import 'package:flutter/widgets.dart';

/// 根据父级可用宽度居中限宽，且不改变子树的 MediaQuery。
///
/// [maxWidth] 包含 [padding]；横向无界时使用该宽度，纵向保持内容高度。
class ConstrainedContent extends StatelessWidget {
  const ConstrainedContent({
    super.key,
    required this.child,
    required this.maxWidth,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          width: double.infinity,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
