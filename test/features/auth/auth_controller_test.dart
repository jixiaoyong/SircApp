import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/features/auth/data/auth_repository.dart';
import 'package:sirc/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sirc/utils/m5d_utils.dart';
import 'package:sirc/utils/username_pwd_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('UsernamePwdUtils 校验逻辑测试 (Dart 3 模式匹配)', () {
    test('用户名长度校验', () {
      expect(UsernamePwdUtils.checkUserName('ab'), isNotNull);
      expect(UsernamePwdUtils.checkUserName('12345678901'), isNotNull);
      expect(UsernamePwdUtils.checkUserName('jixiaoyong'), isNull);
    });

    test('密码与确认密码校验', () {
      // 密码过短
      expect(UsernamePwdUtils.checkPassword('12345'), isNotNull);
      // 密码过长
      expect(UsernamePwdUtils.checkPassword('1234567890123'), isNotNull);
      // 正常密码
      expect(UsernamePwdUtils.checkPassword('123456'), isNull);
      // 两次密码不一致
      expect(
        UsernamePwdUtils.checkPassword('123456', confirmPwd: '654321'),
        isNotNull,
      );
      // 两次密码一致
      expect(
        UsernamePwdUtils.checkPassword('123456', confirmPwd: '123456'),
        isNull,
      );
    });

    test('邮箱格式与长度校验', () {
      expect(UsernamePwdUtils.checkUserEmail('a@b'), isNotNull);
      expect(UsernamePwdUtils.checkUserEmail('invalid_email_format'), isNotNull);
      expect(UsernamePwdUtils.checkUserEmail('test@example.com'), isNull);
    });
  });

  group('AuthRepository MD5 校验与数据持久化测试', () {
    test('MD5 加密结果一致性', () {
      final md5_1 = Md5Utils.generateMd5('123456');
      final md5_2 = Md5Utils.generateMd5('123456');
      expect(md5_1, equals(md5_2));
      expect(md5_1, isNotEmpty);
    });

    test('initDefaultUserIfNeeded 成功预置默认测试账号', () async {
      final repo = container.read(authRepositoryProvider);
      await repo.initDefaultUserIfNeeded();

      expect(repo.getSavedUserName(), equals('jixiaoyong'));
      expect(repo.getSavedUserPwdMd5(), equals(Md5Utils.generateMd5('123456')));
    });

    test('登录逻辑：账号密码匹配登录成功，密码错误登录失败', () async {
      final repo = container.read(authRepositoryProvider);
      await repo.initDefaultUserIfNeeded();

      // 正确密码
      final loginSuccess = await repo.login('jixiaoyong', '123456', mockDelay: Duration.zero);
      expect(loginSuccess, isTrue);
      expect(repo.isUserLoggedIn(), isTrue);

      // 错误密码
      final loginFail = await repo.login('jixiaoyong', 'wrong_pwd', mockDelay: Duration.zero);
      expect(loginFail, isFalse);
    });

    test('注册逻辑：更新持久化数据与密码 MD5', () async {
      final repo = container.read(authRepositoryProvider);
      final success = await repo.register(
        'new_user',
        'new@test.com',
        'newpassword',
        mockDelay: Duration.zero,
      );

      expect(success, isTrue);
      expect(repo.getSavedUserName(), equals('new_user'));
      expect(repo.getSavedUserEmail(), equals('new@test.com'));
      expect(repo.getSavedUserPwdMd5(), equals(Md5Utils.generateMd5('newpassword')));
    });

    test('重置密码与修改密码', () async {
      final repo = container.read(authRepositoryProvider);
      await repo.initDefaultUserIfNeeded();

      // 修改密码：旧密码错误
      final changeFail = await repo.changePassword(
        'wrong_old_pwd',
        '654321',
        mockDelay: Duration.zero,
      );
      expect(changeFail, isFalse);

      // 修改密码：旧密码正确
      final changeSuccess = await repo.changePassword(
        '123456',
        '654321',
        mockDelay: Duration.zero,
      );
      expect(changeSuccess, isTrue);
      expect(repo.getSavedUserPwdMd5(), equals(Md5Utils.generateMd5('654321')));
    });
  });

  group('Riverpod Notifier 控制器状态流转测试', () {
    test('SignInNotifier: 预置账号加载与登录状态流转', () async {
      final notifier = container.read(signInControllerProvider.notifier);
      await notifier.initPresetAccount();

      final state = container.read(signInControllerProvider);
      expect(state.userName, equals('jixiaoyong'));
      expect(state.userPwd, equals('123456'));
      expect(state.isUserInputValid, isTrue);

      // 执行登录
      await notifier.login(mockDelay: Duration.zero);
      final loginState = container.read(signInControllerProvider);
      expect(loginState.isLoginSuccess, isTrue);
      expect(loginState.isLoading, isFalse);
    });

    test('SignUpNotifier: 表单输入校验与注册联动', () async {
      final notifier = container.read(signUpControllerProvider.notifier);

      notifier.setUserName('testuser');
      notifier.setUserEmail('test@domain.com');
      notifier.setUserPwd('password123');
      notifier.setUserConfirmPwd('password123');

      final state = container.read(signUpControllerProvider);
      expect(state.isUserInputValid, isTrue);
      expect(state.userNameError, isNull);
      expect(state.userPwdError, isNull);

      await notifier.register(mockDelay: Duration.zero);
      final registeredState = container.read(signUpControllerProvider);
      expect(registeredState.isRegisterSuccess, isTrue);

      // 注册成功后，SignIn 界面也已同步预填充账号
      final signInState = container.read(signInControllerProvider);
      expect(signInState.userName, equals('testuser'));
      expect(signInState.userPwd, equals('password123'));
    });

    test('ForgetPwdNotifier & SetPwdNotifier: 找回与重置密码', () async {
      final forgetNotifier = container.read(forgetPwdControllerProvider.notifier);
      forgetNotifier.setUserEmail('user@test.com');
      forgetNotifier.setVerifyCode('123456');

      expect(forgetNotifier.isEmailAndVerifyCodeValid(), isTrue);

      await forgetNotifier.verifyEmailAndResetPwd(mockDelay: Duration.zero);
      expect(container.read(forgetPwdControllerProvider).isVerifySuccess, isTrue);

      final setPwdNotifier = container.read(setPwdControllerProvider.notifier);
      setPwdNotifier.setUserName('user@test.com');
      setPwdNotifier.setUserPwd('888888');
      setPwdNotifier.setUserConfirmPwd('888888');

      expect(container.read(setPwdControllerProvider).isUserInputValid, isTrue);

      await setPwdNotifier.resetPwd(mockDelay: Duration.zero);
      expect(container.read(setPwdControllerProvider).isSuccess, isTrue);

      final repo = container.read(authRepositoryProvider);
      expect(repo.getSavedUserPwdMd5(), equals(Md5Utils.generateMd5('888888')));
    });

    test('PasswordNotifier: 修改密码页面状态与校验', () async {
      final repo = container.read(authRepositoryProvider);
      await repo.initDefaultUserIfNeeded();

      final notifier = container.read(passwordControllerProvider.notifier);
      notifier.setOldPassword('123456');
      notifier.setNewPassword('newpwd666');
      notifier.setConfirmPassword('newpwd666');

      expect(container.read(passwordControllerProvider).errorMessage, isNull);

      await notifier.changePassword(mockDelay: Duration.zero);
      expect(container.read(passwordControllerProvider).isSuccess, isTrue);
      expect(repo.getSavedUserPwdMd5(), equals(Md5Utils.generateMd5('newpwd666')));
    });
  });
}
