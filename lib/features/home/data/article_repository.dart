import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/mock/mock_data_repository.dart';

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
  });

  final String id;
  final String title;
  final String summary;
  final String body;

  factory Article.fromLocalizedJson(String id, Map<String, dynamic> json) =>
      Article(
        id: id,
        title: json['title'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );
}

class ArticleRepository {
  const ArticleRepository(this._mock);

  final MockDataRepository _mock;

  Future<List<List<Article>>> getGroups(Locale locale) async {
    final groups = await _mock.getArticleGroups(locale);
    return [
      for (var groupIndex = 0; groupIndex < groups.length; groupIndex++)
        [
          for (var articleIndex = 0;
              articleIndex < groups[groupIndex].length;
              articleIndex++)
            Article.fromLocalizedJson(
              '$groupIndex-$articleIndex',
              groups[groupIndex][articleIndex],
            ),
        ],
    ];
  }

  Future<Article?> getById(String id, Locale locale) async {
    final groups = await getGroups(locale);
    final parts = id.split('-');
    if (parts.length != 2) return null;
    final group = int.tryParse(parts[0]);
    final index = int.tryParse(parts[1]);
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

final articleRepositoryProvider = Provider<ArticleRepository>(
  (ref) => ArticleRepository(ref.watch(mockDataRepositoryProvider)),
);

final articleGroupsProvider = FutureProvider.family<List<List<Article>>, Locale>(
  (ref, locale) => ref.watch(articleRepositoryProvider).getGroups(locale),
);

final articleDetailProvider = FutureProvider.family<Article?, ArticleDetailKey>(
  (ref, key) => ref.watch(articleRepositoryProvider).getById(key.id, key.locale),
);

class ArticleDetailKey {
  const ArticleDetailKey(this.id, this.locale);

  final String id;
  final Locale locale;

  @override
  bool operator ==(Object other) =>
      other is ArticleDetailKey && other.id == id && other.locale == locale;

  @override
  int get hashCode => Object.hash(id, locale);
}
