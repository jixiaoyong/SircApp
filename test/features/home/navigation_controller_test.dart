import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/features/home/controllers/home_controller.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';

void main() {
  group('NavigationController Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state should have default values', () {
      final state = container.read(navigationControllerProvider);

      expect(state.currentIndex, 0);
      expect(state.userName, 'JI,XIAOYONG');
      expect(state.userEmail, 'jixiaoyong1995@gmail.com');
      expect(
        state.userAvatar,
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
      );
      expect(state.isDrawerOpen, isFalse);
    });

    test('changeIndex should update currentIndex correctly', () {
      final controller = container.read(navigationControllerProvider.notifier);

      controller.changeIndex(1);
      expect(container.read(navigationControllerProvider).currentIndex, 1);

      controller.changeIndex(3);
      expect(container.read(navigationControllerProvider).currentIndex, 3);

      // 幂等调用相同索引
      controller.changeIndex(3);
      expect(container.read(navigationControllerProvider).currentIndex, 3);
    });

    test('setUserInfo should update user name and email selectively', () {
      final controller = container.read(navigationControllerProvider.notifier);

      // 仅更新名称
      controller.setUserInfo(name: 'Alice');
      var state = container.read(navigationControllerProvider);
      expect(state.userName, 'Alice');
      expect(state.userEmail, 'jixiaoyong1995@gmail.com');

      // 仅更新邮箱
      controller.setUserInfo(email: 'alice@example.com');
      state = container.read(navigationControllerProvider);
      expect(state.userName, 'Alice');
      expect(state.userEmail, 'alice@example.com');

      // 同时更新两者
      controller.setUserInfo(name: 'Bob', email: 'bob@example.com');
      state = container.read(navigationControllerProvider);
      expect(state.userName, 'Bob');
      expect(state.userEmail, 'bob@example.com');
    });

    test('updateUserAvatar should update user avatar URL', () {
      final controller = container.read(navigationControllerProvider.notifier);
      const newAvatar = 'https://example.com/avatar.png';

      controller.updateUserAvatar(newAvatar);
      expect(
        container.read(navigationControllerProvider).userAvatar,
        newAvatar,
      );
    });

    test('openDrawer, closeDrawer, and toggleDrawer should control drawer state',
        () {
      final controller = container.read(navigationControllerProvider.notifier);

      expect(container.read(navigationControllerProvider).isDrawerOpen, isFalse);

      controller.openDrawer();
      expect(container.read(navigationControllerProvider).isDrawerOpen, isTrue);

      // 重复打开保持 true
      controller.openDrawer();
      expect(container.read(navigationControllerProvider).isDrawerOpen, isTrue);

      controller.closeDrawer();
      expect(container.read(navigationControllerProvider).isDrawerOpen, isFalse);

      // toggle 切换
      controller.toggleDrawer();
      expect(container.read(navigationControllerProvider).isDrawerOpen, isTrue);

      controller.toggleDrawer();
      expect(container.read(navigationControllerProvider).isDrawerOpen, isFalse);

      // setDrawerOpen
      controller.setDrawerOpen(true);
      expect(container.read(navigationControllerProvider).isDrawerOpen, isTrue);
      controller.setDrawerOpen(false);
      expect(container.read(navigationControllerProvider).isDrawerOpen, isFalse);
    });
  });

  group('HomeController Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state should load correctly', () {
      final state = container.read(homeControllerProvider);

      expect(state.currentBankIndex, 0);
      expect(state.weeklyPercentages.length, 7);
      expect(state.banks.length, 3);
      expect(state.quickActions.length, 15);
    });

    test('setBankIndex should update selected bank index', () {
      final controller = container.read(homeControllerProvider.notifier);

      controller.setBankIndex(1);
      expect(container.read(homeControllerProvider).currentBankIndex, 1);

      controller.setBankIndex(2);
      expect(container.read(homeControllerProvider).currentBankIndex, 2);
    });

    test('updateWeeklyPercentages should update weekly percentages data', () {
      final controller = container.read(homeControllerProvider.notifier);
      final newData = [0.1, 0.2, 0.8];

      controller.updateWeeklyPercentages(newData);
      expect(
        container.read(homeControllerProvider).weeklyPercentages,
        equals(newData),
      );
    });
  });
}
