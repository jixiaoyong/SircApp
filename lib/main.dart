import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_ume/flutter_ume.dart'; // UME 框架
import 'package:flutter_ume_kit_console/flutter_ume_kit_console.dart'; // debugPrint 插件包
import 'package:flutter_ume_kit_device/flutter_ume_kit_device.dart'; // 设备信息插件包
import 'package:flutter_ume_kit_perf/flutter_ume_kit_perf.dart'; // 性能插件包
import 'package:flutter_ume_kit_show_code/flutter_ume_kit_show_code.dart'; // 代码查看插件包
import 'package:flutter_ume_kit_ui/flutter_ume_kit_ui.dart'; // UI 插件包
import 'package:get/get.dart';
import 'package:sirc/data/languages.dart';
import 'package:sirc/utils/size_extension.dart' as sizeExt;

import 'data/common_date.dart';
import 'routes/app_pages.dart';
import 'utils/logger.dart';

/// a finance $ banking app
/// UI copy from https://hbimg.huabanimg.com/71e943643aac8a17dedaee0445a0e27aec8023d212e8d8-5fkAOb
void main() {
  const myApp = MyApp();

  if (kDebugMode) {
    PluginManager.instance // 注册插件
      ..register(const WidgetInfoInspector())..register(const WidgetDetailInspector())..register(const ColorSucker())..register(AlignRuler())..register(Performance())..register(const ShowCode())..register(const MemoryInfoPage())..register(CpuInfoPage())..register(const DeviceInfoPanel())..register(Console());
    runApp(const UMEWidget(child: myApp, enable: true)); // 初始化
  } else {
    runApp(myApp);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemUiOverlayStyle uiStyle = SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(uiStyle);

    // physical size, unit is pixel
    final size = window.physicalSize;
    // logical size, which is the size we want to use in flutter
    final widthLogical = size.width / window.devicePixelRatio;
    final heightLogical = size.height / window.devicePixelRatio;

    // consider to adapter the web screen which usually has a ultra width
    if (kIsWeb && widthLogical > heightLogical) {
      // make the available width to be the height*9/16
      final appWidth = heightLogical * 9 / 16;
      final horizontalPadding = (widthLogical - appWidth) / 2;

      sizeExt.SizeExtension.dpScale = appWidth / widthLogical;
      CommonData.realScreenWidth = appWidth;

      LogUtils.d(
          'widthLogical: $widthLogical, heightLogical: $heightLogical, appWidth: $appWidth, horizontalPadding: $horizontalPadding');

      return Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        color: Colors.grey.shade100,
        child: buildAppScreen(),
      );
    } else {
      CommonData.realScreenWidth = widthLogical;
      return buildAppScreen();
    }
    // return app;
  }

  ScreenUtilInit buildAppScreen() {
    return ScreenUtilInit(
        // setup the screen width be 375,then you can use number.dp to set the design size
        designSize: const Size(375, 666),
        builder: (context) {
          LogUtils.d("1.dp: ${1.dp}");

          return GetMaterialApp(
            title: "Sirc App",
            locale: Get.deviceLocale,
            fallbackLocale: const Locale("en", "US"),
            translations: Languages(),
            initialRoute: AppPages.INITIAL,
            getPages: AppPages.routes,
            theme: Theme.of(context).copyWith(primaryColor: Colors.white),
          ).build(context);
        });
  }
}
