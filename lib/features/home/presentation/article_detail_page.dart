import 'package:flutter/material.dart';
import 'package:sirc/features/home/presentation/sample_articles.dart';
import 'package:sirc/widgets/one_title_with_back_button_appbar.dart';

/// Local reading examples only; no article backend is connected.
class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final article = sampleArticleForId(id);
    final title = article?.title(zh) ?? (zh ? '未找到文章' : 'Article not found');
    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(title: title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zh ? '本地静态示例 · 未连接文章服务 · 非投资建议' : 'Static example · Local content · No article service connected · Not investment advice',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 24),
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                if (article != null) ...[
                  Text(
                    article.summary(zh),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    article.body(zh),
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(height: 1.8),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
