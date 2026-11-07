import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/title_text.dart';

/// 指纹登录开关状态 Provider
final fingerprintEnabledProvider = StateProvider<bool>((ref) => false);

/// 菜单列表页面，视觉与交互 100% 保持一致
class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  static const List<Color> _menuColors = [
    Color(0xFF7E57C2), // 深紫
    Color(0xFFFFA726), // 橙色
    Color(0xFF42A5F5), // 蓝色
    Color(0xFF26A69A), // 青绿
    Color(0xFFEF5350), // 红色
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听全局语言变更，实时刷新菜单项文本
    ref.watch(localeProvider);
    final isFingerprintOpen = ref.watch(fingerprintEnabledProvider);

    final menuItems = [
      (Icons.language_outlined, "Language".tr, AppRoutes.LANGUAGES),
      (Icons.lock_outlined, "Change Password".tr, AppRoutes.PASSWORD),
      (
        Icons.fingerprint_outlined,
        "Fingerprint Login".tr,
        AppRoutes.FINGERPRINT
      ),
      (Icons.credit_card_outlined, "Add Card".tr, AppRoutes.ADD_CARD),
      (Icons.logout, "Logout".tr, AppRoutes.LOGOUT),
    ];

    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10.dp),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TitleText(
                    text: "Settings".tr,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.NOTIFICATIONS);
                    },
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined),
                        Positioned(
                          top: 5.dp,
                          right: 1.dp,
                          child: Container(
                            height: 8.dp,
                            width: 8.dp,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10.dp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ...menuItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final bool isFingerprint = item.$3 == AppRoutes.FINGERPRINT;
                final Color iconBgColor =
                    _menuColors[index % _menuColors.length];

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10.dp),
                  padding: EdgeInsets.symmetric(vertical: 12.dp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.dp),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        offset: const Offset(0, 5),
                        blurRadius: 10.dp,
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(item.$2),
                    leading: Container(
                      height: 50.dp,
                      width: 50.dp,
                      decoration: BoxDecoration(
                        color: iconBgColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(50.dp),
                      ),
                      child: Icon(
                        item.$1,
                        color: Colors.white,
                      ),
                    ),
                    trailing: isFingerprint
                        ? CupertinoSwitch(
                            value: isFingerprintOpen,
                            onChanged: (v) {
                              ref
                                  .read(fingerprintEnabledProvider.notifier)
                                  .state = v;
                            },
                          )
                        : const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      if (isFingerprint) {
                        ref
                            .read(fingerprintEnabledProvider.notifier)
                            .update((val) => !val);
                      } else if (AppRoutes.LOGOUT == item.$3) {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: Text("Logout".tr),
                            content: Text("SureToLogout".tr),
                            actions: [
                              OutlinedButton(
                                child: Text("Cancel".tr),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                              ),
                              OutlinedButton(
                                child: Text(
                                  "Logout & Clean Data".tr,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.clear();
                                  if (dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
                                  }
                                  if (context.mounted) {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                      AppRoutes.INITIAL,
                                      (route) => false,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
                        Navigator.of(context).pushNamed(item.$3);
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
