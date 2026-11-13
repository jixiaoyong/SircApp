import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/data/article_repository.dart';
import 'package:sirc/widgets/one_title_with_back_button_appbar.dart';

class ArticleDetailPage extends ConsumerWidget {
  const ArticleDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final state = ref.watch(articleDetailProvider(ArticleDetailKey(id, locale)));
    final article = state.asData?.value;
    final title = article?.title ?? Languages.home.articles;
    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(title: title),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(Languages.common.loadFailed),
              TextButton(
                onPressed: () => ref.invalidate(
                  articleDetailProvider(ArticleDetailKey(id, locale)),
                ),
                child: Text(Languages.common.retry),
              ),
            ],
          ),
        ),
        data: (article) => article == null
            ? Center(child: Text(Languages.home.articleNotFound))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Languages.home.articleDisclaimer,
                            style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 24),
                        Text(article.title,
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 16),
                        Text(article.summary,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 24),
                        Text(article.body,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8)),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
