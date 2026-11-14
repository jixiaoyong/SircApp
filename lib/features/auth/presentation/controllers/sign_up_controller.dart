import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sirc/features/auth/data/auth_repository.dart';
import 'package:sirc/features/auth/presentation/controllers/sign_in_controller.dart';
import 'package:sirc/mock/mock_utils.dart';
import 'package:sirc/utils/username_pwd_utils.dart';

part 'sign_up_controller.g.dart';

class SignUpState {
  final String userName;
  final String userEmail;
  final String userPwd;
  final String userConfirmPwd;
  final String? userNameError;
  final String? userEmailError;
  final String? userPwdError;
  final String? userConfirmPwdError;
  final bool isLoading;
  final bool? isRegisterSuccess;
  final bool isUserInputValid;
  final List<(IconData, Color)> socialList;

  const SignUpState({
    this.userName = "",
    this.userEmail = "",
    this.userPwd = "",
    this.userConfirmPwd = "",
    this.userNameError,
    this.userEmailError,
    this.userPwdError,
    this.userConfirmPwdError,
    this.isLoading = false,
    this.isRegisterSuccess,
    this.isUserInputValid = false,
    this.socialList = const [],
  });

  SignUpState copyWith({
    String? userName,
    String? userEmail,
    String? userPwd,
    String? userConfirmPwd,
    String? Function()? userNameError,
    String? Function()? userEmailError,
    String? Function()? userPwdError,
    String? Function()? userConfirmPwdError,
    bool? isLoading,
    bool? Function()? isRegisterSuccess,
    bool? isUserInputValid,
    List<(IconData, Color)>? socialList,
  }) {
    return SignUpState(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPwd: userPwd ?? this.userPwd,
      userConfirmPwd: userConfirmPwd ?? this.userConfirmPwd,
      userNameError: userNameError != null
          ? userNameError()
          : this.userNameError,
      userEmailError: userEmailError != null
          ? userEmailError()
          : this.userEmailError,
      userPwdError: userPwdError != null ? userPwdError() : this.userPwdError,
      userConfirmPwdError: userConfirmPwdError != null
          ? userConfirmPwdError()
          : this.userConfirmPwdError,
      isLoading: isLoading ?? this.isLoading,
      isRegisterSuccess: isRegisterSuccess != null
          ? isRegisterSuccess()
          : this.isRegisterSuccess,
      isUserInputValid: isUserInputValid ?? this.isUserInputValid,
      socialList: socialList ?? this.socialList,
    );
  }
}

@riverpod
class SignUpController extends _$SignUpController {
  @override
  SignUpState build() {
    return SignUpState(socialList: MockUtils.socialList);
  }

  void setUserName(String value) {
    final error = UsernamePwdUtils.checkUserName(value);
    final isValid = _checkAllValid(
      nameError: error,
      emailError: state.userEmailError,
      pwdError: state.userPwdError,
      confirmPwdError: state.userConfirmPwdError,
      name: value,
      email: state.userEmail,
      pwd: state.userPwd,
      confirmPwd: state.userConfirmPwd,
    );
    state = state.copyWith(
      userName: value,
      userNameError: () => error,
      isUserInputValid: isValid,
    );
  }

  void setUserEmail(String value) {
    final error = UsernamePwdUtils.checkUserEmail(value);
    final isValid = _checkAllValid(
      nameError: state.userNameError,
      emailError: error,
      pwdError: state.userPwdError,
      confirmPwdError: state.userConfirmPwdError,
      name: state.userName,
      email: value,
      pwd: state.userPwd,
      confirmPwd: state.userConfirmPwd,
    );
    state = state.copyWith(
      userEmail: value,
      userEmailError: () => error,
      isUserInputValid: isValid,
    );
  }

  void setUserPwd(String value) {
    final pwdError = UsernamePwdUtils.checkPassword(
      value,
      confirmPwd: state.userConfirmPwd,
    );
    final confirmError = UsernamePwdUtils.checkPassword(
      state.userConfirmPwd,
      confirmPwd: value,
    );
    final isValid = _checkAllValid(
      nameError: state.userNameError,
      emailError: state.userEmailError,
      pwdError: pwdError,
      confirmPwdError: confirmError,
      name: state.userName,
      email: state.userEmail,
      pwd: value,
      confirmPwd: state.userConfirmPwd,
    );
    state = state.copyWith(
      userPwd: value,
      userPwdError: () => pwdError,
      userConfirmPwdError: () => confirmError,
      isUserInputValid: isValid,
    );
  }

  void setUserConfirmPwd(String value) {
    final confirmError = UsernamePwdUtils.checkPassword(
      value,
      confirmPwd: state.userPwd,
    );
    final pwdError = UsernamePwdUtils.checkPassword(
      state.userPwd,
      confirmPwd: value,
    );
    final isValid = _checkAllValid(
      nameError: state.userNameError,
      emailError: state.userEmailError,
      pwdError: pwdError,
      confirmPwdError: confirmError,
      name: state.userName,
      email: state.userEmail,
      pwd: state.userPwd,
      confirmPwd: value,
    );
    state = state.copyWith(
      userConfirmPwd: value,
      userConfirmPwdError: () => confirmError,
      userPwdError: () => pwdError,
      isUserInputValid: isValid,
    );
  }

  bool _checkAllValid({
    required String? nameError,
    required String? emailError,
    required String? pwdError,
    required String? confirmPwdError,
    required String name,
    required String email,
    required String pwd,
    required String confirmPwd,
  }) {
    if (nameError != null ||
        emailError != null ||
        pwdError != null ||
        confirmPwdError != null) {
      return false;
    }
    if (name.isEmpty || email.isEmpty || pwd.isEmpty || confirmPwd.isEmpty) {
      return false;
    }
    return pwd == confirmPwd;
  }

  bool isUserNameAndPwdValid() {
    return _checkAllValid(
      nameError: state.userNameError,
      emailError: state.userEmailError,
      pwdError: state.userPwdError,
      confirmPwdError: state.userConfirmPwdError,
      name: state.userName,
      email: state.userEmail,
      pwd: state.userPwd,
      confirmPwd: state.userConfirmPwd,
    );
  }

  Future<void> register({Duration? mockDelay}) async {
    if (!isUserNameAndPwdValid()) return;

    state = state.copyWith(isLoading: true, isRegisterSuccess: () => null);

    final repo = ref.read(authRepositoryProvider);
    final success = await repo.register(
      state.userName,
      state.userEmail,
      state.userPwd,
      mockDelay: mockDelay,
    );

    // 注册成功，同步更新登录界面的预填充账号
    if (success) {
      ref.read(signInControllerProvider.notifier).setUserName(state.userName);
      ref.read(signInControllerProvider.notifier).setUserPwd(state.userPwd);
    }

    state = state.copyWith(isLoading: false, isRegisterSuccess: () => success);
  }

  void resetRegisterStatus() {
    state = state.copyWith(isRegisterSuccess: () => null);
  }

  void logUpWith((IconData, Color) item) {}
}

typedef SignUpNotifier = SignUpController;
