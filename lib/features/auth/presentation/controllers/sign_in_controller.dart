import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sirc/features/auth/data/auth_repository.dart';
import 'package:sirc/mock/mock_utils.dart';
import 'package:sirc/utils/username_pwd_utils.dart';

part 'sign_in_controller.g.dart';

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
      userNameError: userNameError != null
          ? userNameError()
          : this.userNameError,
      userPwdError: userPwdError != null ? userPwdError() : this.userPwdError,
      isLoading: isLoading ?? this.isLoading,
      isLoginSuccess: isLoginSuccess != null
          ? isLoginSuccess()
          : this.isLoginSuccess,
      isUserInputValid: isUserInputValid ?? this.isUserInputValid,
      socialList: socialList ?? this.socialList,
    );
  }
}

@riverpod
class SignInController extends _$SignInController {
  @override
  SignInState build() {
    return SignInState(socialList: MockUtils.socialList);
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
    final isValid =
        error == null &&
        state.userPwdError == null &&
        value.isNotEmpty &&
        state.userPwd.isNotEmpty;
    state = state.copyWith(
      userName: value,
      userNameError: () => error,
      isUserInputValid: isValid,
    );
  }

  void setUserPwd(String value) {
    final error = UsernamePwdUtils.checkPassword(value);
    final isValid =
        state.userNameError == null &&
        error == null &&
        state.userName.isNotEmpty &&
        value.isNotEmpty;
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

    state = state.copyWith(isLoading: false, isLoginSuccess: () => success);
  }

  void resetLoginStatus() {
    state = state.copyWith(isLoginSuccess: () => null);
  }

  void loginWith((IconData, Color) item) {
    // 社交登录扩展预留
  }
}

typedef SignInNotifier = SignInController;
