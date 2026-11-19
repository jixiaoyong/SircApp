import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/layout/app_layout.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/presentation/slide_menu_page.dart';
import 'package:sirc/features/payload/payload_page.dart';
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
    final isWideLayout = AppLayout.isWideWindow(context);
    final navigationItems = [
      (Icons.home_outlined, Languages.home.title),
      (Icons.account_balance_wallet_outlined, Languages.wallet.title),
      (Icons.av_timer_outlined, Languages.history),
      (Icons.person_outline_outlined, Languages.person),
      (Icons.menu_outlined, Languages.menu),
      (Icons.web_outlined, Languages.home.payloadTitle),
    ];

    void selectTab(int index) => navigationShell.goBranch(index);

    return SlideMenuPage(
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
            // 各分支 Navigator 自带独立 HeroController；
            // 采用对齐公考项目的架构：将 Web Tab 保持常驻且静默预载，切到时瞬间可见。
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Semantics(
                    container: true,
                    explicitChildNodes: true,
                    child: navigationShell,
                  ),
                  // 当未点击到网页 Tab 时，在后台通过 Offstage 保持常驻并提早渲染
                  if (currentIndex != 5)
                    const Offstage(
                      offstage: true,
                      child: PayloadPage(),
                    ),
                ],
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
