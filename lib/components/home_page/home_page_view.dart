
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/utils/color_extension.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/line_graph.dart';
import 'package:sirc/widgets/title_text.dart';

import 'home_page_logic.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(HomePageLogic());
    final state = Get.find<HomePageLogic>().state;

    return Obx(() {
      return SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.dp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const TitleText(text: "Dashboard"),
                    Expanded(child: Container()),
                    Padding(
                      padding: EdgeInsets.only(right: 10.dp),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50.dp),
                        child: Image.network(
                          "https://img2.doubanio.com/view/group_topic/l/public/p486842201.webp",
                          width: 50.dp,
                          height: 50.dp,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 20.dp),
                  height: 200.dp,
                  child: Stack(
                    children: [
                      PageView.builder(
                        itemBuilder: (context, index) {
                          return state.banks[index];
                        },
                        itemCount: state.banks.length,
                        onPageChanged: (index) {
                          logic.setBankIndex(index);
                        },
                      ),
                      Positioned(
                          bottom: 10.dp,
                          right: 0,
                          left: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                List.generate(state.banks.length, (index) {
                              return Container(
                                width: 10.dp,
                                height: 10.dp,
                                margin: EdgeInsets.symmetric(horizontal: 5.dp),
                                decoration: BoxDecoration(
                                    color:
                                        (state.currentBankIndex.value == index
                                            ? "#ff871094"
                                            : "#ffb6c6d5")
                                            .hexToColor
                                            .withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(10.dp)),
                              );
                            }),
                          ))
                    ],
                  ),
                ),
                const TitleText(text: "February"),
                SizedBox(
                  height: 200.dp,
                  width: double.infinity,
                  child: LineGraph(data: state.dataChange,),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const TitleText(text: "Transcations"),
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
                                    ? "Money Send"
                                    : "Money Recharge",
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
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
