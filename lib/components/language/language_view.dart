import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/components/language/language_logic.dart';
import 'package:sirc/data/languages.dart';

/*
* @description: Slide Menu
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class LanguagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languages = Languages();
    LanguageLogic logic = Get.put(LanguageLogic());

    return Scaffold(
      appBar: AppBar(
        title: Text("Language".tr, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back, color: Colors.black),
          onTap: () {
            Get.back();
          },
        ),
      ),
      body: ListView.separated(
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(languages.languagesName[index].first),
              trailing:
                  "${Get.locale?.languageCode}_${Get.locale?.countryCode}" ==
                          languages.languagesName[index].second
                      ? const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        )
                      : null,
              onTap: () {
                var locationStrArr =
                    languages.languagesName[index].second.split("_");
                var locale = Locale(locationStrArr.first, locationStrArr.last);
                logic.updateLanguage(
                    locale, languages.languagesName[index].second);
                Get.back();
              },
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
          itemCount: languages.languagesName.length),
    );
  }
}
