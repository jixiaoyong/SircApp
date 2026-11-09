import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/data/common_data.dart';
import 'package:sirc/main.dart';
import 'package:sirc/routes/app_router.dart';
import 'package:sirc/utils/size_extension.dart';

void main() {
  for (final width in [320.0, 375.0, 430.0, 1440.0, 1461.0]) {
    testWidgets('窗口 $width 全宽传递到 Scaffold，登录表单保持局部限宽', (tester) async {
      tester.view.physicalSize = Size(width, 1407);
      tester.view.devicePixelRatio = 1;
      addTearDown(() => tester.view.reset());
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      late GoRouter router;
      await tester.pumpWidget(ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MyApp(),
      ));
      await tester.pumpAndSettle();
      router = ProviderScope.containerOf(tester.element(find.byType(MyApp)))
          .read(appRouterProvider);
      router.go('/sign_in');
      await tester.pumpAndSettle();

      final scaffold = find.byType(Scaffold);
      final rect = tester.getRect(scaffold);
      expect(rect.left, 0);
      expect(rect.width, width);
      expect(MediaQuery.sizeOf(tester.element(scaffold)).width, width);
      expect(CommonData.realScreenWidth, width);
      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(2));
      final expectedFieldWidth = width.clamp(0.0, 520.0) - 32;
      for (final field in fields.evaluate()) {
        expect(tester.getSize(find.byWidget(field.widget)).width,
            closeTo(expectedFieldWidth, 0.01));
      }
      expect(tester.getRect(fields.first).center.dx, closeTo(width / 2, 0.01));
      expect(24.dp, 24);
      expect(16.sp, 16);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
