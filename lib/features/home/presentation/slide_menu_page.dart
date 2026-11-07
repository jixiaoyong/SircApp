import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/color_extension.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/utils/toast.dart';
import 'package:sirc/widgets/network_web_image.dart';

/// 侧滑抽屉 Widget，支持平移缩放视觉与抽屉动画
class SlideMenuPage extends ConsumerStatefulWidget {
  final Widget child;
  final double? screenWidth;

  const SlideMenuPage({super.key, required this.child, this.screenWidth});

  @override
  ConsumerState<SlideMenuPage> createState() => _SlideMenuPageState();
}

class _SlideMenuPageState extends ConsumerState<SlideMenuPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _percentage = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _controller.addListener(() {
      setState(() {
        _percentage = _controller.value;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ref.read(navigationControllerProvider.notifier).setDrawerOpen(true);
      } else if (status == AnimationStatus.dismissed) {
        ref.read(navigationControllerProvider.notifier).setDrawerOpen(false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleMenuItemClick(
    (IconData icon, String title) item,
    BuildContext context,
  ) {
    final title = item.$2;
    ref.read(navigationControllerProvider.notifier).closeDrawer();

    if (title == Languages.about) {
      context.push(AppRoutes.ABOUT);
    } else if (title == Languages.home) {
      ref.read(navigationControllerProvider.notifier).changeIndex(0);
    } else if (title == Languages.profile) {
      ref.read(navigationControllerProvider.notifier).changeIndex(3);
    } else if (title == Languages.history) {
      ref.read(navigationControllerProvider.notifier).changeIndex(2);
    } else if (title == Languages.settings) {
      ref.read(navigationControllerProvider.notifier).changeIndex(4);
    } else if (title == Languages.notifications) {
      context.push(AppRoutes.NOTIFICATIONS);
    } else {
      Toast.showDefaultToast();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 监听全局抽屉开闭状态
    ref.listen<bool>(
      navigationControllerProvider.select((s) => s.isDrawerOpen),
      (previous, next) {
        if (next && !_controller.isCompleted) {
          _controller.forward();
        } else if (!next && !_controller.isDismissed) {
          _controller.reverse();
        }
      },
    );

    // 当抽屉完全收起时，直接返回原生全尺寸内容，确保移动端底部导航栏贴底且不产生任何空白
    if (_percentage == 0.0) {
      return Material(
        color: Colors.transparent,
        child: SizedBox.expand(child: widget.child),
      );
    }

    ref.watch(localeProvider);
    final navigationState = ref.watch(navigationControllerProvider);
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = (widget.screenWidth != null && widget.screenWidth! > 0)
        ? widget.screenWidth!
        : screenSize.width;
    final double screenHeight = screenSize.height;

    final slideMenuList = [
      (Icons.home_outlined, Languages.home),
      (Icons.person_outline, Languages.profile),
      (Icons.history_outlined, Languages.history),
      (Icons.notifications_outlined, Languages.notifications),
      (Icons.settings, Languages.settings),
      (Icons.help_outline_outlined, Languages.about),
    ];

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 抽屉背景菜单层
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.only(left: 30.dp),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    "#ffc19bff".hexToColor,
                    "#ff7784ff".hexToColor,
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20.dp),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.dp),
                      child: NetworkWebImage(
                        navigationState.userAvatar,
                        size: Size.square(70.dp),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.dp, bottom: 12.dp),
                    child: Text(
                      navigationState.userName.isNotEmpty
                          ? navigationState.userName
                          : "User",
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ),
                  Text(
                    navigationState.userEmail.isNotEmpty
                        ? navigationState.userEmail
                        : "user@sirc.com",
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                  Padding(padding: EdgeInsets.all(20.dp)),
                  ...slideMenuList.map((item) {
                    return GestureDetector(
                      onTap: () => _handleMenuItemClick(item, context),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10.dp),
                        child: Row(
                          children: [
                            Icon(
                              item.$1,
                              color: Colors.white,
                            ),
                            Text(
                              " ${item.$2}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  Padding(padding: EdgeInsets.symmetric(vertical: 20.dp)),
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(navigationControllerProvider.notifier)
                          .closeDrawer();
                    },
                    child: Container(
                      width: 50.dp,
                      height: 50.dp,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50.dp),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.7),
                            blurRadius: 15.dp,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.exit_to_app_outlined,
                        color: "#ff7784ff".hexToColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 中间装饰投影层
          Transform(
            transform: Matrix4.identity()
              ..translate(
                screenWidth * 0.55 * _percentage,
                0.18 * _percentage * screenHeight,
              )
              ..scale(1.0 - (_percentage * 0.36)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(_percentage * 20.dp),
              ),
            ),
          ),
          // 顶层主体内容层
          Transform(
            transform: Matrix4.identity()
              ..translate(
                screenWidth * 0.6 * _percentage,
                0.15 * _percentage * screenHeight,
              )
              ..scale(1.0 - (_percentage * 0.3)),
            child: SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: "#ffc19bff".hexToColor.withValues(alpha: 0.7),
                      blurRadius: 15.dp,
                      offset: Offset(-5.dp, 5.dp),
                      spreadRadius: 5.dp,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_percentage * 20.dp),
                  child: Stack(
                    children: [
                      widget.child,
                      // 当抽屉展开时，覆盖一层点击遮罩，点击立即收起抽屉
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            ref
                                .read(navigationControllerProvider.notifier)
                                .closeDrawer();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
