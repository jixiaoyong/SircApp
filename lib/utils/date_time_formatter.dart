import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:sirc/l10n/lang_keys.dart';

/// 解析和展示业务日期，不读取全局语言状态，也不修改原始数据。
class AppDateTimeFormatter {
  const AppDateTimeFormatter._();

  static final _absolute = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})(?:T(\d{2}):(\d{2}):(\d{2})(?:\.\d{1,6})?(Z|[+-]\d{2}:\d{2}))?$',
  );

  /// 将 [raw] 的 ISO 8601 日期或明确时区的时间解析为手机本地时间。
  ///
  /// 完整时间必须包含 Z 或 offset，并按真实瞬间换算；仅日期保留本地
  /// 日历日期语义，不进行 UTC 转换。缺失、无时区时间及非法值返回空。
  static DateTime? parseLocal(String? raw) {
    final normalized = (raw ?? '').trim();
    final match = _absolute.firstMatch(normalized);
    if (match == null) return null;
    final year = int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final day = int.parse(match[3]!);
    final date = DateTime.utc(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    if (match[4] == null) return DateTime(year, month, day);
    if (int.parse(match[4]!) > 23 ||
        int.parse(match[5]!) > 59 ||
        int.parse(match[6]!) > 59) {
      return null;
    }
    final zone = match[7]!;
    if (zone != 'Z') {
      if (int.parse(zone.substring(1, 3)) > 23 ||
          int.parse(zone.substring(4)) > 59) {
        return null;
      }
    }
    return DateTime.tryParse(normalized)?.toLocal();
  }

  /// 使用显式 [locale] 和对应 [languages] 格式化 [value] 的本地日期。
  /// [value] 为 UTC 时先换算手机时区；仅输出日期，不补造时间或时区后缀。
  static String date(
    DateTime value, {
    required Locale locale,
    required LangKeys languages,
  }) => DateFormat(
    languages.common.dateOnlyPattern,
    locale.toString(),
  ).format(value.toLocal());

  /// 按显式 [locale] 和对应 [languages] 展示原始业务日期或时间 [raw]。
  ///
  /// 明确时区的完整时间换算手机时区且保留秒，不显示时区后缀；仅日期
  /// 不补时间。缺失或不符合 ISO 契约的值返回空，不翻译或直出原始标签。
  static String display(
    String? raw, {
    required Locale locale,
    required LangKeys languages,
  }) {
    final text = raw?.trim() ?? '';
    final value = parseLocal(text);
    if (value == null) return '';
    if (!text.contains('T')) {
      return date(value, locale: locale, languages: languages);
    }
    return DateFormat(
      languages.common.fullDateTimePattern,
      locale.toString(),
    ).format(value);
  }
}
