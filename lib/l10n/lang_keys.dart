import 'keys/auth_keys.dart';
import 'keys/common_keys.dart';
import 'keys/home_keys.dart';
import 'keys/settings_keys.dart';
import 'keys/wallet_keys.dart';

export 'keys/auth_keys.dart';
export 'keys/common_keys.dart';
export 'keys/home_keys.dart';
export 'keys/settings_keys.dart';
export 'keys/wallet_keys.dart';

/// 全局多语言总契约接口
///
/// 所有具体语言实现（如 [LanguagesZhCN]、[LanguagesEnUS]）必须完整实现该接口。
/// 一旦契约中新增或修改任何词条，未实现该词条的语言实现类将在编译期直接报错，
/// 从而保证 100% 的多语言对称性与类型安全。
abstract class LangKeys {
  AuthLang get auth;
  WalletLang get wallet;
  HomeLang get home;
  SettingsLang get settings;
  CommonLang get common;
}
