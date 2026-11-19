import 'package:flutter/material.dart';

/// 随行中心极简优雅骨架屏：
/// 对齐 MasterNavView 结构（Hero 概览面板 + 3 个卡片列表项 + 2 个快捷速览格），
/// 背景色与 App 表面色 100% 融合，消除加载空白与闪屏感。
class PayloadSkeleton extends StatelessWidget {
  const PayloadSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF222426)
        : const Color(0xFFEBECEE);
    final highlightColor = isDark
        ? const Color(0xFF2D2F32)
        : const Color(0xFFF4F5F7);

    Widget block({
      required double height,
      double? width,
      double radius = 12,
      EdgeInsetsGeometry? margin,
    }) {
      return Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero 概览面板骨架
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: highlightColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    block(height: 14, width: 140, radius: 4),
                  ],
                ),
                const SizedBox(height: 14),
                block(height: 24, width: 120, radius: 6),
                const SizedBox(height: 10),
                block(height: 14, width: double.infinity, radius: 4),
                const SizedBox(height: 6),
                block(height: 14, width: 220, radius: 4),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: block(height: 38, radius: 8)),
                    const SizedBox(width: 8),
                    Expanded(child: block(height: 38, radius: 8)),
                    const SizedBox(width: 8),
                    Expanded(child: block(height: 38, radius: 8)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. 分组业务列表骨架
          block(height: 14, width: 90, radius: 4, margin: const EdgeInsets.only(bottom: 10)),
          Container(
            decoration: BoxDecoration(
              color: highlightColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _buildRowSkeleton(baseColor),
                Divider(height: 1, color: baseColor.withValues(alpha: 0.5)),
                _buildRowSkeleton(baseColor),
                Divider(height: 1, color: baseColor.withValues(alpha: 0.5)),
                _buildRowSkeleton(baseColor),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. 底部双格速览骨架
          block(height: 14, width: 80, radius: 4, margin: const EdgeInsets.only(bottom: 10)),
          Row(
            children: [
              Expanded(child: block(height: 78, radius: 12)),
              const SizedBox(width: 10),
              Expanded(child: block(height: 78, radius: 12)),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildRowSkeleton(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 15,
                  width: 130,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12,
                  width: 180,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
