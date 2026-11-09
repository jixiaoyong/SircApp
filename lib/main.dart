import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/router/nav_keys.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/routes/app_router.dart';
import 'package:sirc/utils/size_extension.dart' as size_ext;

import 'data/common_data.dart';

/// a finance $ banking app
/// UI copy from https://hbimg.huabanimg.com/71e943643aac8a17dedaee0445a0e27aec8023d212e8d8-5fkAOb
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemUiOverlayStyle uiStyle = SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(uiStyle);

    final locale = ref.watch(localeProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 666),
      builder: (context, _) {
        return MaterialApp.router(
          routerConfig: appRouter,
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
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            // 使用可用窗口宽度切换布局，不将页面缩放成手机预览画布。
            const maxContentWidth = 1200.0;
            const isWeb = kIsWeb;
            final screenWidth = mediaQuery.size.width;
            final screenHeight = mediaQuery.size.height;
            final appWidth = screenWidth.clamp(0.0, maxContentWidth);

            CommonData.realScreenWidth = appWidth;
            size_ext.SizeExtension.dpScale = 1;

            if (isWeb && screenWidth > maxContentWidth) {
              return ColoredBox(
                color: const Color(0xFFF1F5F9),
                child: Center(
                  child: SizedBox(
                    width: maxContentWidth,
                    height: screenHeight,
                    child: ColoredBox(
                      color: Colors.white,
                      child: MediaQuery(
                        data: mediaQuery.copyWith(
                          size: Size(maxContentWidth, screenHeight),
                        ),
                        child: child ?? const SizedBox(),
                      ),
                    ),
                  ),
                ),
              );
            }

            return child ?? const SizedBox();
          },
        );
      },
    );
  }
}
