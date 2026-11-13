import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale.dart';
import '../../../widgets/one_title_with_back_button_appbar.dart';
import '../controllers/settings_controller.dart';

class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final current = ref.watch(themeModeProvider);
    final colors = Theme.of(context).colorScheme;
    final choices = [
      (ThemeMode.light, Languages.settings.themeLight),
      (ThemeMode.dark, Languages.settings.themeDark),
      (ThemeMode.system, Languages.settings.themeSystem),
    ];

    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(
        title: Languages.settings.appearance,
        onBack: onBack,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Material(
            key: const ValueKey('appearance-options-group'),
            color: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: colors.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var index = 0; index < choices.length; index++) ...[
                  if (index > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color:
                          current == choices[index - 1].$1 ||
                              current == choices[index].$1
                          ? Colors.transparent
                          : colors.onSurfaceVariant.withValues(alpha: 0.2),
                    ),
                  ListTile(
                    key: ValueKey('theme-${choices[index].$1.name}'),
                    minTileHeight: 48,
                    selected: current == choices[index].$1,
                    selectedTileColor: Color.alphaBlend(
                      colors.primary.withValues(alpha: 0.10),
                      colors.surface,
                    ),
                    selectedColor: colors.onSurface,
                    title: Text(
                      choices[index].$2,
                      style: TextStyle(
                        fontWeight: current == choices[index].$1
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    trailing: current == choices[index].$1
                        ? Icon(
                            Icons.check_circle_outline,
                            color: colors.primary,
                          )
                        : null,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(choices[index].$1),
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
