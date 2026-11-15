import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/data/article_repository.dart';
import 'package:sirc/features/home/presentation/home_page.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';

class _TestLocaleNotifier extends LocaleNotifier {
  _TestLocaleNotifier(this.locale);

  final Locale locale;

  @override
  Locale build() => locale;
}

void main() {
  for (final language in ['zh', 'en']) {
    testWidgets('分类栏吸顶、回滚、切换与真实视口 $language', (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final locale = Locale(language);
      AppLocale.setLocale(locale);
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final groups = List.generate(
        3,
        (group) => List.generate(
          24,
          (index) => Article(
            id: '$group-$index',
            title: 'Article $group-$index',
            summary: 'Summary $group-$index',
            body: 'Body $group-$index',
          ),
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localeProvider.overrideWith(() => _TestLocaleNotifier(locale)),
            articleGroupsProvider(locale).overrideWith((ref) async => groups),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const SizedBox(height: 62),
                  Expanded(
                    child: CustomScrollView(
                      controller: controller,
                      slivers: [
                        const SliverToBoxAdapter(child: SizedBox(height: 180)),
                        const HomeArticlesPanel.sliver(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final segment = find.byKey(const ValueKey('article-segment-1'));
      final segments = find.ancestor(
        of: segment,
        matching: find.byType(NeutralSegments),
      );
      final viewport = tester.getRect(find.byType(CustomScrollView));
      final before = tester.getRect(segment);
      final originalBar = tester.getRect(segments);
      final stickyInset = tester.view.padding.top;
      final threshold = originalBar.top - viewport.top;
      // 必须先证实数据已加载且滚动范围足够，避免在 loading 的 224px 面板上假测吸顶。
      expect(find.byKey(const ValueKey('home-article-0-23')), findsOneWidget);
      expect(controller.positions, hasLength(1));
      expect(controller.position.viewportDimension, viewport.height);
      expect(controller.position.maxScrollExtent, greaterThan(threshold + 300));
      expect(segment, findsOneWidget);
      await tester.tap(segment);
      await tester.pumpAndSettle();

      Future<void> scrollTo(double pixels) async {
        controller.jumpTo(pixels);
        await tester.pump();
        await tester.pump();
      }

      await scrollTo(threshold - 1);
      expect(tester.getRect(segments).top, closeTo(viewport.top + 1, .5));
      await scrollTo(threshold + 1);
      expect(
        tester.getRect(segments).top,
        closeTo(viewport.top + stickyInset, .5),
      );
      // 再通过真实手势继续滚动，验证绑定的控制器确实跟随用户输入。
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -280));
      await tester.pumpAndSettle();
      expect(controller.offset, greaterThan(threshold + 200));
      final after = tester.getRect(segment);
      expect(
        tester.getRect(segments).top,
        closeTo(viewport.top + stickyInset, .5),
      );
      expect(after.size.height, before.size.height);
      expect(after.size.width, greaterThan(before.size.width));
      final button = tester.widget<TextButton>(segment);
      expect(
        button.style?.backgroundColor?.resolve({}),
        Theme.of(tester.element(segment)).colorScheme.surface,
      );
      // 浮层必须能命中点击，不能只验证移出屏幕的占位 widget。
      await tester.tap(find.byKey(const ValueKey('article-segment-2')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('home-article-2-0')), findsOneWidget);
      expect(
        tester.getRect(segments).top,
        closeTo(viewport.top + stickyInset, .5),
      );
      await scrollTo(controller.position.maxScrollExtent);
      expect(
        tester.getRect(segments).top,
        closeTo(viewport.top + stickyInset, .5),
      );
      await scrollTo(0);
      await tester.pumpAndSettle();
      expect(tester.getRect(segments), originalBar);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
