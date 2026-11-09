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
      minTileHeight: 88.dp,
      minVerticalPadding: 12.dp,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.dp),
      horizontalTitleGap: 16.dp,
      minLeadingWidth: 40.dp,
      leading: Container(
        width: 40.dp,
        height: 40.dp,
        decoration: BoxDecoration(
          color: iconBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: Icon(icon, size: 24.dp, color: Colors.white)),
      ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      titleAlignment: ListTileTitleAlignment.center,
      trailing: trailing ?? const Icon(Icons.keyboard_arrow_right),
      onTap: onTap,
    );
  }
}
