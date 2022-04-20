import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'sign_up_logic.dart';

/*
* @description: routes for app pages
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/
class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(SignUpLogic());
    final state = Get.find<SignUpLogic>().state;

    return Container();
  }
}
