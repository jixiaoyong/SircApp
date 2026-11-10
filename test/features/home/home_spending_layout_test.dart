import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/features/home/controllers/home_controller.dart';
import 'package:sirc/features/home/presentation/home_page.dart';

// 只验证消费卡片，不让银行卡的 Ahem 等宽测试字体布局干扰小屏边界。
class _SpendingHomeController extends HomeController {
  @override
  HomeState build() => super.build().copyWith(banks: const []);
}

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1200, 900),
  ]) {
    testWidgets('消费卡片在 $size 默认字号下完整容纳图标金额与双行标签', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({
        CommonKeys.LOCAL_LANGUAGE: 'en_US',
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          homeControllerProvider.overrideWith(_SpendingHomeController.new),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: HomeTopBodyWidget(
                  homeState: container.read(homeControllerProvider),
                  userAvatar: '',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);

      final label = find.text(Languages.moneyRecharge).first;
      final column = find
          .ancestor(of: label, matching: find.byType(Column))
          .first;
      await tester.ensureVisible(label);
      await tester.pump();
      final context = tester.element(label);
      expect(MediaQuery.textScalerOf(context).scale(12), 12);
      expect(tester.widget<Text>(label).style!.fontSize, 12);
      final contentRect = tester.getRect(column);
      final icon = find.descendant(
        of: column,
        matching: find.byIcon(Icons.run_circle_outlined),
      );
      final amount = find.descendant(of: column, matching: find.text(r'-$20'));
      expect(tester.widget<Text>(amount).style!.fontSize, 20);
      expect(tester.getSize(icon), const Size(50, 50));
      expect(contentRect.width, 100);
      // 英文充值标签在固定 100px 内容宽度内换两行，必须完整显示。
      expect(tester.getSize(label).height, greaterThan(24));
      // Material 3 默认行高：50px 图标 + 29px 金额 + 34px 双行标签。
      expect(tester.getSize(amount).height, 29);
      expect(tester.getSize(label).height, 34);
      expect(contentRect.height, 120);
      for (final child in [icon, amount, label]) {
        final rect = tester.getRect(child);
        expect(rect.top, greaterThanOrEqualTo(contentRect.top));
        expect(rect.bottom, lessThanOrEqualTo(contentRect.bottom));
        expect(rect.left, greaterThanOrEqualTo(contentRect.left));
        expect(rect.right, lessThanOrEqualTo(contentRect.right));
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
