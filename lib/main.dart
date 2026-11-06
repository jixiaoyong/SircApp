
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'package:flutter_ume/flutter_ume.dart'; // UME 框架
// import 'package:flutter_ume_kit_console/flutter_ume_kit_console.dart'; // debugPrint 插件包
// import 'package:flutter_ume_kit_device/flutter_ume_kit_device.dart'; // 设备信息插件包
// import 'package:flutter_ume_kit_perf/flutter_ume_kit_perf.dart'; // 性能插件包
// import 'package:flutter_ume_kit_show_code/flutter_ume_kit_show_code.dart'; // 代码查看插件包
// import 'package:flutter_ume_kit_ui/flutter_ume_kit_ui.dart'; // UI 插件包
import 'package:get/get.dart';
import 'package:sirc/data/languages.dart';
import 'package:sirc/utils/size_extension.dart' as size_ext;

import 'components/not_found/not_found_view.dart';
import 'data/common_date.dart';
import 'routes/app_pages.dart';

/// a finance $ banking app
/// UI copy from https://hbimg.huabanimg.com/71e943643aac8a17dedaee0445a0e27aec8023d212e8d8-5fkAOb
void main() {
  const myApp = MyApp();

  // LogUtils.forceOpenLog();

  // if (kDebugMode) {
  //   PluginManager.instance // 注册插件
  //     ..register(const WidgetInfoInspector())
  //     ..register(const WidgetDetailInspector())
  //     ..register(const ColorSucker())
  //     ..register(AlignRuler())
  //     ..register(Performance())
  //     ..register(const ShowCode())
  //     ..register(const MemoryInfoPage())
  //     ..register(CpuInfoPage())
  //     ..register(const DeviceInfoPanel())
  //     ..register(Console());
  //   runApp(const UMEWidget(child: myApp, enable: true)); // 初始化
  // } else {
  runApp(myApp);
  // }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemUiOverlayStyle uiStyle = SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(uiStyle);

    return ScreenUtilInit(
      designSize: const Size(375, 666),
      builder: (context, _) {
        return GetMaterialApp(
          title: "Sirc App",
          onUnknownRoute: (RouteSettings settings) {
            return MaterialPageRoute(
              builder: (context) => const NotFoundPage(),
            );
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale("en", ""),
            Locale("zh", "CN"),
          ],
          locale: Get.deviceLocale,
          fallbackLocale: const Locale("en", "US"),
          translations: Languages(),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          theme: Theme.of(context).copyWith(
            primaryColor: Colors.white,
          ),
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
                          color: Colors.black.withOpacity(0.08),
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
