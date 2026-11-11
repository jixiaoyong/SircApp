import 'package:flutter/material.dart';
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
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: choices.length,
        itemBuilder: (context, index) {
          final (mode, label) = choices[index];
          final selected = current == mode;
          return ListTile(
            key: ValueKey('theme-${mode.name}'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            tileColor: colors.surface,
            selected: selected,
            selectedColor: colors.onSurface,
            title: Text(label),
            trailing: selected
                ? Icon(Icons.check_circle_outline, color: colors.onSurface)
                : null,
            onTap: () =>
                ref.read(themeModeProvider.notifier).setThemeMode(mode),
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
