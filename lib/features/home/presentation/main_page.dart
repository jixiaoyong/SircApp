import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  const MainPage({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  static const _tabRoutes = [
    AppRoutes.MAIN,
    '/wallet',
    '/history',
    '/person',
    '/menu',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(navigationControllerProvider.notifier)
            .changeIndex(widget.initialIndex);
      });
    }
  }

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
    final currentIndex = ref.watch(
      navigationControllerProvider.select((s) => s.currentIndex),
    );

    // 监听全局语言变化以动态刷新底部导航栏标签
    ref.watch(localeProvider);

    final homePages = [
      const HomePage(),
      const WalletPage(),
      const HistoryPage(),
      const PersonPage(),
      const MenuPage(),
    ];

    return SlideMenuPage(
      screenWidth: CommonData.realScreenWidth,
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: homePages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              label: Languages.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: Languages.wallet,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.av_timer_outlined),
              label: Languages.history,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_outlined),
              label: Languages.person,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_outlined),
              label: Languages.menu,
            ),
          ],
          onTap: (index) {
            ref.read(navigationControllerProvider.notifier).changeIndex(index);
            if (kIsWeb && index < _tabRoutes.length) {
              SystemNavigator.routeInformationUpdated(
                uri: Uri.parse(_tabRoutes[index]),
              );
            }
          },
          currentIndex: currentIndex,
          selectedItemColor: Theme.of(context).primaryColorDark,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedItemColor: Theme.of(context).primaryColorLight,
        ),
      ),
    );
  }
}
