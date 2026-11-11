import 'package:flutter/material.dart';
import 'package:sirc/utils/size_extension.dart';

/// 资料与设置共用的行内容；由外层 Material 提供卡片和裁剪。
class SettingsItemTile extends StatelessWidget {
  const SettingsItemTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconBackgroundColor = Colors.grey,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final Color iconBackgroundColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.standard,
      minTileHeight: 64,
      minVerticalPadding: 14,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.dp),
      horizontalTitleGap: 16.dp,
      minLeadingWidth: 36.dp,
      leading: Container(
        width: 36.dp,
        height: 36.dp,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20.dp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
      titleAlignment: ListTileTitleAlignment.center,
      trailing: trailing ?? const Icon(Icons.keyboard_arrow_right),
      onTap: onTap,
    );
  }
}
