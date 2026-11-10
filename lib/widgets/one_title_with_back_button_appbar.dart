import 'package:flutter/material.dart';

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
  final VoidCallback? onBack;

  const OneTitleWithBackButtonAppBar({super.key, this.title = '', this.onBack});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      leading: GestureDetector(
        child: const Icon(Icons.arrow_back, color: Colors.black),
        onTap: () {
          if (onBack != null) {
            onBack!();
          } else {
            Navigator.of(context).maybePop();
          }
        },
      ),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
