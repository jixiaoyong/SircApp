import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sirc/mock/mock_data_repository.dart';

part 'navigation_controller.g.dart';

/// 由用户 fixture 映射后的资料字段。
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String avatarUrl;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json, Locale locale) {
    final suffix = locale.languageCode == 'en' ? 'En' : 'Zh';
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name$suffix'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }
}

/// 底部导航与主框架全局状态
class NavigationState {
  final int currentIndex;
  final String userName;
  final String userEmail;
  final String userAvatar;
  final bool isDrawerOpen;

  const NavigationState({
    this.currentIndex = 0,
    this.userName = 'JI,XIAOYONG',
    this.userEmail = 'jixiaoyong1995@gmail.com',
    this.userAvatar = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
    this.isDrawerOpen = false,
  });

  NavigationState copyWith({
    int? currentIndex,
    String? userName,
    String? userEmail,
    String? userAvatar,
    bool? isDrawerOpen,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userAvatar: userAvatar ?? this.userAvatar,
      isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationState &&
          runtimeType == other.runtimeType &&
          currentIndex == other.currentIndex &&
          userName == other.userName &&
          userEmail == other.userEmail &&
          userAvatar == other.userAvatar &&
          isDrawerOpen == other.isDrawerOpen;

  @override
  int get hashCode =>
      currentIndex.hashCode ^
      userName.hashCode ^
      userEmail.hashCode ^
      userAvatar.hashCode ^
      isDrawerOpen.hashCode;
}

/// 底部导航与抽屉控制器
@Riverpod(keepAlive: true)
class NavigationController extends _$NavigationController {
  @override
  NavigationState build() {
    return const NavigationState();
  }

  Future<UserProfile> loadUserProfile(Locale locale) async {
    final json = await ref.read(mockDataRepositoryProvider).user;
    return UserProfile.fromJson(json, locale);
  }

  /// 切换底部导航栏 Tab 索引
  void changeIndex(int index) {
    if (state.currentIndex != index) {
      state = state.copyWith(currentIndex: index);
    }
  }

  /// 更新用户信息
  void setUserInfo({String? name, String? email}) {
    state = state.copyWith(
      userName: name ?? state.userName,
      userEmail: email ?? state.userEmail,
    );
  }

  /// 更新头像链接
  void updateUserAvatar(String avatar) {
    state = state.copyWith(userAvatar: avatar);
  }

  /// 打开侧滑抽屉
  void openDrawer() {
    if (!state.isDrawerOpen) {
      state = state.copyWith(isDrawerOpen: true);
    }
  }

  /// 关闭侧滑抽屉
  void closeDrawer() {
    if (state.isDrawerOpen) {
      state = state.copyWith(isDrawerOpen: false);
    }
  }

  /// 切换侧滑抽屉状态
  void toggleDrawer() {
    state = state.copyWith(isDrawerOpen: !state.isDrawerOpen);
  }

  /// 显式设置侧滑抽屉状态
  void setDrawerOpen(bool isOpen) {
    if (state.isDrawerOpen != isOpen) {
      state = state.copyWith(isDrawerOpen: isOpen);
    }
  }
}
