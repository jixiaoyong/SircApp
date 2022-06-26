import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/data/common_date.dart';
import 'package:sirc/gen_a/A.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/title_text.dart';

import 'initial_logic.dart';

/*
* @description: initial page
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class InitialPage extends StatelessWidget {
  final logic = Get.put(InitialLogic());
  final state = Get.find<InitialLogic>().state;
  final _pageController = PageController(initialPage: 0);
  var _hasCallGoMainPage = false;

  @override
  Widget build(BuildContext context) {
    var initialInfoLength = state.initialTips.length;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      child: Obx(() {
        var isFirst = state.isFirstInitial.value;
        // first splash page
        Widget? widget = Column(
          children: [
            const Spacer(),
            Center(child: Image.asset(A.assets_ic_launcher)),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              margin: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Center(
                  child: Text("假装这里有广告>>>",
                      style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.white.withOpacity(0.8)))),
            ),
          ],
        );
        if (true == isFirst) {
          // first initial page
          widget = SizedBox(
            width: CommonData.realScreenWidth,
            child: PageView.builder(
              controller: _pageController,
              itemBuilder: (context, index) {
                final item = state.initialTips[index];
                return Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.1, right: 20.dp, left: 20.dp),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        item.first,
                        height: screenHeight * 0.4,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(
                        height: 10.dp,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, subIndex) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 5.dp),
                              height: 10.dp,
                              width: 10.dp,
                              decoration: BoxDecoration(
                                  color: subIndex == index
                                      ? Colors.deepPurpleAccent
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(10.dp)),
                            );
                          },
                          itemCount: initialInfoLength,
                        ),
                      ),
                      TitleText(text: item.second),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.dp),
                        child: Text(
                          item.third,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15.sp,
                              height: 1.5),
                        ),
                      ),
                      Container(
                        child: initialInfoLength - 1 != index
                            ? GestureDetector(
                                onTap: () {
                                  _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut);
                                },
                                child: Container(
                                  height: 50.dp,
                                  width: 50.dp,
                                  margin: EdgeInsets.only(top: 30.dp),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(25.dp),
                                      gradient: const LinearGradient(colors: [
                                        Colors.purple,
                                        Colors.deepPurpleAccent
                                      ])),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  goMainPage();
                                },
                                child: Container(
                                  height: 50.dp,
                                  width: CommonData.realScreenWidth - 60.dp,
                                  margin: EdgeInsets.fromLTRB(
                                      30.dp, 30.dp, 30.dp, 0),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(15.dp),
                                      gradient: const LinearGradient(colors: [
                                        Colors.purple,
                                        Colors.deepPurpleAccent
                                      ])),
                                  child: Center(
                                    child: Text(
                                      "Get Start".tr,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20.sp),
                                    ),
                                  ),
                                ),
                              ),
                      )
                    ],
                  ),
                );
              },
              itemCount: initialInfoLength,
            ),
          );
        } else if (false == isFirst) {
          // empty page
          Future.delayed(const Duration(seconds: 5), () {
            goMainPage();
          });
        }
        return widget;
      }),
    );
  }

  Future<void> goMainPage() async {
    if (_hasCallGoMainPage) {
      return;
    }
    _hasCallGoMainPage = true;

    bool? isLoginSuccess = false;
    if (!logic.isUserLoggedIn()) {
      isLoginSuccess = await Get.toNamed(AppRoutes.SIGN_IN);
    } else {
      isLoginSuccess = true;
    }

    if (isLoginSuccess == true) {
      Get.offAndToNamed(AppRoutes.MAIN);
      logic.markAsNotFirstInitial();
    } else {
      _hasCallGoMainPage = false;
    }
  }
}
