import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/l10n/impl/en/languages_en.dart';
import 'package:sirc/l10n/impl/zh/languages_zh.dart';

void main() {
  group('现代强类型分层多语言 (l10n) 架构测试', () {
    const zh = LanguagesZhCN();
    const en = LanguagesEnUS();

    test('1. 契约完整性与非空校验 (严格杜绝漏翻或空串)', () {
      // Auth 认证模块
      expect(zh.auth.signIn, '登录');
      expect(en.auth.signIn, 'Sign In');
      expect(zh.auth.oldPasswordIncorrect, '原密码不正确或修改失败');
      expect(
        en.auth.oldPasswordIncorrect,
        'Original password incorrect or update failed',
      );
      expect(zh.auth.passwordInconsistent, '两次输入的密码不一致');
      expect(
        en.auth.passwordInconsistent,
        'The passwords entered twice do not match',
      );

      // Wallet 钱包模块
      expect(zh.wallet.title, '钱包');
      expect(en.wallet.title, 'Wallet');
      expect(zh.wallet.availableBalance, '可用余额');
      expect(en.wallet.availableBalance, 'Available Balance');
      expect(zh.wallet.masterCard, '万事达卡');
      expect(en.wallet.masterCard, 'MasterCard');
      expect(zh.wallet.visa, '维萨卡');
      expect(en.wallet.visa, 'Visa');

      // Home 看板模块
      expect(zh.home.title, '首页');
      expect(en.home.title, 'Home');
      expect(zh.home.mon, '周一');
      expect(en.home.mon, 'Mon');
      expect(zh.home.february, '二月');
      expect(en.home.february, 'February');

      // Settings 设置模块
      expect(zh.settings.title, '设置');
      expect(en.settings.title, 'Settings');
      expect(zh.settings.language, '语言');
      expect(en.settings.language, 'Language');
      expect(zh.settings.notifications, '通知');
      expect(en.settings.notifications, 'Notifications');

      // Common 公共通用模块
      expect(zh.common.cancel, '取消');
      expect(en.common.cancel, 'Cancel');
      expect(zh.common.submit, '提交');
      expect(en.common.submit, 'Submit');
      expect(zh.common.notFound, '页面未找到');
      expect(en.common.notFound, 'Not Found');
    });

    test('2. 强类型动态参数与单复数测试', () {
      expect(zh.wallet.cardCount(1), '共 1 张卡片');
      expect(zh.wallet.cardCount(3), '共 3 张卡片');

      // 英文单复数规则
      expect(en.wallet.cardCount(1), '1 card in total');
      expect(en.wallet.cardCount(3), '3 cards in total');
    });

    test('3. Languages 门面类命名空间与扁平别名调用对齐测试', () {
      AppLocale.setLocale(const Locale('zh', 'CN'));

      // 命名空间调用
      expect(Languages.auth.oldPasswordIncorrect, '原密码不正确或修改失败');
      expect(Languages.wallet.availableBalance, '可用余额');
      expect(Languages.common.cancel, '取消');

      // 扁平别名调用（兼容层）
      expect(Languages.oldPasswordIncorrect, '原密码不正确或修改失败');
      expect(Languages.availableBalance, '可用余额');
      expect(Languages.cancel, '取消');
      expect(Languages.homeTitle, '首页');
      expect(Languages.walletTitle, '钱包');
      expect(Languages.settingsTitle, '设置');
    });

    test('4. 动态切换系统 Locale 验证实时生效', () {
      // 切换至英文
      AppLocale.setLocale(const Locale('en', 'US'));
      expect(
        Languages.auth.oldPasswordIncorrect,
        'Original password incorrect or update failed',
      );
      expect(Languages.wallet.availableBalance, 'Available Balance');
      expect(Languages.cancel, 'Cancel');
      expect(Languages.home.title, 'Home');

      // 切换回中文
      AppLocale.setLocale(const Locale('zh', 'CN'));
      expect(Languages.auth.oldPasswordIncorrect, '原密码不正确或修改失败');
      expect(Languages.wallet.availableBalance, '可用余额');
      expect(Languages.cancel, '取消');
      expect(Languages.home.title, '首页');
    });
  });
}
