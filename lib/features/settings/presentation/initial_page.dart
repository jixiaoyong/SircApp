import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  late final PageController _pageController;

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
                if (!mounted) return;
                final destination = ref
                    .read(initialControllerProvider.notifier)
                    .completeInitialFlow();
                if (destination != null) context.go(destination);
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
    final isFirst = ref.watch(initialControllerProvider).isFirstInitial;
    final tips = InitialState.initialTips;

    return Material(
      child: SafeArea(
        child: isFirst
            ? _InitialOnboarding(
                controller: _pageController,
                tips: tips,
                onComplete: () {
                  final destination = ref
                      .read(initialControllerProvider.notifier)
                      .completeInitialFlow();
                  if (destination != null) context.go(destination);
                },
              )
            : const _SplashContent(),
      ),
    );
  }
}

class _InitialOnboarding extends StatelessWidget {
  const _InitialOnboarding({
    required this.controller,
    required this.tips,
    required this.onComplete,
  });

  final PageController controller;
  final List<(String image, String title, String subtitle)> tips;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final (imagePath, title, subtitle) = tips[index];
        return _InitialTipPage(
          imagePath: imagePath,
          title: title,
          subtitle: subtitle,
          index: index,
          pageCount: tips.length,
          onNext: () => controller.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
          onComplete: onComplete,
        );
      },
    );
  }
}

class _InitialTipPage extends StatelessWidget {
  const _InitialTipPage({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.index,
    required this.pageCount,
    required this.onNext,
    required this.onComplete,
  });

  final String imagePath;
  final String title;
  final String subtitle;
  final int index;
  final int pageCount;
  final VoidCallback onNext;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportHeight = constraints.maxHeight;
          final imageHeight = (viewportHeight * 0.36).clamp(0.0, 360.0);

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewportHeight),
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
                  _PageIndicator(currentIndex: index, pageCount: pageCount),
                  TitleText(text: title),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (index < pageCount - 1)
                    _NextPageButton(onPressed: onNext)
                  else
                    _GetStartedButton(onPressed: onComplete),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.currentIndex, required this.pageCount});

  final int currentIndex;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      key: ValueKey('initial_indicators_$currentIndex'),
      height: 10,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: pageCount,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: index == currentIndex
                ? colors.onSurface
                : colors.outlineVariant,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class _NextPageButton extends StatelessWidget {
  const _NextPageButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 50,
        width: 50,
        margin: const EdgeInsets.only(top: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: colors.primary,
        ),
        child: Icon(Icons.arrow_forward_rounded, color: colors.onPrimary),
      ),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
        child: ConstrainedContent(
          maxWidth: 360,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: colors.primary,
            ),
            child: Center(
              child: Text(
                Languages.getStart,
                style: TextStyle(color: colors.onPrimary, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Center(child: Image.asset(A.assets_ic_launcher)),
        const Spacer(),
        ConstrainedContent(
          maxWidth: 520,
          padding: const EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer
                  .withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                Languages.somethingLikeAds,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
