import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/components/slide_menu/slide_menu_logic.dart';
import 'package:sirc/utils/color_extension.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/footlights_for_bank_card.dart';
import 'package:sirc/widgets/line_graph.dart';
import 'package:sirc/widgets/title_text.dart';

import 'home_page_logic.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(HomePageLogic());
    final state = Get.find<HomePageLogic>().state;
    final slideMenuLogic = Get.find<SlideMenuLogic>();

    return Obx(() {
      return SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.dp),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TitleText(text: "Dashboard".tr),
                    Expanded(child: Container()),
                    Padding(
                      padding: EdgeInsets.only(right: 10.dp),
                      child: GestureDetector(
                        onTap: () => slideMenuLogic.onMenuTap?.call(true),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.dp),
                          child: Image.network(
                            "https://img2.doubanio.com/view/group_topic/l/public/p486842201.webp",
                            width: 50.dp,
                            height: 50.dp,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 255.dp,
                child: Stack(
                  children: [
                    FootlightsForBankCard(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 40.dp, 0, 25.dp),
                      child: PageView.builder(
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.dp),
                            child: state.banks[index],
                          );
                        },
                        itemCount: state.banks.length,
                        onPageChanged: (index) {
                          logic.setBankIndex(index);
                        },
                      ),
                    ),
                    Positioned(
                        bottom: 30.dp,
                        right: 0,
                        left: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(state.banks.length, (index) {
                            return Container(
                              width: 10.dp,
                              height: 10.dp,
                              margin: EdgeInsets.symmetric(horizontal: 5.dp),
                              decoration: BoxDecoration(
                                  color: (state.currentBankIndex.value == index
                                          ? Colors.white
                                          : "#ffb6c6d5".hexToColor)
                                      .withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(10.dp)),
                            );
                          }),
                        ))
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.dp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleText(text: "February".tr),
                    SizedBox(
                      height: 200.dp,
                      width: double.infinity,
                      child: LineGraph(
                        data: state.dataChange,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TitleText(text: "Translations".tr),
                        const Spacer(),
                        GestureDetector(
                          child: const Icon(Icons.arrow_forward),
                          onTap: () {},
                        )
                      ],
                    ),
                    Container(
                      height: 150.dp,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.dp, horizontal: 15.dp),
                            child: Container(
                              width: 120.dp,
                              padding: EdgeInsets.all(10.dp),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.dp),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12.withOpacity(0.1),
                                        spreadRadius: 5.dp,
                                        blurRadius: 5.dp)
                                  ]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.run_circle_outlined,
                                    color: Colors.blue,
                                    size: 50.dp,
                                  ),
                                  Text(
                                    r"-$20",
                                    style: TextStyle(
                                        fontSize: 20.dp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  const Spacer(),
                                  Text(
                                    index % 2 == 0
                                        ? "Money Send".tr
                                        : "Money Recharge".tr,
                                    style: TextStyle(
                                        fontSize: 12.dp, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
