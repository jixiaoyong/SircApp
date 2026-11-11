import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/gen_a/A.dart';
import 'package:sirc/widgets/network_web_image.dart';

void main() {
  group('NetworkWebImage Tests', () {
    for (final dark in [false, true]) {
      testWidgets('fallback follows theme colors dark=$dark', (tester) async {
        final theme = dark ? AppTheme.darkTheme : AppTheme.lightTheme;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(body: NetworkWebImage('', size: const Size(60, 60))),
          ),
        );

        final scheme = theme.colorScheme;
        final fallback = tester.widget<Container>(
          find
              .ancestor(
                of: find.byIcon(Icons.person_rounded),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(
          (fallback.decoration! as BoxDecoration).color,
          scheme.surfaceContainer,
        );
        expect(
          tester.widget<Icon>(find.byIcon(Icons.person_rounded)).color,
          scheme.onSurfaceVariant,
        );
      });
    }

    testWidgets('renders fallback avatar when URL is empty or invalid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NetworkWebImage('', size: Size(50, 50))),
        ),
      );

      // Verify default avatar icon is rendered
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);

      // Ensure no raw "Failed to load image" text appears
      expect(find.text('Failed to load image'), findsNothing);
    });

    testWidgets('renders non-avatar fallback icon when isAvatar is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetworkWebImage(null, size: Size(40, 40), isAvatar: false),
          ),
        ),
      );

      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsNothing);
    });

    testWidgets('renders custom fallbackWidget when provided', (
      WidgetTester tester,
    ) async {
      const customKey = Key('custom_fallback');
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetworkWebImage('', fallbackWidget: SizedBox(key: customKey)),
          ),
        ),
      );

      expect(find.byKey(customKey), findsOneWidget);
    });

    testWidgets('renders custom fallbackIcon when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetworkWebImage(
              'invalid-url',
              size: Size(60, 60),
              fallbackIcon: Icons.account_circle,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.account_circle), findsOneWidget);
    });

    testWidgets('renders fallbackAsset with App Logo when configured', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetworkWebImage(
              '',
              size: Size(60, 60),
              fallbackAsset: A.assets_ic_launcher,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('applies borderRadius correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetworkWebImage(
              '',
              size: Size(50, 50),
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
          ),
        ),
      );

      final clipRRectFinder = find.byType(ClipRRect);
      expect(clipRRectFinder, findsOneWidget);
      final clipRRect = tester.widget<ClipRRect>(clipRRectFinder);
      expect(
        clipRRect.borderRadius,
        const BorderRadius.all(Radius.circular(25)),
      );
    });

    testWidgets('renders small dimensions without overflow errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NetworkWebImage('', size: Size(16, 16))),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });
  });
}
