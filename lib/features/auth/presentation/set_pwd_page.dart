import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/common_text_button.dart';

/*
* @description: Set Password Page (Refactored to Riverpod & Clean Architecture)
* need pass the userName with key: [CommonKeys.USER_NAME]
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class SetPwdPage extends ConsumerStatefulWidget {
  final String? initialUserName;

  const SetPwdPage({super.key, this.initialUserName});

  @override
  ConsumerState<SetPwdPage> createState() => _SetPwdPageState();
}

class _SetPwdPageState extends ConsumerState<SetPwdPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String? userName = widget.initialUserName;
      if (userName == null) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Map && args.containsKey(CommonKeys.USER_NAME)) {
          userName = args[CommonKeys.USER_NAME] as String?;
        }
      }
      if (userName != null) {
        ref.read(setPwdControllerProvider.notifier).setUserName(userName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 监听重置结果副作用
    ref.listen<SetPwdState>(setPwdControllerProvider, (previous, next) {
      if (previous?.isWaitSetPwdResult != true && next.isWaitSetPwdResult) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text("Loading...".tr),
            content: SizedBox(
              height: 50.dp,
              width: 50.dp,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      } else if (previous?.isWaitSetPwdResult == true && !next.isWaitSetPwdResult) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (previous?.isSuccess != next.isSuccess && next.isSuccess == true) {
        Navigator.of(context).pop(true);
      }
    });

    final state = ref.watch(setPwdControllerProvider);
    final notifier = ref.read(setPwdControllerProvider.notifier);
    final marginBetweenFields = 30.dp;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New Password".tr,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.dp),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: marginBetweenFields),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.dp),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  )
                ],
                color: Colors.white,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Password".tr,
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.black12, width: 0),
                  ),
                  labelText: "Password".tr,
                  errorText: state.userPwdError,
                  suffixIcon: const Icon(
                    Icons.lock_outlined,
                    color: Colors.grey,
                  ),
                ),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                onChanged: (value) {
                  notifier.setUserPwd(value);
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: marginBetweenFields),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.dp),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  )
                ],
                color: Colors.white,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Confirm Password".tr,
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.black12, width: 0),
                  ),
                  labelText: "Confirm Password".tr,
                  errorText: state.userConfirmPwdError,
                  suffixIcon: const Icon(
                    Icons.lock_outlined,
                    color: Colors.grey,
                  ),
                ),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                onChanged: (value) {
                  notifier.setUserConfirmPwd(value);
                },
              ),
            ),
            CommonTextButton(
              isButtonEnabled: state.isUserInputValid,
              onTap: () {
                notifier.resetPwd();
              },
              text: "Submit".tr,
            ),
          ],
        ),
      ),
    );
  }
}
