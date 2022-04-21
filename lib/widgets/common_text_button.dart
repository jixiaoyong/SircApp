import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sirc/utils/size_extension.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class CommonTextButton extends StatelessWidget {
  const CommonTextButton({
    Key? key,
    required this.isButtonEnabled,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  final bool isButtonEnabled;
  final GestureTapCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !isButtonEnabled ? null : onTap,
      child: Container(
        height: 50.dp,
        margin: EdgeInsets.only(top: 30.dp, bottom: 50.dp),
        decoration: !isButtonEnabled
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8.dp),
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey, width: 1),
              )
            : BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade400.withOpacity(0.7),
                    Colors.deepPurpleAccent.shade400.withOpacity(0.7)
                  ],
                ),
                borderRadius: BorderRadius.circular(8.dp)),
        child: Center(
          child: Text(text,
              style: TextStyle(
                  color: !isButtonEnabled ? Colors.grey : Colors.white,
                  fontSize: 16.dp,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
