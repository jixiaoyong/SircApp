import '../../lang_keys.dart';
import 'auth_en.dart';
import 'common_en.dart';
import 'home_en.dart';
import 'settings_en.dart';
import 'wallet_en.dart';

/// 英文多语言实现 (en_US)
class LanguagesEnUS implements LangKeys {
  const LanguagesEnUS();

  @override
  AuthLang get auth => const AuthEn();

  @override
  WalletLang get wallet => const WalletEn();

  @override
  HomeLang get home => const HomeEn();

  @override
  SettingsLang get settings => const SettingsEn();

  @override
  CommonLang get common => const CommonEn();
}

