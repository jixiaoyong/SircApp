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
            title: Text(Languages.loading),
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
              content: Text(Languages.oldPasswordIncorrect),
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
        title: Languages.changePassword,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.dp, vertical: 10.dp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: Languages.oldPassword,
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
                hintText: Languages.newPassword,
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
                hintText: Languages.confirmPassword,
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
            Padding(
              padding: EdgeInsets.only(top: 50.dp),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: Size(0, 50.dp),
                    textStyle: TextStyle(fontSize: 16.dp),
                  ),
                  onPressed: !isButtonEnabled
                      ? null
                      : () {
                          notifier.changePassword();
                        },
                  child: Text(Languages.changePassword),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
