import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return Column(
      children: [
        const Icon(Icons.details, size: 100),
        const Text('Not Found'),
        OutlinedButton(
          child: const Text('Go to Home'),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.INITIAL,
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}
