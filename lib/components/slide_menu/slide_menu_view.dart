import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/utils/color_extension.dart';
import 'package:sirc/utils/size_extension.dart';

import 'slide_menu_logic.dart';

/*
* @description: Slide Menu
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class SlideMenuPage extends StatefulWidget {
  Widget child;

  SlideMenuPage({Key? key, required this.child}) : super(key: key);

  @override
  State<SlideMenuPage> createState() => _SlideMenuPageState();
}

class _SlideMenuPageState extends State<SlideMenuPage>
    with SingleTickerProviderStateMixin {
  final logic = Get.put(SlideMenuLogic());
  final state = Get.find<SlideMenuLogic>().state;

  late AnimationController _controller;
  double _percentage = 0;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _controller.addListener(() {
      setState(() {
        _percentage = _controller.value;
      });
    });
    logic.onMenuTap = (isOpen) {
      if (isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double _screenWidth = screenSize.width;
    double _screenHeight = screenSize.height;

    return Material(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.only(left: 30.dp),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                "#ffc19bff".hexToColor,
                "#ff7784ff".hexToColor,
              ], begin: Alignment.bottomLeft, end: Alignment.topRight)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20.dp),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.dp),
                      child: Image.network(
                        "https://img2.doubanio.com/view/group_topic/l/public/p486842201.webp",
                        width: 70.dp,
                        height: 70.dp,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.dp, bottom: 12.dp),
                    child: Text(
                      "JI,XIAOYONG",
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ),
                  Text(
                    "jixiaoyong1995@gmail.com",
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                  Padding(padding: EdgeInsets.all(20.dp)),
                  ...state.slideMenuList.map((item) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10.dp),
                      child: Row(
                        children: [
                          Icon(
                            item.first,
                            color: Colors.white,
                          ),
                          Text(
                            " ${item.second}",
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    );
                  }),
                  Padding(padding: EdgeInsets.all(50.dp)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 80.dp,
            left: 25.dp,
            child: GestureDetector(
              onTap: () {
                _controller.reverse();
              },
              child: Container(
                width: 50.dp,
                height: 50.dp,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50.dp),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white.withOpacity(0.7),
                          blurRadius: 15.dp,
                          spreadRadius: 0.5)
                    ]),
                child: Icon(
                  Icons.exit_to_app_outlined,
                  color: "#ff7784ff".hexToColor,
                ),
              ),
            ),
          ),
          Transform(
            transform: Matrix4.identity()
              // translate y  = (height - child.height*scaleValue) / 2
              ..translate(_screenWidth * 0.55 * _percentage,
                  0.18 * _percentage * _screenHeight)
              ..scale(1.0 - (_percentage * 0.36)),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(_percentage * 20.dp)),
            ),
          ),
          Transform(
            transform: Matrix4.identity()
              ..translate(_screenWidth * 0.6 * _percentage,
                  0.15 * _percentage * _screenHeight)
              ..scale(1.0 - (_percentage * 0.3)),
            child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: "#ffc19bff".hexToColor.withOpacity(0.7),
                    blurRadius: 15.dp,
                    offset: Offset(-5.dp, 5.dp),
                    spreadRadius: 5.dp)
              ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_percentage * 20.dp),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
