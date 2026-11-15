import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sirc/core/localization/app_locale.dart' show localeProvider;
import 'package:sirc/core/theme/app_colors.dart' show AppColors;
import 'package:sirc/features/home/data/article_repository.dart'
    show articleGroupsProvider, Article;
import 'package:sirc/l10n/languages.g.dart' show Languages;
import 'package:sirc/routes/source_detail_navigation.dart'
    show openSourceDetail;
import 'package:sirc/widgets/neutral_segments.dart' show NeutralSegments;

/// 展示本地文章面板
///
/// 作为 [SliverMainAxisGroup] 提供分类栏局域吸顶（Scoped Sticky Header）与文章列表。
class HomeArticlesPanel extends ConsumerStatefulWidget {
  /// 创建文章面板 Sliver
  const HomeArticlesPanel({super.key});

  @override
  ConsumerState<HomeArticlesPanel> createState() => _HomeArticlesPanelState();
}

class _HomeArticlesPanelState extends ConsumerState<HomeArticlesPanel> {
  int selected = 0;

  Widget _buildHeading() {
    return Row(
      children: [
        Expanded(
          child: Text(
            Languages.articles,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          Languages.home.localExamples,
          style: TextStyle(fontSize: 10, color: AppColors.muted(context)),
        ),
      ],
    );
  }

  Widget _buildSegments({
    Key? key,
    required String keyPrefix,
    bool isPinned = false,
  }) {
    return NeutralSegments(
      key: key,
      labels: [Languages.follow, Languages.hot, Languages.explore],
      selected: selected,
      onSelected: (i) => setState(() => selected = i),
      keyPrefix: keyPrefix,
      borderRadius: isPinned ? BorderRadius.zero : BorderRadius.circular(11),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final articlesState = ref.watch(articleGroupsProvider(locale));

    final articleItems = articlesState.when(
      loading: () => [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (error, stack) => [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(Languages.common.loadFailed),
              TextButton(
                onPressed: () => ref.invalidate(articleGroupsProvider(locale)),
                child: Text(Languages.common.retry),
              ),
            ],
          ),
        ),
      ],
      data: (groups) => selected >= groups.length || groups[selected].isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(Languages.common.notFound),
              ),
            ]
          : [
              for (var i = 0; i < groups[selected].length; i++) ...[
                if (i > 0) Divider(height: 1, color: AppColors.line(context)),
                _RepositoryArticleItem(
                  article: groups[selected][i],
                  group: selected,
                  index: i,
                ),
              ],
            ],
    );

    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderColor = AppColors.line(context);

    final sectionStart = SliverToBoxAdapter(
      child: Container(
        key: const ValueKey('home-articles'),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          border: Border(
            top: BorderSide(color: borderColor),
            left: BorderSide(color: borderColor),
            right: BorderSide(color: borderColor),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: _buildHeading(),
      ),
    );

    final stickySegments = SliverPersistentHeader(
      pinned: true,
      delegate: _ArticleSegmentsHeaderDelegate(
        builder: (context, isPinned) =>
            _buildSegments(keyPrefix: 'article-segment', isPinned: isPinned),
      ),
    );

    final sectionEnd = SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(14),
          ),
          border: Border(
            left: BorderSide(color: borderColor),
            right: BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: articleItems,
        ),
      ),
    );

    return SliverMainAxisGroup(
      slivers: [sectionStart, stickySegments, sectionEnd],
    );
  }
}

class _RepositoryArticleItem extends StatelessWidget {
  const _RepositoryArticleItem({
    required this.article,
    required this.group,
    required this.index,
  });
  final Article article;
  final int group;
  final int index;

  @override
  Widget build(BuildContext context) {
    final title = article.title;
    final summary = article.summary;
    return InkWell(
      key: ValueKey('home-article-$group-$index'),
      onTap: () => openSourceDetail(context, 'article/$group-$index'),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                summary,
                style: TextStyle(fontSize: 12, color: AppColors.muted(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 文章分类吸顶栏 Delegate
///
/// 固定 44 像素高度，在吸顶时展示横向满幅扩展动画、平滑阴影与边框贴合。
class _ArticleSegmentsHeaderDelegate extends SliverPersistentHeaderDelegate {
  /// 创建文章分类吸顶栏 Delegate
  ///
  /// [builder] 根据是否吸顶构建子组件。
  const _ArticleSegmentsHeaderDelegate({required this.builder});

  /// 吸顶栏子组件构建函数
  final Widget Function(BuildContext context, bool isPinned) builder;

  @override
  double get minExtent => 44.0;

  @override
  double get maxExtent => 44.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isPinned = shrinkOffset > 0 || overlapsContent;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderColor = AppColors.line(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: 44.0,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          left: BorderSide(color: borderColor),
          right: BorderSide(color: borderColor),
        ),
        boxShadow: isPinned
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.symmetric(horizontal: isPinned ? 0 : 16),
      child: builder(context, isPinned),
    );
  }

  @override
  bool shouldRebuild(covariant _ArticleSegmentsHeaderDelegate oldDelegate) =>
      true;
}
