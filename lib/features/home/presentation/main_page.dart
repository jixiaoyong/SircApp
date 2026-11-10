import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/data/common_data.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/features/home/presentation/home_page.dart';
import 'package:sirc/features/home/presentation/menu_page.dart';
import 'package:sirc/features/home/presentation/person_page.dart';
import 'package:sirc/features/home/presentation/slide_menu_page.dart';
import 'package:sirc/features/wallet/presentation/history_page.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/toast.dart';

/// 应用主框架页面，集成侧滑抽屉、IndexedStack 多页面与底部导航栏
class MainPage extends ConsumerStatefulWidget {
  final int initialIndex;
  final String? initialMenuDetail;

  const MainPage({super.key, this.initialIndex = 0, this.initialMenuDetail});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  static const _tabRoutes = [
    AppRoutes.MAIN,
    '/wallet',
    '/history',
    '/person',
    AppRoutes.MENU,
  ];

  @override
  void didUpdateWidget(covariant MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      ref
          .read(navigationControllerProvider.notifier)
          .changeIndex(widget.initialIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    Toast.init(context);

    // 监听当前选中的 Tab 索引
    ref.watch(navigationControllerProvider.select((s) => s.currentIndex));
    // 路由参数直接决定当前 Tab，避免 Provider 缓存旧索引造成 Person 闪帧。
    final uriPath = GoRouterState.of(context).uri.path;
    final uriTabIndex = switch (uriPath) {
      AppRoutes.MENU ||
      AppRoutes.LANGUAGES ||
      AppRoutes.NOTIFICATIONS ||
      AppRoutes.PASSWORD ||
      AppRoutes.ADD_CARD => 4,
      '/wallet' => 1,
      '/history' => 2,
      '/person' => 3,
      _ => widget.initialIndex,
    };
    final currentIndex = uriTabIndex;
    final menuDetail =
        widget.initialMenuDetail ??
        switch (uriPath) {
          AppRoutes.LANGUAGES => AppRoutes.LANGUAGES,
          AppRoutes.NOTIFICATIONS => AppRoutes.NOTIFICATIONS,
          AppRoutes.PASSWORD => AppRoutes.PASSWORD,
          AppRoutes.ADD_CARD => AppRoutes.ADD_CARD,
          _ => null,
        };

    // 监听全局语言变化以动态刷新底部导航栏标签
    ref.watch(localeProvider);

    final isWideLayout = MediaQuery.sizeOf(context).width >= 840;
    final homePages = [
      const HomePage(),
      const WalletPage(),
      const HistoryPage(),
      const PersonPage(),
      MenuPage(
        wideDetail: isWideLayout && currentIndex == 4 ? menuDetail : null,
        onWideDetailSelected: (location) {
          if (location == null) {
            context.go(AppRoutes.MENU);
          } else {
            context.go('${AppRoutes.MENU}$location');
          }
        },
      ),
    ];
    final navigationItems = [
      (Icons.home_outlined, Languages.home.title),
      (Icons.account_balance_wallet_outlined, Languages.wallet.title),
      (Icons.av_timer_outlined, Languages.history),
      (Icons.person_outline_outlined, Languages.person),
      (Icons.menu_outlined, Languages.menu),
    ];

    void selectTab(int index) {
      if (index < _tabRoutes.length) {
        context.go(_tabRoutes[index]);
      }
    }

    final navigation = isWideLayout
        ? NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: selectTab,
            labelType: NavigationRailLabelType.all,
            destinations: navigationItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.$1),
                    label: Text(item.$2),
                  ),
                )
                .toList(),
          )
        : null;

    return SlideMenuPage(
      screenWidth: CommonData.realScreenWidth,
      child: Scaffold(
        body: Row(
          children: [
            if (navigation != null) navigation,
            Expanded(
              child: IndexedStack(index: currentIndex, children: homePages),
            ),
          ],
        ),
        bottomNavigationBar: isWideLayout
            ? null
            : BottomNavigationBar(
                items: navigationItems
                    .map(
                      (item) => BottomNavigationBarItem(
                        icon: Icon(item.$1),
                        label: item.$2,
                      ),
                    )
                    .toList(),
                onTap: selectTab,
                currentIndex: currentIndex,
                selectedItemColor: Theme.of(context).primaryColorDark,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                unselectedItemColor: Theme.of(context).primaryColorLight,
              ),
      ),
    );
  }
}
