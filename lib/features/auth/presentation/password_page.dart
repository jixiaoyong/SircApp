import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/one_title_with_back_button_appbar.dart';

/*
* @description: Password Page (Refactored to Riverpod & Clean Architecture)
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class PasswordPage extends ConsumerWidget {
  const PasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    ref.listen<PasswordState>(passwordControllerProvider, (previous, next) {
      if (previous?.isLoading != true && next.isLoading) {
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
      } else if (previous?.isLoading == true && !next.isLoading) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (previous?.isSuccess != next.isSuccess && next.isSuccess != null) {
        if (next.isSuccess == true) {
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("原密码不正确或修改失败".tr),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });

    final state = ref.watch(passwordControllerProvider);
    final notifier = ref.read(passwordControllerProvider.notifier);
    final isValidError = state.errorMessage;
    final isButtonEnabled = isValidError == null;

    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(
        title: "Change Password".tr,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.dp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Old Password".tr,
                border: const OutlineInputBorder(),
                suffix: GestureDetector(
                  onLongPress: () {
                    notifier.setOldPasswordVisible(true);
                  },
                  onLongPressEnd: (_) {
                    notifier.setOldPasswordVisible(false);
                  },
                  child: const Icon(Icons.remove_red_eye_outlined),
                ),
              ),
              maxLines: 1,
              keyboardType: TextInputType.visiblePassword,
              obscureText: !state.isOldPasswordVisible,
              onChanged: (value) {
                notifier.setOldPassword(value);
              },
            ),
            Container(
              height: 20.dp,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: "New Password".tr,
                border: const OutlineInputBorder(),
                errorText: isValidError,
                suffix: GestureDetector(
                  onLongPress: () {
                    notifier.setNewPasswordVisible(true);
                  },
                  onLongPressEnd: (_) {
                    notifier.setNewPasswordVisible(false);
                  },
                  child: const Icon(Icons.remove_red_eye_outlined),
                ),
              ),
              maxLines: 1,
              keyboardType: TextInputType.visiblePassword,
              obscureText: !state.isNewPasswordVisible,
              onChanged: (value) {
                notifier.setNewPassword(value);
              },
            ),
            Container(
              height: 20.dp,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: "Confirm Password".tr,
                errorText: isValidError,
                border: const OutlineInputBorder(),
                suffix: GestureDetector(
                  onLongPress: () {
                    notifier.setConfirmPasswordVisible(true);
                  },
                  onLongPressEnd: (_) {
                    notifier.setConfirmPasswordVisible(false);
                  },
                  child: const Icon(Icons.remove_red_eye_outlined),
                ),
              ),
              maxLines: 1,
              keyboardType: TextInputType.visiblePassword,
              obscureText: !state.isConfirmPasswordVisible,
              onChanged: (value) {
                notifier.setConfirmPassword(value);
              },
            ),
            Container(
              height: 50.dp,
              width: double.infinity,
              margin: EdgeInsets.only(top: 50.dp),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.dp),
                border: !isButtonEnabled ? Border.all(color: Colors.grey) : null,
                gradient: !isButtonEnabled
                    ? null
                    : LinearGradient(
                        colors: [Colors.blue, Colors.purple.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              ),
              child: GestureDetector(
                onTap: !isButtonEnabled
                    ? null
                    : () {
                        notifier.changePassword();
                      },
                child: Center(
                  child: Text(
                    "Change Password".tr,
                    style: TextStyle(
                      color: !isButtonEnabled ? Colors.grey : Colors.white,
                      fontSize: 16.dp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
