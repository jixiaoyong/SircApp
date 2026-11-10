import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/router/nav_keys.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/routes/app_router.dart';
import 'package:sirc/features/settings/controllers/settings_controller.dart';
import 'package:sirc/utils/size_extension.dart' as size_ext;

import 'data/common_data.dart';

/// a finance $ banking app
/// UI copy from https://hbimg.huabanimg.com/71e943643aac8a17dedaee0445a0e27aec8023d212e8d8-5fkAOb
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
    // extended_image creates cacheimage non-recursively; its parent may not
    // exist on a fresh macOS installation.
    final cacheDirectory = await getTemporaryDirectory();
    await cacheDirectory.create(recursive: true);
  }
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      routerConfig: ref.watch(appRouterProvider),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: "Sirc App",
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocale.supportedLocales,
      locale: locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final overlay = Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark;
        SystemChrome.setSystemUIOverlayStyle(
          overlay.copyWith(statusBarColor: Colors.transparent),
        );
        // 页面使用完整窗口宽度，控件尺寸不随窗口宽度缩放。
        CommonData.realScreenWidth = mediaQuery.size.width;
        size_ext.SizeExtension.dpScale = 1;

        return child ?? const SizedBox();
      },
    );
  }
}
