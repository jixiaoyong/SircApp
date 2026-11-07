import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/auth/data/auth_repository.dart';
import 'package:sirc/mock/mock_utils.dart';
import 'package:sirc/utils/username_pwd_utils.dart';

// ============================================================================
// 1. Sign In State & Notifier
// ============================================================================

class SignInState {
  final String userName;
  final String userPwd;
  final String? userNameError;
  final String? userPwdError;
  final bool isLoading;
  final bool? isLoginSuccess;
  final bool isUserInputValid;
  final List<(IconData, Color)> socialList;

  const SignInState({
    this.userName = "",
    this.userPwd = "",
    this.userNameError,
    this.userPwdError,
    this.isLoading = false,
    this.isLoginSuccess,
    this.isUserInputValid = false,
    this.socialList = const [],
  });

  SignInState copyWith({
    String? userName,
    String? userPwd,
    String? Function()? userNameError,
    String? Function()? userPwdError,
    bool? isLoading,
    bool? Function()? isLoginSuccess,
    bool? isUserInputValid,
    List<(IconData, Color)>? socialList,
  }) {
    return SignInState(
      userName: userName ?? this.userName,
      userPwd: userPwd ?? this.userPwd,
      userNameError: userNameError != null ? userNameError() : this.userNameError,
      userPwdError: userPwdError != null ? userPwdError() : this.userPwdError,
      isLoading: isLoading ?? this.isLoading,
      isLoginSuccess: isLoginSuccess != null ? isLoginSuccess() : this.isLoginSuccess,
      isUserInputValid: isUserInputValid ?? this.isUserInputValid,
      socialList: socialList ?? this.socialList,
    );
  }
}

class SignInNotifier extends Notifier<SignInState> {
  @override
  SignInState build() {
    final rawSocial = MockUtils.socialList;
    final convertedSocial = rawSocial.map((e) => (e.first, e.second)).toList();
    return SignInState(socialList: convertedSocial);
  }

  /// 预填充测试账号（若本地未初始化，自动写入默认账号并在进入时加载）
  Future<void> initPresetAccount() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.initDefaultUserIfNeeded();

    final savedUserName = repo.getSavedUserName() ?? "jixiaoyong";
    const defaultPwd = "123456";

    setUserName(savedUserName);
    setUserPwd(defaultPwd);
  }

  void setUserName(String value) {
    final error = UsernamePwdUtils.checkUserName(value);
    final isValid = error == null && state.userPwdError == null && value.isNotEmpty && state.userPwd.isNotEmpty;
    state = state.copyWith(
      userName: value,
      userNameError: () => error,
      isUserInputValid: isValid,
    );
  }

  void setUserPwd(String value) {
    final error = UsernamePwdUtils.checkPassword(value);
    final isValid = state.userNameError == null && error == null && state.userName.isNotEmpty && value.isNotEmpty;
    state = state.copyWith(
      userPwd: value,
      userPwdError: () => error,
      isUserInputValid: isValid,
    );
  }

  bool isUserNameAndPwdValid() {
    return state.userNameError == null &&
        state.userPwdError == null &&
        state.userName.isNotEmpty &&
        state.userPwd.isNotEmpty;
  }

  Future<void> login({Duration? mockDelay}) async {
    if (!isUserNameAndPwdValid()) return;

    state = state.copyWith(isLoading: true, isLoginSuccess: () => null);

    final repo = ref.read(authRepositoryProvider);
    final success = await repo.login(
      state.userName,
      state.userPwd,
      mockDelay: mockDelay,
    );

    state = state.copyWith(
      isLoading: false,
      isLoginSuccess: () => success,
    );
  }

  void resetLoginStatus() {
    state = state.copyWith(isLoginSuccess: () => null);
  }

  void loginWith((IconData, Color) item) {
    // 社交登录扩展预留
  }
}

final signInControllerProvider =
    NotifierProvider<SignInNotifier, SignInState>(SignInNotifier.new);

// ============================================================================
// 2. Sign Up State & Notifier
// ============================================================================

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
      userNameError: userNameError != null ? userNameError() : this.userNameError,
      userEmailError: userEmailError != null ? userEmailError() : this.userEmailError,
      userPwdError: userPwdError != null ? userPwdError() : this.userPwdError,
      userConfirmPwdError: userConfirmPwdError != null ? userConfirmPwdError() : this.userConfirmPwdError,
      isLoading: isLoading ?? this.isLoading,
      isRegisterSuccess: isRegisterSuccess != null ? isRegisterSuccess() : this.isRegisterSuccess,
      isUserInputValid: isUserInputValid ?? this.isUserInputValid,
      socialList: socialList ?? this.socialList,
    );
  }
}

class SignUpNotifier extends Notifier<SignUpState> {
  @override
  SignUpState build() {
    final rawSocial = MockUtils.socialList;
    final convertedSocial = rawSocial.map((e) => (e.first, e.second)).toList();
    return SignUpState(socialList: convertedSocial);
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
    final pwdError = UsernamePwdUtils.checkPassword(value, confirmPwd: state.userConfirmPwd);
    final confirmError = UsernamePwdUtils.checkPassword(state.userConfirmPwd, confirmPwd: value);
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
    final confirmError = UsernamePwdUtils.checkPassword(value, confirmPwd: state.userPwd);
    final pwdError = UsernamePwdUtils.checkPassword(state.userPwd, confirmPwd: value);
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
    if (nameError != null || emailError != null || pwdError != null || confirmPwdError != null) {
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

    state = state.copyWith(
      isLoading: false,
      isRegisterSuccess: () => success,
    );
  }

  void resetRegisterStatus() {
    state = state.copyWith(isRegisterSuccess: () => null);
  }

  void logUpWith((IconData, Color) item) {}
}

final signUpControllerProvider =
    NotifierProvider<SignUpNotifier, SignUpState>(SignUpNotifier.new);

// ============================================================================
// 3. Forget Password State & Notifier
// ============================================================================

class ForgetPwdState {
  final String userEmail;
  final String verifyCode;
  final String? userEmailError;
  final bool isVerifyingCode;
  final int lastSendVerifyCodeTime;
  final bool isWaitingForVerifyCode;
  final bool? isVerifySuccess;

  static const int verifyCodeLength = 6;
  static const int verifyCodeDurationSecond = 60;

  const ForgetPwdState({
    this.userEmail = "",
    this.verifyCode = "",
    this.userEmailError,
    this.isVerifyingCode = false,
    this.lastSendVerifyCodeTime = 0,
    this.isWaitingForVerifyCode = false,
    this.isVerifySuccess,
  });

  ForgetPwdState copyWith({
    String? userEmail,
    String? verifyCode,
    String? Function()? userEmailError,
    bool? isVerifyingCode,
    int? lastSendVerifyCodeTime,
    bool? isWaitingForVerifyCode,
    bool? Function()? isVerifySuccess,
  }) {
    return ForgetPwdState(
      userEmail: userEmail ?? this.userEmail,
      verifyCode: verifyCode ?? this.verifyCode,
      userEmailError: userEmailError != null ? userEmailError() : this.userEmailError,
      isVerifyingCode: isVerifyingCode ?? this.isVerifyingCode,
      lastSendVerifyCodeTime: lastSendVerifyCodeTime ?? this.lastSendVerifyCodeTime,
      isWaitingForVerifyCode: isWaitingForVerifyCode ?? this.isWaitingForVerifyCode,
      isVerifySuccess: isVerifySuccess != null ? isVerifySuccess() : this.isVerifySuccess,
    );
  }
}

class ForgetPwdNotifier extends Notifier<ForgetPwdState> {
  @override
  ForgetPwdState build() => const ForgetPwdState();

  void setUserEmail(String value) {
    final error = UsernamePwdUtils.checkUserEmail(value);
    state = state.copyWith(
      userEmail: value,
      userEmailError: () => error,
    );
  }

  void setVerifyCode(String value) {
    state = state.copyWith(verifyCode: value);
  }

  void updateCountdown(int seconds) {
    state = state.copyWith(lastSendVerifyCodeTime: seconds);
  }

  void verifyEmail() {
    state = state.copyWith(isWaitingForVerifyCode: true);
  }

  bool isEmailAndVerifyCodeValid() {
    return state.userEmailError == null &&
        state.userEmail.isNotEmpty &&
        state.verifyCode.length == ForgetPwdState.verifyCodeLength;
  }

  Future<void> verifyEmailAndResetPwd({Duration? mockDelay}) async {
    if (!isEmailAndVerifyCodeValid()) return;

    state = state.copyWith(isVerifyingCode: true, isVerifySuccess: () => null);

    final repo = ref.read(authRepositoryProvider);
    final success = await repo.verifyResetCode(
      state.userEmail,
      state.verifyCode,
      mockDelay: mockDelay,
    );

    state = state.copyWith(
      isVerifyingCode: false,
      isVerifySuccess: () => success,
    );
  }

  void resetVerifyStatus() {
    state = state.copyWith(isVerifySuccess: () => null);
  }
}

final forgetPwdControllerProvider =
    NotifierProvider<ForgetPwdNotifier, ForgetPwdState>(ForgetPwdNotifier.new);

// ============================================================================
// 4. Set Password State & Notifier
// ============================================================================

class SetPwdState {
  final String userName;
  final String userPwd;
  final String userConfirmPwd;
  final String? userPwdError;
  final String? userConfirmPwdError;
  final bool isUserInputValid;
  final bool isWaitSetPwdResult;
  final bool? isSuccess;

  const SetPwdState({
    this.userName = "",
    this.userPwd = "",
    this.userConfirmPwd = "",
    this.userPwdError,
    this.userConfirmPwdError,
    this.isUserInputValid = false,
    this.isWaitSetPwdResult = false,
    this.isSuccess,
  });

  SetPwdState copyWith({
    String? userName,
    String? userPwd,
    String? userConfirmPwd,
    String? Function()? userPwdError,
    String? Function()? userConfirmPwdError,
    bool? isUserInputValid,
    bool? isWaitSetPwdResult,
    bool? Function()? isSuccess,
  }) {
    return SetPwdState(
      userName: userName ?? this.userName,
      userPwd: userPwd ?? this.userPwd,
      userConfirmPwd: userConfirmPwd ?? this.userConfirmPwd,
      userPwdError: userPwdError != null ? userPwdError() : this.userPwdError,
      userConfirmPwdError: userConfirmPwdError != null ? userConfirmPwdError() : this.userConfirmPwdError,
      isUserInputValid: isUserInputValid ?? this.isUserInputValid,
      isWaitSetPwdResult: isWaitSetPwdResult ?? this.isWaitSetPwdResult,
      isSuccess: isSuccess != null ? isSuccess() : this.isSuccess,
    );
  }
}

class SetPwdNotifier extends Notifier<SetPwdState> {
  @override
  SetPwdState build() => const SetPwdState();

  void setUserName(String name) {
    state = state.copyWith(userName: name);
  }

  void setUserPwd(String value) {
    final pwdError = UsernamePwdUtils.checkPassword(value, confirmPwd: state.userConfirmPwd);
    final confirmError = UsernamePwdUtils.checkPassword(state.userConfirmPwd, confirmPwd: value);
    final isValid = pwdError == null && confirmError == null && value.isNotEmpty && state.userConfirmPwd.isNotEmpty && value == state.userConfirmPwd;
    state = state.copyWith(
      userPwd: value,
      userPwdError: () => pwdError,
      userConfirmPwdError: () => confirmError,
      isUserInputValid: isValid,
    );
  }

  void setUserConfirmPwd(String value) {
    final confirmError = UsernamePwdUtils.checkPassword(value, confirmPwd: state.userPwd);
    final pwdError = UsernamePwdUtils.checkPassword(state.userPwd, confirmPwd: value);
    final isValid = pwdError == null && confirmError == null && state.userPwd.isNotEmpty && value.isNotEmpty && state.userPwd == value;
    state = state.copyWith(
      userConfirmPwd: value,
      userConfirmPwdError: () => confirmError,
      userPwdError: () => pwdError,
      isUserInputValid: isValid,
    );
  }

  bool isUserNameAndPwdValid() {
    return state.userPwdError == null &&
        state.userConfirmPwdError == null &&
        state.userPwd.isNotEmpty &&
        state.userConfirmPwd.isNotEmpty &&
        state.userPwd == state.userConfirmPwd;
  }

  Future<void> resetPwd({Duration? mockDelay}) async {
    if (!isUserNameAndPwdValid()) return;

    state = state.copyWith(isWaitSetPwdResult: true, isSuccess: () => null);

    final repo = ref.read(authRepositoryProvider);
    final success = await repo.resetPassword(
      state.userName,
      state.userPwd,
      mockDelay: mockDelay,
    );

    state = state.copyWith(
      isWaitSetPwdResult: false,
      isSuccess: () => success,
    );
  }

  void resetSuccessStatus() {
    state = state.copyWith(isSuccess: () => null);
  }
}

final setPwdControllerProvider =
    NotifierProvider<SetPwdNotifier, SetPwdState>(SetPwdNotifier.new);

// ============================================================================
// 5. Password Page State & Notifier (修改密码)
// ============================================================================

class PasswordState {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  final bool isOldPasswordVisible;
  final bool isNewPasswordVisible;
  final bool isConfirmPasswordVisible;
  final String? errorMessage;
  final bool isLoading;
  final bool? isSuccess;

  const PasswordState({
    this.oldPassword = "",
    this.newPassword = "",
    this.confirmPassword = "",
    this.isOldPasswordVisible = false,
    this.isNewPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.errorMessage,
    this.isLoading = false,
    this.isSuccess,
  });

  PasswordState copyWith({
    String? oldPassword,
    String? newPassword,
    String? confirmPassword,
    bool? isOldPasswordVisible,
    bool? isNewPasswordVisible,
    bool? isConfirmPasswordVisible,
    String? Function()? errorMessage,
    bool? isLoading,
    bool? Function()? isSuccess,
  }) {
    return PasswordState(
      oldPassword: oldPassword ?? this.oldPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isOldPasswordVisible: isOldPasswordVisible ?? this.isOldPasswordVisible,
      isNewPasswordVisible: isNewPasswordVisible ?? this.isNewPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess != null ? isSuccess() : this.isSuccess,
    );
  }
}

class PasswordNotifier extends Notifier<PasswordState> {
  @override
  PasswordState build() => const PasswordState();

  void setOldPassword(String value) {
    state = state.copyWith(
      oldPassword: value,
      errorMessage: () => _validatePasswords(oldPwd: value),
    );
  }

  void setNewPassword(String value) {
    state = state.copyWith(
      newPassword: value,
      errorMessage: () => _validatePasswords(newPwd: value),
    );
  }

  void setConfirmPassword(String value) {
    state = state.copyWith(
      confirmPassword: value,
      errorMessage: () => _validatePasswords(confirmPwd: value),
    );
  }

  void setOldPasswordVisible(bool visible) {
    state = state.copyWith(isOldPasswordVisible: visible);
  }

  void setNewPasswordVisible(bool visible) {
    state = state.copyWith(isNewPasswordVisible: visible);
  }

  void setConfirmPasswordVisible(bool visible) {
    state = state.copyWith(isConfirmPasswordVisible: visible);
  }

  String? _validatePasswords({String? oldPwd, String? newPwd, String? confirmPwd}) {
    final oldP = oldPwd ?? state.oldPassword;
    final newP = newPwd ?? state.newPassword;
    final confirmP = confirmPwd ?? state.confirmPassword;

    if (oldP.isEmpty) {
      return "请先输入现有密码".tr;
    }
    if (newP.isEmpty) {
      return "请输入新密码".tr;
    }
    if (confirmP.isEmpty) {
      return "请输入确认新密码".tr;
    }
    if (newP != confirmP) {
      return "两次输入的密码不一致".tr;
    }
    if (newP.length < 6 || confirmP.length < 6) {
      return "密码长度不能小于6位".tr;
    }
    return null;
  }

  String? get errorMessage => _validatePasswords();

  Future<void> changePassword({Duration? mockDelay}) async {
    final error = _validatePasswords();
    if (error != null) {
      state = state.copyWith(errorMessage: () => error);
      return;
    }

    state = state.copyWith(isLoading: true, isSuccess: () => null);

    final repo = ref.read(authRepositoryProvider);
    final success = await repo.changePassword(
      state.oldPassword,
      state.newPassword,
      mockDelay: mockDelay,
    );

    state = state.copyWith(
      isLoading: false,
      isSuccess: () => success,
    );
  }

  void resetSuccessStatus() {
    state = state.copyWith(isSuccess: () => null);
  }
}

final passwordControllerProvider =
    NotifierProvider<PasswordNotifier, PasswordState>(PasswordNotifier.new);
