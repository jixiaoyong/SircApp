import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/features/home/data/article_repository.dart';
import 'package:sirc/mock/mock_data_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ArticleRepository repository;

  setUp(() {
    repository = ArticleRepository(MockDataRepository());
  });

  test('文章列表显式按中文与英文Locale映射，详情可按ID查找', () async {
    final chinese = await repository.getGroups(const Locale('zh'));
    final english = await repository.getGroups(const Locale('en'));

    expect(chinese[0][0].title, '认识债券');
    expect(english[0][0].title, 'Bonds');
    for (var group = 0; group < english.length; group++) {
      for (var index = 0; index < english[group].length; index++) {
        final article = english[group][index];
        expect(article.publishedAt, '2026-11-16T09:00:00+08:00');
        expect(chinese[group][index].publishedAt, article.publishedAt);
        expect(
          (await repository.getById(
            article.id,
            const Locale('en'),
          ))!.publishedAt,
          article.publishedAt,
        );
      }
    }
    expect(
      (await repository.getById('0-0', const Locale('en')))?.body,
      contains('A bond usually specifies'),
    );
    expect(await repository.getById('99-99', const Locale('zh')), isNull);
  });
}
