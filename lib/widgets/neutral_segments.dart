import 'package:flutter/material.dart';
import 'package:sirc/core/theme/app_colors.dart';

/// 中性分段切换器
///
/// 用于在多个分类或时间范围（如关注/热门/探索、周/月）之间切换。
/// [labels] 为各选项文本列表；[selected] 为当前选中索引；
/// [onSelected] 为切换回调；[keyPrefix] 为语义与测试键前缀；
/// [borderRadius] 为外部圆角，吸顶满幅时可传 [BorderRadius.zero]。
class NeutralSegments extends StatelessWidget {
  /// 创建中性分段切换器
  const NeutralSegments({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
    required this.keyPrefix,
    this.borderRadius,
  });

  /// 选项文本列表
  final List<String> labels;

  /// 当前选中索引
  final int selected;

  /// 选中回调
  final ValueChanged<int> onSelected;

  /// 键前缀
  final String keyPrefix;

  /// 外部圆角，默认为 11 像素
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.field(context),
      borderRadius: borderRadius ?? BorderRadius.circular(11),
    ),
    child: Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
              child: Semantics(
                selected: selected == i,
                child: TextButton(
                  key: ValueKey('$keyPrefix-$i'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.ink(context),
                    backgroundColor: selected == i
                        ? Theme.of(context).colorScheme.surface
                        : Colors.transparent,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: selected == i
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  onPressed: () => onSelected(i),
                  child: Text(labels[i], textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
