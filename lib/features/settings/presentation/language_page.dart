import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale.dart';
import '../controllers/settings_controller.dart';
import '../../../widgets/one_title_with_back_button_appbar.dart';

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
      appBar: OneTitleWithBackButtonAppBar(
        title: Languages.language,
        onBack: onBack,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: supportedLanguages.length,
        itemBuilder: (context, index) {
          final item = supportedLanguages[index];
          final isSelected = currentTag == item.$2;

          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            tileColor: Theme.of(context).colorScheme.surface,
            selected: isSelected,
            selectedColor: Theme.of(context).colorScheme.onSurface,
            title: Text(item.$1),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.onSurface,
                  )
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
