import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/features/settings/controllers/settings_controller.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/auth/data/auth_repository.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/widgets/settings_item_tile.dart';
import 'package:sirc/widgets/title_text.dart';
import 'package:sirc/widgets/page_gutter.dart';

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

/// 柔灰菜单列表；保留详情导航、指纹单次切换与登出确认语义。
class MenuPage extends ConsumerWidget {
  final bool listOnly;

  const MenuPage({super.key, this.listOnly = false});

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

  String _themeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.light => Languages.settings.themeLight,
    ThemeMode.dark => Languages.settings.themeDark,
    ThemeMode.system => Languages.settings.themeSystem,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听全局语言变更，实时刷新菜单项文本
    ref.watch(localeProvider);
    final isFingerprintOpen = ref.watch(fingerprintEnabledProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 840;
    final colors = Theme.of(context).colorScheme;

    final menuItems = [
      (Icons.language_outlined, Languages.language, AppRoutes.MENU_LANGUAGES),
      (Icons.lock_outlined, Languages.changePassword, AppRoutes.MENU_PASSWORD),
      (
        Icons.fingerprint_outlined,
        Languages.fingerprintLogin,
        AppRoutes.FINGERPRINT,
      ),
      (Icons.logout, Languages.logout, AppRoutes.LOGOUT),
    ];

    final list = SingleChildScrollView(
      child: SafeArea(
        child: PageGutter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
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
                                decoration: BoxDecoration(
                                  color: colors.error,
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
                Container(
                  margin: EdgeInsets.zero,
                  child: Material(
                    color: colors.surface,
                    shape: Border(
                      bottom: BorderSide(color: colors.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SettingsItemTile(
                      key: const ValueKey('appearance-setting'),
                      icon: Icons.brightness_6_outlined,
                      title: Languages.settings.appearance,
                      subtitle: _themeLabel(ref.watch(themeModeProvider)),
                      onTap: () => _openDetail(
                        context,
                        AppRoutes.MENU_APPEARANCE,
                        isWide,
                      ),
                    ),
                  ),
                ),
                ...menuItems.map((item) {
                  final bool isFingerprint = item.$3 == AppRoutes.FINGERPRINT;

                  return Container(
                    margin: EdgeInsets.zero,
                    child: Material(
                      color: colors.surface,
                      shape: Border(
                        bottom: BorderSide(color: colors.outlineVariant),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SettingsItemTile(
                        icon: item.$1,
                        title: item.$2,
                        iconBackgroundColor: colors.surfaceContainerHighest,
                        trailing: isFingerprint
                            ? CupertinoSwitch(
                                value: isFingerprintOpen,
                                activeTrackColor: colors.primary,
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
                                      style: TextStyle(color: colors.error),
                                    ),
                                    onPressed: () async {
                                      await ref
                                          .read(storageServiceProvider)
                                          .clearUserData();
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
    this.list = const MenuPage(listOnly: true),
    this.paneKey = const ValueKey('menu-pane'),
    this.keepListMounted = false,
  });

  final bool hasDetail;
  final Widget child;
  final Widget list;
  final Key paneKey;
  final bool keepListMounted;

  @override
  State<MenuDetailLayout> createState() => _MenuDetailLayoutState();
}

class _MenuDetailLayoutState extends State<MenuDetailLayout> {
  // 跨断点移动详情 Navigator 时保留其页面与输入状态。
  final _detailKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final hasDetail = widget.hasDetail;
    // Navigator 的 ModalBarrier 只应屏蔽详情内部，不能吞掉来源窗格语义。
    final detail = Semantics(
      container: true,
      explicitChildNodes: true,
      child: KeyedSubtree(key: _detailKey, child: widget.child),
    );
    final isWide = MediaQuery.sizeOf(context).width >= 840;
    if (!isWide && !widget.keepListMounted) return detail;
    return LayoutBuilder(
      builder: (context, constraints) {
        final showList = isWide || !hasDetail;
        final paneWidth = !showList
            ? 0.0
            : isWide && hasDetail
            ? (constraints.maxWidth - 1) / 2
            : constraints.maxWidth;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Offstage(
              offstage: !showList,
              child: SizedBox(
                key: widget.paneKey,
                width: showList ? paneWidth : constraints.maxWidth,
                child: HeroMode(enabled: !hasDetail, child: widget.list),
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
