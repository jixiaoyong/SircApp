import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/languages.g.dart';
import '../../../routes/app_routes.dart';

/*
* @description: 404 页面（Riverpod 现代架构）
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19 (Refactored to Riverpod 2.x)
*/
class NotFoundPage extends ConsumerWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text(
              Languages.common.notFound,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              child: Text(Languages.common.goToHome),
              onPressed: () {
                context.go(AppRoutes.MAIN);
              },
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: '404 Page')
Widget notFoundPagePreview() {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    home: const Scaffold(body: NotFoundPage()),
  );
}
