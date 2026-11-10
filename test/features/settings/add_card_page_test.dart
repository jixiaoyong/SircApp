import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/wallet/presentation/add_card_page.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/widgets/common_text_button.dart';
import 'package:sirc/widgets/verify_code_widget.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('添加卡保留预览、四位CVV和月份入口 $brightness', (tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: const AddCardPage(),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(BankCardWidget), findsOneWidget);
      expect(find.text(Languages.nameOnCard), findsOneWidget);
      expect(find.text(Languages.cardNumber), findsOneWidget);
      expect(find.text('00/00'), findsWidgets);
      expect(
        tester
            .widget<VerifyCodeWidget>(find.byType(VerifyCodeWidget))
            .verifyCodeCount,
        4,
      );
      expect(
        tester
            .widget<CommonTextButton>(find.byType(CommonTextButton))
            .isButtonEnabled,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
