import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/data/common_data.dart';
import 'package:sirc/features/home/presentation/slide_menu_page.dart';
import 'package:sirc/utils/toast.dart';

/// 单一主框架；分支页面及返回栈由 StatefulNavigationShell 持有。
class MainPage extends ConsumerWidget {
  const MainPage({
    super.key,
    required this.navigationShell,
    required this.showBottomNavigation,
  });

  final StatefulNavigationShell navigationShell;
  final bool showBottomNavigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Toast.init(context);
    ref.watch(localeProvider);
    final currentIndex = navigationShell.currentIndex;
    final isWideLayout = MediaQuery.sizeOf(context).width >= 840;
    final navigationItems = [
      (Icons.home_outlined, Languages.home.title),
      (Icons.account_balance_wallet_outlined, Languages.wallet.title),
      (Icons.av_timer_outlined, Languages.history),
      (Icons.person_outline_outlined, Languages.person),
      (Icons.menu_outlined, Languages.menu),
    ];

    void selectTab(int index) => navigationShell.goBranch(index);

    return SlideMenuPage(
      screenWidth: CommonData.realScreenWidth,
      onBranchSelected: selectTab,
      child: Scaffold(
        body: Row(
          children: [
            if (isWideLayout)
              NavigationRail(
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
              ),
            // 各分支 Navigator 自带独立 HeroController；indexedStack
            // 负责 Offstage/TickerMode，无第二层五页 IndexedStack。
            Expanded(
              child: Semantics(
                container: true,
                explicitChildNodes: true,
                child: navigationShell,
              ),
            ),
          ],
        ),
        bottomNavigationBar: isWideLayout || !showBottomNavigation
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
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedItemColor: Theme.of(context).colorScheme.onSurface,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                unselectedItemColor: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
                elevation: 0,
              ),
      ),
    );
  }
}
