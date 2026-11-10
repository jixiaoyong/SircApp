import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/presentation/menu_page.dart';
import 'package:sirc/features/home/presentation/person_page.dart';
import 'package:sirc/widgets/settings_item_tile.dart';

class _TestLocaleNotifier extends LocaleNotifier {
  _TestLocaleNotifier(this.locale);

  final Locale locale;

  @override
  Locale build() {
    AppLocale.setLocale(locale);
    return locale;
  }
}

void expectSharedGeometry(WidgetTester tester, Finder tiles) {
  for (final element in tiles.evaluate()) {
    final tile = element.widget as ListTile;
    final rect = tester.getRect(find.byWidget(tile));
    final leading = tester.getRect(find.byWidget(tile.leading!));
    final title = tester.getRect(find.byWidget(tile.title!));
    final trailing = tester.getRect(
      find.descendant(
        of: find.byWidget(tile),
        matching: find.byWidget(tile.trailing!),
      ),
    );
    expect(rect.height, greaterThanOrEqualTo(64));
    expect(leading.size, const Size(36, 36));
    expect(
      tester.getSize(
        find.descendant(
          of: find.byWidget(tile.leading!),
          matching: find.byType(Icon),
        ),
      ),
      const Size(20, 20),
    );
    expect(leading.left - rect.left, 16);
    expect(title.left - leading.right, 16);
    expect(trailing.left - title.right, greaterThanOrEqualTo(16));
    expect(leading.center.dy, closeTo(rect.center.dy, 0.01));
    expect(trailing.center.dy, closeTo(rect.center.dy, 0.01));
  }
}

void main() {
  final initialLocale = AppLocale.currentLocale;
  tearDown(() => AppLocale.setLocale(initialLocale));

  for (final width in [320.0, 1440.0]) {
    for (final language in ['zh', 'en']) {
      testWidgets('两页使用同一设置行 $width / $language', (tester) async {
        tester.view.physicalSize = Size(width, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        AppLocale.setLocale(Locale(language));
        for (final page in [const MenuPage(), const PersonPage()]) {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                localeProvider.overrideWith(
                  () => _TestLocaleNotifier(Locale(language)),
                ),
              ],
              child: MaterialApp(home: Scaffold(body: page)),
            ),
          );
          await tester.pump();
          expect(AppLocale.currentLocale.languageCode, language);
          final shared = find.byType(SettingsItemTile);
          expect(shared, findsNWidgets(page is MenuPage ? 5 : 4));
          final tiles = find.descendant(
            of: shared,
            matching: find.byType(ListTile),
          );
          expectSharedGeometry(tester, tiles);
          for (final tile in shared.evaluate()) {
            final materials = find.ancestor(
              of: find.byWidget(tile.widget),
              matching: find.byType(Material),
            );
            final material = tester.widget<Material>(materials.first);
            expect(material.clipBehavior, Clip.antiAlias);
            if (page is MenuPage) {
              expect(material.shape, isA<Border>());
            } else {
              final radius =
                  material.borderRadius ??
                  (material.shape as RoundedRectangleBorder).borderRadius;
              expect(radius, BorderRadius.circular(14));
            }
          }
          if (page is PersonPage) {
            expect(find.byType(Divider), findsNWidgets(3));
            expect(find.text(Languages.email), findsOneWidget);
          } else {
            expect(find.text(Languages.language), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        }
      });
    }

    testWidgets('长文本和大字体自适应 $width', (tester) async {
      tester.view.physicalSize = Size(width, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final title in [
        '非常长的个人信息与语言设置标题，请检查完整换行和尾部控件',
        'A very long personal information and language settings title that wraps',
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: SettingsItemTile(
                  icon: Icons.language,
                  title: title,
                  trailing: CupertinoSwitch(value: false, onChanged: (_) {}),
                  onTap: () {},
                ),
              ),
            ),
          ),
        );
        expect(find.text(title), findsOneWidget);
        expectSharedGeometry(tester, find.byType(ListTile));
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('菜单开关与行点击各切换一次，普通项使用箭头', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: MenuPage())),
      ),
    );
    await tester.pump();
    var changes = 0;
    final subscription = container.listen(
      fingerprintEnabledProvider,
      (previous, next) => changes++,
    );
    addTearDown(subscription.close);
    expect(find.byIcon(Icons.keyboard_arrow_right), findsNWidgets(4));
    final control = find.byType(CupertinoSwitch);
    await tester.tap(control);
    await tester.pumpAndSettle();
    expect(container.read(fingerprintEnabledProvider), isTrue);
    expect(changes, 1);
    final row = find.ancestor(
      of: control,
      matching: find.byType(SettingsItemTile),
    );
    final title = find.descendant(of: row, matching: find.byType(Text));
    await tester.tap(title);
    await tester.pumpAndSettle();
    expect(container.read(fingerprintEnabledProvider), isFalse);
    expect(changes, 2);
    expect(tester.takeException(), isNull);
  });
}
