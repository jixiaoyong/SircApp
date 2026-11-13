import '../../lang_keys.dart';
import 'auth_zh.dart';
import 'common_zh.dart';
import 'home_zh.dart';
import 'settings_zh.dart';
import 'wallet_zh.dart';

/// 简体中文多语言实现 (zh_CN)
class LanguagesZhCN implements LangKeys {
  const LanguagesZhCN();

  @override
  AuthLang get auth => const AuthZh();

  @override
  WalletLang get wallet => const WalletZh();

  @override
  HomeLang get home => const HomeZh();

  @override
  SettingsLang get settings => const SettingsZh();

  @override
  CommonLang get common => const CommonZh();
}
