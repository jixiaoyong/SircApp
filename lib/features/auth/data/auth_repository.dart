import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/features/auth/domain/user.dart';
import 'package:sirc/mock/mock_utils.dart';
import 'package:sirc/utils/m5d_utils.dart';

/// 认证仓储接口与实现：封装用户持久化、账号密码校验（MD5）、找回密码与设置密码等核心业务逻辑
class AuthRepository {
  final StorageService _storageService;

  AuthRepository(this._storageService);

  /// 预置默认测试账号（在 Debug/Web 演示或首次无账号时使用）
  Future<void> initDefaultUserIfNeeded({
    String defaultUsername = "jixiaoyong",
    String defaultPassword = "123456",
  }) async {
    final localUserName = _storageService.userName;
    if (localUserName == null || localUserName.isEmpty) {
      final userPwdMd5 = Md5Utils.generateMd5(defaultPassword);
      await _storageService.setUserName(defaultUsername);
      await _storageService.setUserPwd(userPwdMd5);
    }
  }

  /// 获取本地保存的用户名
  String? getSavedUserName() => _storageService.userName;

  /// 获取本地保存的邮箱
  String? getSavedUserEmail() => _storageService.userEmail;

  /// 获取本地保存的密码 MD5
  String? getSavedUserPwdMd5() => _storageService.userPwd;

  /// 当前是否已登录
  bool isUserLoggedIn() => _storageService.isLoginSuccess;

  /// 获取当前登录用户信息
  User? getCurrentUser() {
    if (!isUserLoggedIn()) return null;
    final username = getSavedUserName();
    if (username == null || username.isEmpty) return null;
    return User(
      username: username,
      email: getSavedUserEmail(),
    );
  }

  /// 登录逻辑：比较用户名与密码 MD5
  Future<bool> login(
    String username,
    String password, {
    Duration? mockDelay,
  }) async {
    final delay = mockDelay ?? Duration(seconds: MockUtils.random.nextInt(3) + 1);
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    final localUserName = _storageService.userName ?? "jixiaoyong";
    final localUserPwdMd5 = _storageService.userPwd ?? Md5Utils.generateMd5("123456");
    final userPwdMd5 = Md5Utils.generateMd5(password);

    if (localUserName == username && userPwdMd5 == localUserPwdMd5) {
      await _storageService.setLoginSuccess(true);
      return true;
    } else {
      return false;
    }
  }

  /// 注册逻辑：持久化用户名、密码 MD5 和邮箱
  Future<bool> register(
    String username,
    String email,
    String password, {
    Duration? mockDelay,
  }) async {
    final delay = mockDelay ?? Duration(seconds: MockUtils.random.nextInt(3) + 1);
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    final userPwdMd5 = Md5Utils.generateMd5(password);
    await _storageService.setUserName(username);
    await _storageService.setUserPwd(userPwdMd5);
    await _storageService.setUserEmail(email);
    return true;
  }

  /// 找回密码 - 验证邮箱与验证码
  Future<bool> verifyResetCode(
    String email,
    String code, {
    Duration? mockDelay,
  }) async {
    final delay = mockDelay ?? Duration(seconds: MockUtils.random.nextInt(3) + 1);
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    // 模拟服务端验证
    return code.length == 6;
  }

  /// 设置新密码 / 找回密码后重置密码
  Future<bool> resetPassword(
    String username,
    String newPassword, {
    Duration? mockDelay,
  }) async {
    final delay = mockDelay ?? Duration(seconds: MockUtils.random.nextInt(2) + 1);
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    if (username.isNotEmpty) {
      await _storageService.setUserName(username);
    }
    await _storageService.setUserPwd(Md5Utils.generateMd5(newPassword));
    return true;
  }

  /// 修改密码：验证旧密码 MD5，成功则更新为新密码 MD5
  Future<bool> changePassword(
    String oldPassword,
    String newPassword, {
    Duration? mockDelay,
  }) async {
    final delay = mockDelay ?? Duration(seconds: MockUtils.random.nextInt(2) + 1);
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    final savedPwdMd5 = _storageService.userPwd;
    if (savedPwdMd5 != null && savedPwdMd5.isNotEmpty) {
      final oldPwdMd5 = Md5Utils.generateMd5(oldPassword);
      if (oldPwdMd5 != savedPwdMd5) {
        return false;
      }
    }

    await _storageService.setUserPwd(Md5Utils.generateMd5(newPassword));
    return true;
  }

  /// 退出登录
  Future<void> logout() async {
    await _storageService.clearUser();
  }
}

/// AuthRepository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return AuthRepository(storageService);
});
