import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/mock/mock_data_repository.dart';
import 'package:sirc/widgets/one_title_with_back_button_appbar.dart';

/// Local reading examples only; no article backend is connected.
class ArticleDetailPage extends ConsumerWidget {
  const ArticleDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final repository = ref.watch(mockDataRepositoryProvider);
    return FutureBuilder<Map<String, dynamic>?>(
      future: repository.getArticleById(id, locale),
      builder: (context, snapshot) {
        final article = snapshot.data;
        final title =
            article?['title'] as String? ?? Languages.home.articleNotFound;
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
                      Languages.home.articleDisclaimer,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    if (article != null) ...[
                      Text(
                        article['summary'] as String? ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        article['body'] as String? ?? '',
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
      },
    );
  }
}
