import 'package:material_ui/material_ui.dart';
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

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(
        title: Languages.language,
        onBack: onBack,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Material(
            key: const ValueKey('language-options-group'),
            color: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: colors.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (index, item) in supportedLanguages.indexed) ...[
                  if (index > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color:
                          currentTag == supportedLanguages[index - 1].$2 ||
                              currentTag == item.$2
                          ? Colors.transparent
                          : colors.onSurfaceVariant.withValues(alpha: 0.2),
                    ),
                  ListTile(
                    minTileHeight: 48,
                    selected: currentTag == item.$2,
                    selectedTileColor: Color.alphaBlend(
                      colors.primary.withValues(alpha: 0.10),
                      colors.surface,
                    ),
                    selectedColor: colors.onSurface,
                    title: Text(
                      item.$1,
                      style: TextStyle(
                        fontWeight: currentTag == item.$2
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    trailing: currentTag == item.$2
                        ? Icon(
                            Icons.check_circle_outline,
                            color: colors.primary,
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
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
