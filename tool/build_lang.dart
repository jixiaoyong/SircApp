import 'dart:async';
import 'dart:io';

/// 多语言自动化生成与同步脚本
///
/// 使用方式：
/// 1. 手动一键生成：
///    `fvm dart run tool/build_lang.dart`
/// 2. 监听文件变动实时自动生成：
///    `fvm dart run tool/build_lang.dart --watch`
void main(List<String> args) {
  final isWatch = args.contains('--watch') || args.contains('-w');

  // 立即执行一次生成
  _generate();

  if (isWatch) {
    print('👀 已启动监听模式（--watch），正在实时监听 lib/l10n/ 目录变动...');
    print('💡 当你保存契约或实现文件时，将自动重新生成，无需手动执行命令。\n');

    final l10nDir = Directory('lib/l10n');
    Timer? debounceTimer;

    l10nDir.watch(recursive: true).listen((event) {
      // 忽略 README.md、生成的门面文件等变动，仅监听 keys 和 impl
      if (!event.path.endsWith('.dart') ||
          event.path.endsWith('languages.g.dart'))
        return;

      debounceTimer?.cancel();
      debounceTimer = Timer(const Duration(milliseconds: 300), () {
        print('\n⚡ 检测到文件变更: ${event.path}');
        _generate();
      });
    });
  }
}

void _generate() {
  final keysDir = Directory('lib/l10n/keys');
  final zhDir = Directory('lib/l10n/impl/zh');
  final enDir = Directory('lib/l10n/impl/en');
  final targetFile = File('lib/l10n/languages.g.dart');

  if (!keysDir.existsSync() || !zhDir.existsSync() || !enDir.existsSync()) {
    stderr.writeln('错误：找不到多语言目录结构！请确保在项目根目录运行。');
    exit(1);
  }

  print('🔄 正在扫描多语言契约与实现模块...');

  final modules = ['auth', 'wallet', 'home', 'settings', 'common'];
  final moduleData = <String, List<_Entry>>{};
  int totalCount = 0;

  for (final mod in modules) {
    final zhFile = File('${zhDir.path}/${mod}_zh.dart');
    final enFile = File('${enDir.path}/${mod}_en.dart');

    if (!zhFile.existsSync() || !enFile.existsSync()) {
      stderr.writeln('警告：模块 $mod 缺少实现文件！');
      continue;
    }

    final zhMap = _parseTranslations(zhFile.readAsStringSync());
    final enMap = _parseTranslations(enFile.readAsStringSync());

    final entries = <_Entry>[];
    for (final key in zhMap.keys) {
      final zhVal = zhMap[key] ?? '';
      final enVal = enMap[key] ?? key;
      entries.add(_Entry(key: key, zh: zhVal, en: enVal));
      totalCount++;
    }
    moduleData[mod] = entries;
    print('  - 模块 [$mod] 解析到 ${entries.length} 个词条');
  }

  print('📊 总计解析到 $totalCount 个词条，正在生成 lib/l10n/languages.g.dart...');

  final sb = StringBuffer();
  sb.writeln('''// GENERATED CODE - DO NOT MODIFY BY HAND
// 该文件由脚本自动维护。如需新增或修改多语言词条：
// 1. 在 `lib/l10n/keys/` 中声明对应模块属性
// 2. 在 `lib/l10n/impl/zh/` 和 `lib/l10n/impl/en/` 中实现中英文翻译
// 3. 执行更新命令：
//    - 手动单次生成：`dart run tool/build_lang.dart`
//    - 后台监听实时生成：`dart run tool/build_lang.dart --watch`

import '../core/localization/app_locale.dart';

/*
* @description: 全局强类型分层多语言门面
*
* 1. 支持业务分层命名空间调用：
*    例如 Languages.auth.oldPasswordIncorrect、Languages.wallet.availableBalance
* 2. 完整保留扁平别名调用（平滑兼容历史代码）：
*    例如 Languages.oldPasswordIncorrect、Languages.cancel
* 3. 具备双语悬浮预览注释，敲代码时鼠标移至属性即可查看中英真实文案！
*
* 自动生成命令：
* - 手动执行：dart run tool/build_lang.dart
* - 实时监听：dart run tool/build_lang.dart --watch
*/
class Languages {
  Languages._();

  // ==========================================
  // 一、 业务分层命名空间（Layered Namespaces）
  // ==========================================

  /// 认证、账号、密码及表单校验词条命名空间
  static AuthLang get auth => AppLocale.current.auth;

  /// 钱包、银行卡、交易流水及财务词条命名空间
  static WalletLang get wallet => AppLocale.current.wallet;

  /// 首页、看板、月份、星期及快捷分类词条命名空间
  static HomeLang get home => AppLocale.current.home;

  /// 设置、关于、个人资料、通知及退出登录词条命名空间
  static SettingsLang get settings => AppLocale.current.settings;

  /// 通用公共词条（按钮、状态、缺省页等）命名空间
  static CommonLang get common => AppLocale.current.common;

  // ==========================================
  // 二、 扁平兼容层（带双语悬浮预览注释）
  // ==========================================
''');

  for (final mod in modules) {
    sb.writeln('  // --- ${_capitalize(mod)} 模块 ---');
    final entries = moduleData[mod] ?? [];
    for (final e in entries) {
      if (e.key == 'title') {
        final propName = '${mod}Title';
        final cleanZh = e.zh.replaceAll('\n', r'\n');
        final cleanEn = e.en.replaceAll('\n', r'\n');
        sb.writeln('  ///- [zh_CN] $cleanZh');
        sb.writeln('  ///- [en_US] $cleanEn');
        sb.writeln('  static String get $propName => $mod.title;');
        sb.writeln();
        continue;
      }

      if (e.key == mod) continue;

      final cleanZh = e.zh.replaceAll('\n', r'\n');
      final cleanEn = e.en.replaceAll('\n', r'\n');

      sb.writeln('  ///- [zh_CN] $cleanZh');
      sb.writeln('  ///- [en_US] $cleanEn');
      sb.writeln('  static String get ${e.key} => $mod.${e.key};');
      sb.writeln();
    }
  }

  sb.writeln('''  // ==========================================
  // 三、 兼容字典映射 (供 AppLocale.translate 兜底查找)
  // ==========================================
  static Map<String, Map<String, String>> get keys => _keys;

  static final Map<String, Map<String, String>> _keys = {
    "en_US": {''');

  for (final mod in modules) {
    for (final e in moduleData[mod] ?? []) {
      if (e.key == 'aboutUsDescription') continue;
      final escapedEn = e.en
          .replaceAll(r'\', r'\\')
          .replaceAll('"', r'\"')
          .replaceAll('\n', r'\n');
      sb.writeln('      "${e.en}": "$escapedEn",');
    }
  }
  sb.writeln('''    },
    "zh_CN": {''');

  for (final mod in modules) {
    for (final e in moduleData[mod] ?? []) {
      if (e.key == 'aboutUsDescription') continue;
      final escapedZh = e.zh
          .replaceAll(r'\', r'\\')
          .replaceAll('"', r'\"')
          .replaceAll('\n', r'\n');
      sb.writeln('      "${e.en}": "$escapedZh",');
    }
  }

  sb.writeln('''    },
  };
}
''');

  targetFile.writeAsStringSync(sb.toString());

  Process.runSync('dart', ['format', targetFile.path]);
  print('✅ 自动生成完成！lib/l10n/languages.g.dart 已更新。');

  // 审计在生成成功后运行；无引用仅作提示，审计故障不影响生成结果。
  try {
    final result = Process.runSync('dart', [
      'run',
      'tool/audit_lang_usage.dart',
    ]);
    if (result.stdout.toString().isNotEmpty) stdout.write(result.stdout);
    if (result.stderr.toString().isNotEmpty) stderr.write(result.stderr);
  } catch (error) {
    stderr.writeln('语言 key 审计跳过（不影响生成）：$error');
  }
}

class _Entry {
  final String key;
  final String zh;
  final String en;
  _Entry({required this.key, required this.zh, required this.en});
}

Map<String, String> _parseTranslations(String code) {
  final map = <String, String>{};

  final tripleRegex = RegExp(
    r'@override\s+String\s+get\s+(\w+)\s*=>\s*r?(?:"""([\s\S]*?)"""|'
    "'''"
    r'([\s\S]*?)'
    "''');",
    multiLine: true,
  );
  for (final match in tripleRegex.allMatches(code)) {
    final key = match.group(1)!;
    final val = match.group(2) ?? match.group(3) ?? '';
    map[key] = val;
  }

  final singleRegex = RegExp(
    r'@override\s+String\s+get\s+(\w+)\s*=>\s*r?(?:"([^"\\]*(?:\\.[^"\\]*)*)"|'
    r"'([^'\\]*(?:\\.[^'\\]*)*)');",
    multiLine: true,
  );
  for (final match in singleRegex.allMatches(code)) {
    final key = match.group(1)!;
    if (!map.containsKey(key)) {
      final val = match.group(2) ?? match.group(3) ?? '';
      map[key] = val;
    }
  }

  return map;
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}
