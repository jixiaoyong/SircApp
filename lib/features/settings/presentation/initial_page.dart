import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale.dart';
import '../../../gen_a/A.dart';
import '../../../widgets/constrained_content.dart';
import '../../../widgets/title_text.dart';
import '../controllers/settings_controller.dart';

/*
* @description: 启动引导与闪屏页面
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
      child: SafeArea(
        child: isFirst
            ? PageView.builder(
                controller: _pageController,
                itemCount: initialInfoLength,
                itemBuilder: (context, index) {
                  final (imagePath, title, subtitle) = tips[index];

                  return Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.only(right: 20, left: 20),
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
                                const SizedBox(height: 32),
                                SizedBox(
                                  key: ValueKey('initial_indicators_$index'),
                                  height: 10,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: initialInfoLength,
                                    itemBuilder: (context, subIndex) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                        ),
                                        height: 10,
                                        width: 10,
                                        decoration: BoxDecoration(
                                          color: subIndex == index
                                              ? Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .outlineVariant,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                TitleText(text: title),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    subtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontSize: 15,
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
                                          height: 50,
                                          width: 50,
                                          margin: const EdgeInsets.only(
                                            top: 30,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
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
                                          padding: const EdgeInsets.fromLTRB(
                                            30,
                                            30,
                                            30,
                                            0,
                                          ),
                                          child: ConstrainedContent(
                                            maxWidth: 360,
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  Languages.getStart,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    fontSize: 20,
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
              )
            : Column(
                children: [
                  const Spacer(),
                  Center(child: Image.asset(A.assets_ic_launcher)),
                  const Spacer(),
                  ConstrainedContent(
                    maxWidth: 520,
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer
                            .withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Center(
                        child: Text(
                          Languages.somethingLikeAds,
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
