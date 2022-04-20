import 'package:get/get.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/
class MainAppLogic extends GetxController {
  var userName = ''.obs;

  void setUserInfo(String? name) {
    userName.value = name ?? "JI,XIAOYONG";
  }
}
