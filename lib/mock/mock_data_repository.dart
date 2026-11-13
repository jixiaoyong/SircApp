import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/features/wallet/domain/models/bank_card.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';

class MockDataRepository {
  MockDataRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;
  final AssetBundle _bundle;
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

  Future<List<Transaction>> getTransactions([
    Locale locale = const Locale('zh'),
  ]) async => ((await wallet)['transactions'] as List).map((item) {
    final json = Map<String, dynamic>.from(item as Map);
    return Transaction.fromJson({
      ...json,
      'moneyActionName':
          json['name${_languageSuffix(locale)}'] ?? json['moneyActionName'],
    });
  }).toList();

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
