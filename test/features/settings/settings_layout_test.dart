import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/data/common_data.dart';
import 'package:sirc/features/home/presentation/menu_page.dart';
import 'package:sirc/features/settings/controllers/settings_controller.dart';
import 'package:sirc/features/settings/presentation/initial_page.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  for (final brightness in Brightness.values) {
    testWidgets('引导小屏大字在 $brightness 下可切换三个步骤', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      final previousWidth = CommonData.realScreenWidth;
      CommonData.realScreenWidth = 320;
      addTearDown(() {
        tester.view.reset();
        CommonData.realScreenWidth = previousWidth;
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            theme: ThemeData(brightness: brightness),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: const InitialPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final tips = InitialState.initialTips;
      for (var index = 0; index < tips.length; index++) {
        final page = find.ancestor(
          of: find.text(tips[index].$2),
          matching: find.byType(SingleChildScrollView),
        );
        final control = index < tips.length - 1
            ? find.byIcon(Icons.arrow_forward_rounded)
            : find.text(Languages.getStart);
        await tester.scrollUntilVisible(
          control,
          100,
          scrollable: find
              .descendant(of: page, matching: find.byType(Scrollable))
              .first,
        );
        expect(control.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (index < tips.length - 1) {
          await tester.tap(control);
          await tester.pumpAndSettle();
        }
      }
    });
  }

  for (final width in [320.0, 375.0, 390.0, 430.0, 1461.0]) {
    testWidgets('引导末页按钮在宽度 $width 时居中并保留边距', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      final previousWidth = CommonData.realScreenWidth;
      CommonData.realScreenWidth = width;
      addTearDown(() {
        tester.view.reset();
        CommonData.realScreenWidth = previousWidth;
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: InitialPage()),
        ),
      );
      await tester.pumpAndSettle();
      final pageView = tester.widget<PageView>(find.byType(PageView));
      final tips = InitialState.initialTips;
      for (var index = 0; index < tips.length; index++) {
        final title = find.text(tips[index].$2);
        expect(title.hitTestable(), findsOneWidget);
        final image = find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == tips[index].$1,
        );
        expect(tester.getRect(image).center.dx, closeTo(width / 2, 0.01));
        expect(tester.getRect(image).top, greaterThanOrEqualTo(0));
        final indicators = find.byKey(ValueKey('initial_indicators_$index'));
        expect(
          tester.getRect(indicators).top - tester.getRect(image).bottom,
          closeTo(32, 0.01),
        );
        expect(tips[index].$1, endsWith('_transparent.webp'));
        expect(tester.takeException(), isNull);
        if (index < tips.length - 1) {
          final next = find.byIcon(Icons.arrow_forward_rounded).hitTestable();
          expect(next, findsOneWidget);
          expect(tester.getRect(next).center.dx, closeTo(width / 2, 0.01));
          await tester.tap(next);
          await tester.pumpAndSettle();
          expect(pageView.controller!.page, index + 1);
        }
      }

      final button = find
          .ancestor(
            of: find.text(Languages.getStart),
            matching: find.byType(DecoratedBox),
          )
          .first;
      final rect = tester.getRect(button);
      expect(rect.width, (width - 100).clamp(0, 360));
      expect(rect.height, 50);
      expect(rect.center.dx, closeTo(width / 2, 0.01));
      expect(rect.left, greaterThanOrEqualTo(50));
      expect(width - rect.right, greaterThanOrEqualTo(50));
      expect(rect.bottom, lessThanOrEqualTo(900));
      final subtitleRect = tester.getRect(find.text(tips.last.$3));
      expect(rect.top - subtitleRect.bottom, closeTo(30, 0.01));
      expect(MediaQuery.sizeOf(tester.element(button)).width, width);
      expect(tester.takeException(), isNull);
    });

    testWidgets('设置项在宽度 $width 时维持图标与卡片比例', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: Scaffold(body: MenuPage())),
        ),
      );
      await tester.pumpAndSettle();

      final tiles = find.byType(ListTile);
      expect(tiles, findsNWidgets(5));
      for (final tileElement in tiles.evaluate()) {
        final tileFinder = find.byWidget(tileElement.widget);
        final tile = tileElement.widget as ListTile;
        final leading = find.byWidget(tile.leading!);
        final icon = find.descendant(of: leading, matching: find.byType(Icon));
        final tileRect = tester.getRect(tileFinder);
        final leadingRect = tester.getRect(leading);
        final titleRect = tester.getRect(find.byWidget(tile.title!));
        final trailingRect = tester.getRect(
          find.descendant(
            of: tileFinder,
            matching: find.byWidget(tile.trailing!),
          ),
        );
        expect(tileRect.height, greaterThanOrEqualTo(64));
        expect(leadingRect.size, const Size(36, 36));
        expect(tester.getSize(icon), const Size(20, 20));
        expect(leadingRect.top - tileRect.top, greaterThanOrEqualTo(12));
        expect(tileRect.bottom - leadingRect.bottom, greaterThanOrEqualTo(12));
        if (tile.subtitle == null) {
          expect(titleRect.center.dy, closeTo(tileRect.center.dy, 0.01));
        } else {
          expect(titleRect.top, greaterThanOrEqualTo(tileRect.top));
          expect(
            tester.getRect(find.byWidget(tile.subtitle!)).bottom,
            lessThanOrEqualTo(tileRect.bottom),
          );
        }
        expect(trailingRect.center.dy, closeTo(tileRect.center.dy, 0.01));
        expect(tileRect.left, greaterThanOrEqualTo(0));
        expect(tileRect.right, lessThanOrEqualTo(width));
      }
      expect(tester.takeException(), isNull);
    });
  }
}
