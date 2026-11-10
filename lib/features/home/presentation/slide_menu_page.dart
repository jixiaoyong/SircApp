import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/utils/toast.dart';
import 'package:sirc/widgets/network_web_image.dart';

/// 侧滑抽屉 Widget，支持平移缩放视觉与抽屉动画
class SlideMenuPage extends ConsumerStatefulWidget {
  final Widget child;
  final double? screenWidth;
  final ValueChanged<int> onBranchSelected;

  const SlideMenuPage({
    super.key,
    required this.child,
    this.screenWidth,
    required this.onBranchSelected,
  });

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
    } else if (title == Languages.home.title) {
      widget.onBranchSelected(0);
    } else if (title == Languages.profile) {
      widget.onBranchSelected(3);
    } else if (title == Languages.history) {
      widget.onBranchSelected(2);
    } else if (title == Languages.settings.title) {
      widget.onBranchSelected(4);
    } else if (title == Languages.notifications) {
      context.push(AppRoutes.MENU_NOTIFICATIONS);
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

    // 收起与展开保持同一棵主体树，避免抽屉动画重建分支 Navigator。
    ref.watch(localeProvider);
    final navigationState = ref.watch(navigationControllerProvider);
    final colors = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth =
        (widget.screenWidth != null && widget.screenWidth! > 0)
        ? widget.screenWidth!
        : screenSize.width;
    final double screenHeight = screenSize.height;

    final slideMenuList = [
      (Icons.home_outlined, Languages.home.title),
      (Icons.person_outline, Languages.profile),
      (Icons.history_outlined, Languages.history),
      (Icons.notifications_outlined, Languages.notifications),
      (Icons.settings, Languages.settings.title),
      (Icons.help_outline_outlined, Languages.about),
    ];

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 抽屉背景菜单层
          Positioned.fill(
            child: ExcludeSemantics(
              excluding: _percentage == 0,
              child: Container(
                padding: EdgeInsets.only(left: 30.dp),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 32.dp),
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
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      Text(
                        navigationState.userEmail.isNotEmpty
                            ? navigationState.userEmail
                            : "user@sirc.com",
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 12.sp,
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(20.dp)),
                      ...slideMenuList.map((item) {
                        return GestureDetector(
                          onTap: () => _handleMenuItemClick(item, context),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10.dp),
                            child: Row(
                              children: [
                                Icon(item.$1, color: colors.onSurface),
                                Text(
                                  " ${item.$2}",
                                  style: TextStyle(color: colors.onSurface),
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
                            color: colors.onSurface,
                            borderRadius: BorderRadius.circular(50.dp),
                          ),
                          child: Icon(
                            Icons.exit_to_app_outlined,
                            color: colors.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 中间装饰投影层
          Transform(
            transform: Matrix4.identity()
              ..translateByDouble(
                screenWidth * 0.55 * _percentage,
                0.18 * _percentage * screenHeight,
                0,
                1,
              )
              ..scaleByDouble(
                1.0 - (_percentage * 0.36),
                1.0 - (_percentage * 0.36),
                1.0 - (_percentage * 0.36),
                1,
              ),
            child: Container(
              decoration: BoxDecoration(
                color: colors.onSurface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(_percentage * 20.dp),
              ),
            ),
          ),
          // 顶层主体内容层
          Transform(
            transform: Matrix4.identity()
              ..translateByDouble(
                screenWidth * 0.6 * _percentage,
                0.15 * _percentage * screenHeight,
                0,
                1,
              )
              ..scaleByDouble(
                1.0 - (_percentage * 0.3),
                1.0 - (_percentage * 0.3),
                1.0 - (_percentage * 0.3),
                1,
              ),
            child: SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: colors.outlineVariant.withValues(alpha: 0.3),
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
                      if (_percentage > 0)
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
