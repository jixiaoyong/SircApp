import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
* @description: common app bar with one title and back button
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class OneTitleWithBackButtonAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  const OneTitleWithBackButtonAppBar({
    super.key,
    this.title = '',
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      leading: GestureDetector(
        child: const Icon(Icons.arrow_back, color: Colors.black),
        onTap: () {
          Get.back();
        },
      ),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
