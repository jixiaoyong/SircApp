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
import 'package:sirc/utils/size_extension.dart' as size_ext;

import 'package:sirc/routes/app_router.dart';
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
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          theme: AppTheme.lightTheme,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            final screenWidth = mediaQuery.size.width;
            final screenHeight = mediaQuery.size.height;

            // 判定是否处于 Web 宽屏模式（宽大于高且宽度超出普通手机 430px）
            final isWebWideScreen =
                kIsWeb && (screenWidth > screenHeight && screenWidth > 430);

            // 如果处于 Web 宽屏模式，自适应居中在 360~430 之间；拉窄后自动 100% 满屏无缝展示
            final double appWidth = isWebWideScreen
                ? (screenHeight * 9 / 16).clamp(360.0, 430.0)
                : screenWidth;

            // 实时响应窗口尺寸缩放与内部组件联动
            CommonData.realScreenWidth = appWidth;
            size_ext.SizeExtension.dpScale = appWidth / screenWidth;

            if (isWebWideScreen) {
              return Scaffold(
                backgroundColor: const Color(0xFFF1F5F9),
                body: Center(
                  child: Container(
                    width: appWidth,
                    height: screenHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRect(
                      child: MediaQuery(
                        data: mediaQuery.copyWith(
                          size: Size(appWidth, screenHeight),
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
