import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale.dart';
import '../../../data/common_data.dart';
import '../../../gen_a/A.dart';
import '../../../utils/size_extension.dart';
import '../../../widgets/constrained_content.dart';
import '../../../widgets/title_text.dart';
import '../controllers/settings_controller.dart';

/*
* @description: 启动引导与闪屏页面（Riverpod 现代架构）
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19 (Refactored to Riverpod 2.x)
*/
class InitialPage extends ConsumerStatefulWidget {
  const InitialPage({super.key});

  @override
  ConsumerState<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends ConsumerState<InitialPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isFirst = ref.read(initialControllerProvider).isFirstInitial;
      if (!isFirst) {
        ref
            .read(initialControllerProvider.notifier)
            .startAutoNavigateCountdown(
              onComplete: () {
                if (mounted) {
                  ref
                      .read(initialControllerProvider.notifier)
                      .goMainPage(context);
                }
              },
            );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 监听多语言变化以刷新文案
    ref.watch(localeProvider);

    final state = ref.watch(initialControllerProvider);
    final isFirst = state.isFirstInitial;
    final tips = InitialState.initialTips;
    final initialInfoLength = tips.length;

    return Material(
      child: isFirst
          ? SizedBox(
              width: CommonData.realScreenWidth,
              child: PageView.builder(
                controller: _pageController,
                itemCount: initialInfoLength,
                itemBuilder: (context, index) {
                  final (imagePath, title, subtitle) = tips[index];

                  return Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(right: 20.dp, left: 20.dp),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final viewportHeight = constraints.maxHeight;
                        final imageHeight = (viewportHeight * 0.36)
                            .clamp(0.0, 360.0)
                            .toDouble();

                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: viewportHeight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  imagePath,
                                  height: imageHeight,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(
                                  height: 10.dp,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: initialInfoLength,
                                    itemBuilder: (context, subIndex) {
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 5.dp,
                                        ),
                                        height: 10.dp,
                                        width: 10.dp,
                                        decoration: BoxDecoration(
                                          color: subIndex == index
                                              ? Colors.deepPurpleAccent
                                              : Colors.grey,
                                          borderRadius: BorderRadius.circular(
                                            10.dp,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                TitleText(text: title),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.dp,
                                  ),
                                  child: Text(
                                    subtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 15.sp,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                initialInfoLength - 1 != index
                                    ? GestureDetector(
                                        onTap: () {
                                          _pageController.nextPage(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        child: Container(
                                          height: 50.dp,
                                          width: 50.dp,
                                          margin: EdgeInsets.only(top: 30.dp),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              25.dp,
                                            ),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Colors.purple,
                                                Colors.deepPurpleAccent,
                                              ],
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          ref
                                              .read(
                                                initialControllerProvider
                                                    .notifier,
                                              )
                                              .goMainPage(context);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                            30.dp,
                                            30.dp,
                                            30.dp,
                                            0,
                                          ),
                                          child: ConstrainedContent(
                                            maxWidth: 360,
                                            child: Container(
                                              height: 50.dp,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      15.dp,
                                                    ),
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Colors.purple,
                                                    Colors.deepPurpleAccent,
                                                  ],
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  Languages.getStart,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20.sp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            )
          : Column(
              children: [
                const Spacer(),
                Center(child: Image.asset(A.assets_ic_launcher)),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10.0),
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Center(
                    child: Text(
                      Languages.somethingLikeAds,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
