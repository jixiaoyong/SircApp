import 'package:flutter/cupertino.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/core/layout/app_layout.dart';
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

enum _MenuAction { language, password, fingerprint, logout }

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
    final isWide = AppLayout.isWideWindow(context);
    final colors = Theme.of(context).colorScheme;

    final menuItems = [
      (Icons.language_outlined, Languages.language, _MenuAction.language),
      (Icons.lock_outlined, Languages.changePassword, _MenuAction.password),
      (
        Icons.fingerprint_outlined,
        Languages.fingerprintLogin,
        _MenuAction.fingerprint,
      ),
      (Icons.logout, Languages.logout, _MenuAction.logout),
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
                    Flexible(child: TitleText(text: Languages.settings.title)),
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
                Material(
                  key: const ValueKey('menu-settings-group'),
                  color: colors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: colors.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      SettingsItemTile(
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
                      ...menuItems.expand((item) {
                        final bool isFingerprint =
                            item.$3 == _MenuAction.fingerprint;
                        return [
                          Divider(
                            height: 1,
                            thickness: 1,
                            indent: 20,
                            endIndent: 20,
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          SettingsItemTile(
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
                                                fingerprintEnabledProvider
                                                    .notifier,
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
                              } else if (_MenuAction.logout == item.$3) {
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
                                _openDetail(
                                  context,
                                  item.$3 == _MenuAction.language
                                      ? AppRoutes.MENU_LANGUAGES
                                      : AppRoutes.MENU_PASSWORD,
                                  isWide,
                                );
                              }
                            },
                          ),
                        ];
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return list;
  }
}
