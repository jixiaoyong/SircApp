import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart'
    show ResponsiveQuery;
import 'package:sirc/features/auth/presentation/sign_in_page.dart';
import 'package:sirc/widgets/constrained_content.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/main.dart';
import 'package:sirc/routes/app_router.dart';
import 'package:sirc/routes/app_routes.dart';

void main() {
  testWidgets('1461 视口内父约束独立 resize，登录局部 query 和固定尺寸同步', (tester) async {
    tester.view.physicalSize = const Size(1461, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final parentWidth = ValueNotifier<double>(320);
    addTearDown(parentWidth.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: ValueListenableBuilder<double>(
              valueListenable: parentWidth,
              child: const SignInPage(),
              builder: (context, width, child) =>
                  SizedBox(width: width, child: child),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final width in [320.0, 430.0, 900.0, 320.0]) {
      parentWidth.value = width;
      await tester.pumpAndSettle();
      final form = find.byType(ConstrainedContent);
      final localContext = tester.element(form);
      expect(MediaQuery.sizeOf(localContext).width, 1461);
      expect(ResponsiveQuery.of(localContext).width, width);
      final expectedWidth = width.clamp(0.0, 520.0);
      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(2));
      expect(tester.getSize(fields.first).width, expectedWidth - 40);
      expect(tester.getRect(fields.first).center.dx, closeTo(width / 2, 0.01));
      expect(tester.widget<ConstrainedContent>(form).maxWidth, expectedWidth);
      expect(24, 24);
      expect(16, 16);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  for (final width in [320.0, 375.0, 430.0, 1440.0, 1461.0]) {
    testWidgets('窗口 $width 全宽传递到 Scaffold，登录表单保持局部限宽', (tester) async {
      tester.view.physicalSize = Size(width, 1407);
      tester.view.devicePixelRatio = 1;
      addTearDown(() => tester.view.reset());
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      late GoRouter router;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
      router = ProviderScope.containerOf(tester.element(find.byType(MyApp)))
          .read(appRouterProvider);
      router.go(AppRoutes.SIGN_IN);
      await tester.pumpAndSettle();

      final scaffold = find.byType(Scaffold);
      final rect = tester.getRect(scaffold);
      expect(rect.left, 0);
      expect(rect.width, width);
      expect(MediaQuery.sizeOf(tester.element(scaffold)).width, width);
      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(2));
      final expectedFieldWidth = width.clamp(0.0, 520.0) - 40;
      for (final field in fields.evaluate()) {
        expect(
          tester.getSize(find.byWidget(field.widget)).width,
          closeTo(expectedFieldWidth, 0.01),
        );
      }
      expect(tester.getRect(fields.first).center.dx, closeTo(width / 2, 0.01));
      expect(24, 24);
      expect(16, 16);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
