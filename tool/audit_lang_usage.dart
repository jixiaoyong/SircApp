import 'dart:io';

/// Reports translation keys by business and test references. This is advisory only.
void main(List<String> args) {
  try {
    final report = auditLanguageUsage(Directory.current);
    stdout.write(report.format());
  } catch (error, stack) {
    stderr.writeln('语言 key 审计未完成（不影响生成）：$error');
    stderr.writeln(stack);
  }
}

LanguageUsageReport auditLanguageUsage(Directory root) {
  final contractFiles = Directory('${root.path}/lib/l10n/keys')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
  final keys = <String, Set<String>>{};
  for (final file in contractFiles) {
    final module = file.uri.pathSegments.last.replaceFirst('_keys.dart', '');
    final source = file.readAsStringSync();
    for (final match in RegExp(r'\bString\s+get\s+(\w+)').allMatches(source)) {
      keys.putIfAbsent(match.group(1)!, () => <String>{}).add(module);
    }
  }

  final business = <String, int>{};
  final tests = <String, int>{};
  final roots = <String, bool>{'lib': false, 'test': true};
  for (final entry in roots.entries) {
    final dir = Directory('${root.path}/${entry.key}');
    if (!dir.existsSync()) continue;
    for (final file in dir.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart') || _excluded(file.path)) continue;
      final source = file.readAsStringSync();
      for (final key in keys.keys) {
        if (_isReferenced(source, key)) {
          (entry.value ? tests : business).update(
            key,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
        }
      }
    }
  }
  return LanguageUsageReport(
    keys: keys,
    businessFiles: business,
    testFiles: tests,
  );
}

bool _excluded(String path) =>
    path.contains('/l10n/keys/') ||
    path.contains('/l10n/impl/') ||
    path.endsWith('/languages.g.dart') ||
    path.contains('/.dart_tool/') ||
    path.contains('/build/');

bool _isReferenced(String source, String key) {
  // Remove comments and literals so examples and translation text aren't counted.
  final code = source
      .replaceAll(
        RegExp("'''[\\s\\S]*?'''|\\\"\\\"\\\"[\\s\\S]*?\\\"\\\"\\\""),
        ' ',
      )
      .replaceAll(
        RegExp("r?\\\"(?:\\\\.|[^\\\"\\\\])*\\\"|r?'(?:\\\\.|[^'\\\\])*'"),
        ' ',
      )
      .replaceAll(RegExp(r'//[^\n]*|/\*[\s\S]*?\*/'), ' ');
  final name = RegExp.escape(key);
  final access = RegExp(
    r'(?:Languages\s*\.\s*' +
        name +
        r'\b|Languages\s*\.\s*\w+\s*\.\s*' +
        name +
        r'\b|AppLocale\s*\.\s*current\s*\.\s*\w+\s*\.\s*' +
        name +
        r'\b)',
  );
  return access.hasMatch(code);
}

class LanguageUsageReport {
  final Map<String, Set<String>> keys;
  final Map<String, int> businessFiles;
  final Map<String, int> testFiles;

  const LanguageUsageReport({
    required this.keys,
    required this.businessFiles,
    required this.testFiles,
  });

  String format() {
    final out = StringBuffer('语言 key 使用审计（仅报告，不删除、不使 CI 失败）\n');
    for (final key in keys.keys.toList()..sort()) {
      final business = businessFiles[key] ?? 0;
      final test = testFiles[key] ?? 0;
      final status = business > 0
          ? '业务引用'
          : test > 0
          ? '仅测试引用'
          : '无引用候选';
      out.writeln(
        '- $key [${keys[key]!.join(', ')}]：$status（lib: $business 个文件，test: $test 个文件）',
      );
    }
    return out.toString();
  }
}
