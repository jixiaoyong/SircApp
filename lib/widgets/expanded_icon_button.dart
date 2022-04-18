import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sirc/utils/size_extension.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class ExpandedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double height;
  final double maxWidth;
  final List<Color> colors;
  final String text;
  double? minWidth;
  bool? isExpanded = false;

  ExpandedIconButton(
      {Key? key,
      required this.icon,
      required this.onPressed,
      required this.height,
      required this.maxWidth,
      this.minWidth,
      required this.colors,
      required this.text,
      this.isExpanded})
      : super(key: key) {
    minWidth ??= height;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: isExpanded == true ? maxWidth : minWidth,
      padding:
          isExpanded == true ? EdgeInsets.all(0.1 * height) : EdgeInsets.zero,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(height / 2)),
      child: GestureDetector(
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isExpanded == true)
              Padding(
                padding: EdgeInsets.only(left: 0.5 * height),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                  ),
                ),
              ),
            if (isExpanded == true) const Spacer(),
            Container(
              height: height * 0.9,
              width: height * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isExpanded == true ? Colors.white : Colors.transparent,
              ),
              child: Icon(
                icon,
                color: isExpanded == true ? colors[0] : Colors.white,
                size: height * 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
