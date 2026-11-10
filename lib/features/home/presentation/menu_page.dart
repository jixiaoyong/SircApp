import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/auth/data/auth_repository.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/widgets/settings_item_tile.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/title_text.dart';

/// 指纹登录开关状态 Notifier (全面适配 Riverpod 3.x)
class FingerprintEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  @override
  set state(bool value) => super.state = value;
  void update(bool Function(bool state) cb) => state = cb(state);
}

/// 指纹登录开关状态 Provider
final fingerprintEnabledProvider =
    NotifierProvider<FingerprintEnabledNotifier, bool>(
      FingerprintEnabledNotifier.new,
    );

/// 菜单列表页面，视觉与交互 100% 保持一致
class MenuPage extends ConsumerWidget {
  final bool listOnly;

  const MenuPage({super.key, this.listOnly = false});

  static const List<Color> _menuColors = [
    Color(0xFF7E57C2), // 深紫
    Color(0xFFFFA726), // 橙色
    Color(0xFF42A5F5), // 蓝色
    Color(0xFF26A69A), // 青绿
    Color(0xFFEF5350), // 红色
  ];

  void _openDetail(BuildContext context, String location, bool isWide) {
    if (isWide) {
      final router = GoRouter.of(context);
      final current = router.routeInformationProvider.value.uri.path;
      if (current == location) return;
      if (current.startsWith('${AppRoutes.MENU}/')) {
        Router.neglect(context, () => router.replace<void>(location));
        return;
      }
    }
    context.push(location);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听全局语言变更，实时刷新菜单项文本
    ref.watch(localeProvider);
    final isFingerprintOpen = ref.watch(fingerprintEnabledProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 840;

    final menuItems = [
      (Icons.language_outlined, Languages.language, AppRoutes.MENU_LANGUAGES),
      (Icons.lock_outlined, Languages.changePassword, AppRoutes.MENU_PASSWORD),
      (
        Icons.fingerprint_outlined,
        Languages.fingerprintLogin,
        AppRoutes.FINGERPRINT,
      ),
      (Icons.credit_card_outlined, Languages.addCard, AppRoutes.ADD_CARD),
      (Icons.logout, Languages.logout, AppRoutes.LOGOUT),
    ];

    final list = SingleChildScrollView(
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10.dp),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TitleText(text: Languages.settings.title),
                  GestureDetector(
                    onTap: () {
                      _openDetail(
                        context,
                        AppRoutes.MENU_NOTIFICATIONS,
                        isWide,
                      );
                    },
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Stack(
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: Icon(Icons.notifications_outlined),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.dp),
                    elevation: 5,
                    shadowColor: Colors.grey.withValues(alpha: 0.5),
                    clipBehavior: Clip.antiAlias,
                    child: SettingsItemTile(
                      icon: item.$1,
                      title: item.$2,
                      iconBackgroundColor: iconBgColor.withValues(alpha: 0.5),
                      trailing: isFingerprint
                          ? CupertinoSwitch(
                              value: isFingerprintOpen,
                              onChanged: (v) {
                                ref
                                        .read(
                                          fingerprintEnabledProvider.notifier,
                                        )
                                        .state =
                                    v;
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
                              title: Text(Languages.logout),
                              content: Text(Languages.sureToLogout),
                              actions: [
                                OutlinedButton(
                                  child: Text(Languages.cancel),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                ),
                                OutlinedButton(
                                  child: Text(
                                    Languages.logoutAndCleanData,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.clear();
                                    if (dialogContext.mounted) {
                                      Navigator.of(dialogContext).pop();
                                    }
                                    // 清空持久化后仍需发布登出通知，由统一守卫回到登录页。
                                    await ref
                                        .read(authRepositoryProvider)
                                        .logout();
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          _openDetail(context, item.$3, isWide);
                        }
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
    return list;
  }
}

/// Menu stays outside the detail Navigator, including when its pane is closed.
class MenuDetailLayout extends StatefulWidget {
  const MenuDetailLayout({
    super.key,
    required this.hasDetail,
    required this.child,
  });

  final bool hasDetail;
  final Widget child;

  @override
  State<MenuDetailLayout> createState() => _MenuDetailLayoutState();
}

class _MenuDetailLayoutState extends State<MenuDetailLayout> {
  // 跨断点移动详情 Navigator 时保留其页面与输入状态。
  final _detailKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final hasDetail = widget.hasDetail;
    final detail = KeyedSubtree(key: _detailKey, child: widget.child);
    if (MediaQuery.sizeOf(context).width < 840) return detail;
    return LayoutBuilder(
      builder: (context, constraints) {
        final paneWidth = hasDetail
            ? (constraints.maxWidth - 1) / 2
            : constraints.maxWidth;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              key: const ValueKey('menu-pane'),
              width: paneWidth,
              child: const MenuPage(listOnly: true),
            ),
            SizedBox(
              width: hasDetail ? 1 : 0,
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
