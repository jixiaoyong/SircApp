import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale.dart';
import '../controllers/settings_controller.dart';

/*
* @description: 多语言切换页面（Riverpod 现代架构）
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19 (Refactored to Riverpod 2.x)
*/
class LanguagePage extends ConsumerWidget {
  const LanguagePage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final currentTag =
        currentLocale.countryCode != null &&
            currentLocale.countryCode!.isNotEmpty
        ? '${currentLocale.languageCode}_${currentLocale.countryCode}'
        : currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Languages.language,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back, color: Colors.black),
          onTap: () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
      ),
      body: ListView.separated(
        itemCount: supportedLanguages.length,
        itemBuilder: (context, index) {
          final item = supportedLanguages[index];
          final isSelected = currentTag == item.$2;

          return ListTile(
            title: Text(item.$1),
            trailing: isSelected
                ? const Icon(Icons.check_circle_outline, color: Colors.green)
                : null,
            onTap: () {
              switchAppLanguage(ref, item.$2);
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.of(context).maybePop();
              }
            },
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      ),
    );
  }
}
