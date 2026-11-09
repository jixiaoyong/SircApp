import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/data/common_data.dart';
import 'package:sirc/features/home/presentation/menu_page.dart';
import 'package:sirc/features/settings/presentation/initial_page.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  for (final width in [320.0, 1440.0]) {
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
      pageView.controller!.jumpToPage(2);
      await tester.pumpAndSettle();

      final button = find
          .ancestor(
            of: find.text(Languages.getStart),
            matching: find.byType(DecoratedBox),
          )
          .first;
      final rect = tester.getRect(button);
      expect(rect.width, lessThanOrEqualTo(360));
      expect(rect.center.dx, closeTo(width / 2, 0.01));
      expect(rect.left, greaterThanOrEqualTo(20));
      expect(width - rect.right, greaterThanOrEqualTo(20));
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
          find.descendant(of: tileFinder, matching: find.byWidget(tile.trailing!)),
        );
        expect(tileRect.height, greaterThanOrEqualTo(88));
        expect(leadingRect.size, const Size(40, 40));
        expect(tester.getSize(icon), const Size(24, 24));
        expect(leadingRect.top - tileRect.top, greaterThanOrEqualTo(24));
        expect(tileRect.bottom - leadingRect.bottom, greaterThanOrEqualTo(24));
        expect(titleRect.center.dy, closeTo(tileRect.center.dy, 0.01));
        expect(trailingRect.center.dy, closeTo(tileRect.center.dy, 0.01));
        expect(tileRect.left, greaterThanOrEqualTo(0));
        expect(tileRect.right, lessThanOrEqualTo(width));
      }
      expect(tester.takeException(), isNull);
    });
  }
}
