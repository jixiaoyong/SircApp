import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/features/wallet/domain/models/bank_card.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';

class MockDataRepository {
  /// 创建 Mock 仓库；[bundle] 可注入资源包，[clock] 可注入当前时间以便稳定测试。
  MockDataRepository({AssetBundle? bundle, DateTime Function()? clock})
    : _bundle = bundle ?? rootBundle,
      _clock = clock ?? DateTime.now;

  final AssetBundle _bundle;
  final DateTime Function() _clock;
  DateTime? _generatedWeek;
  DateTime? _generatedDate;
  List<Map<String, dynamic>>? _weeklyTransactions;
  Map<String, dynamic>? _wallet;
  Map<String, dynamic>? _articles;
  Map<String, dynamic>? _user;

  Future<Map<String, dynamic>> _load(String path) async =>
      Map<String, dynamic>.from(
        jsonDecode(await _bundle.loadString(path)) as Map,
      );

  Future<Map<String, dynamic>> get user async =>
      _user ??= await _load('assets/mock/user.json');
  Future<Map<String, dynamic>> get wallet async =>
      _wallet ??= await _loadFirst(['assets/mock/wallet.json']);
  Future<Map<String, dynamic>> get articles async =>
      _articles ??= await _loadFirst(['assets/mock/articles.json']);

  Future<Map<String, dynamic>> _loadFirst(List<String> paths) async {
    Object? lastError;
    for (final path in paths) {
      try {
        return await _load(path);
      } catch (error) {
        lastError = error;
      }
    }
    Error.throwWithStackTrace(lastError!, StackTrace.current);
  }

  Future<List<BankCard>> getBankCards([
    Locale locale = const Locale('zh'),
  ]) async => ((await wallet)['cards'] as List).map((item) {
    final json = Map<String, dynamic>.from(item as Map);
    final suffix = _languageSuffix(locale);
    return BankCard.fromJson({
      ...json,
      'bankName': json['displayName$suffix'] ?? json['bankName'],
    });
  }).toList();

  /// 返回交易 Mock；每个自然周追加固定且可复现的当周样例，并按 [locale] 映射名称。
  Future<List<Transaction>> getTransactions([
    Locale locale = const Locale('zh'),
  ]) async {
    final localClock = _clock().toLocal();
    final week = _weekStart(localClock);
    final generatedDate = DateTime(
      localClock.year,
      localClock.month,
      localClock.day,
    );
    if (_generatedWeek != week ||
        _generatedDate != generatedDate ||
        _weeklyTransactions == null) {
      _generatedWeek = week;
      _generatedDate = generatedDate;
      _weeklyTransactions = _createWeeklyTransactions(week, localClock);
    }

    final rawTransactions = [
      ...((await wallet)['transactions'] as List).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
      ..._weeklyTransactions!,
    ];
    final suffix = _languageSuffix(locale);
    return rawTransactions.map((json) {
      return Transaction.fromJson({
        ...json,
        'moneyActionName': json['name$suffix'] ?? json['moneyActionName'],
      });
    }).toList();
  }

  DateTime _weekStart(DateTime value) {
    final date = value.toLocal();
    final today = DateTime(date.year, date.month, date.day);
    return DateTime(today.year, today.month, today.day - today.weekday + 1);
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _formatIsoWithOffset(DateTime local) {
    final offset = local.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final absoluteOffset = offset.abs();
    final hours = absoluteOffset.inHours.toString().padLeft(2, '0');
    final minutes = (absoluteOffset.inMinutes % 60).toString().padLeft(2, '0');
    return '${_formatDate(local)}T'
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}'
        '$sign$hours:$minutes';
  }

  List<Map<String, dynamic>> _createWeeklyTransactions(
    DateTime weekStart,
    DateTime clockNow,
  ) {
    final now = clockNow.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final daysElapsed = today.difference(weekStart).inDays;
    if (daysElapsed < 0) return const [];

    const samples = [
      (
        dayOffset: 0,
        amount: -18.75,
        category: 'food',
        nameEn: 'Weekly Coffee',
        nameZh: '本周咖啡',
      ),
      (
        dayOffset: 1,
        amount: -42.30,
        category: 'groceries',
        nameEn: 'Weekly Market',
        nameZh: '本周超市',
      ),
      (
        dayOffset: 2,
        amount: 125.00,
        category: 'income',
        nameEn: 'Weekly Payment',
        nameZh: '本周收入',
      ),
      (
        dayOffset: 3,
        amount: -26.40,
        category: 'transport',
        nameEn: 'Weekly Transit',
        nameZh: '本周交通',
      ),
      (
        dayOffset: 4,
        amount: -63.20,
        category: 'bills',
        nameEn: 'Weekly Bill',
        nameZh: '本周账单',
      ),
      (
        dayOffset: 5,
        amount: -31.90,
        category: 'entertainment',
        nameEn: 'Weekly Cinema',
        nameZh: '本周电影',
      ),
      (
        dayOffset: 6,
        amount: -12.50,
        category: 'food',
        nameEn: 'Weekly Lunch',
        nameZh: '本周午餐',
      ),
    ];
    return [
      for (final sample in samples)
        if (sample.dayOffset <= daysElapsed)
          {
            'id': 'mock-week-${_formatDate(weekStart)}-${sample.dayOffset}',
            'userIcon': '',
            'moneyActionName': sample.nameEn,
            'nameZh': sample.nameZh,
            'nameEn': sample.nameEn,
            'moneyAmount': sample.amount,
            'time': _formatIsoWithOffset(
              DateTime(
                weekStart.year,
                weekStart.month,
                weekStart.day + sample.dayOffset,
                12,
              ),
            ),
            'category': sample.category,
            'cardId': 'card-test-001',
          },
    ];
  }

  String _languageSuffix(Locale locale) =>
      locale.languageCode == 'en' ? 'En' : 'Zh';

  Future<List<List<Map<String, dynamic>>>> getArticleGroups(
    Locale locale,
  ) async => ((await articles)['groups'] as List)
      .map(
        (group) => (group as List)
            .map(
              (item) => _localizeArticle(
                Map<String, dynamic>.from(item as Map),
                locale,
              ),
            )
            .toList(),
      )
      .toList();

  Map<String, dynamic> _localizeArticle(
    Map<String, dynamic> article,
    Locale locale,
  ) {
    final suffix = _languageSuffix(locale);
    return {
      ...article,
      'title':
          article['title$suffix'] as String? ??
          article['titleEn'] as String? ??
          '',
      'summary':
          article['summary$suffix'] as String? ??
          article['summaryEn'] as String? ??
          '',
      'body':
          article['body$suffix'] as String? ??
          article['bodyEn'] as String? ??
          '',
    };
  }

  Future<List<Map<String, dynamic>>> getQuickActions([
    Locale locale = const Locale('zh'),
  ]) async => ((await articles)['quickActions'] as List? ?? const []).map((
    item,
  ) {
    final json = Map<String, dynamic>.from(item as Map);
    return {
      ...json,
      'title': json['title${_languageSuffix(locale)}'] ?? json['titleEn'] ?? '',
    };
  }).toList();

  Future<Map<String, dynamic>?> getArticleById(String id, Locale locale) async {
    final parts = id.split('-');
    if (parts.length != 2) return null;
    final group = int.tryParse(parts[0]);
    final index = int.tryParse(parts[1]);
    final groups = await getArticleGroups(locale);
    if (group == null ||
        index == null ||
        group < 0 ||
        group >= groups.length ||
        index < 0 ||
        index >= groups[group].length) {
      return null;
    }
    return groups[group][index];
  }
}

final mockDataRepositoryProvider = Provider<MockDataRepository>(
  (ref) => MockDataRepository(),
);
