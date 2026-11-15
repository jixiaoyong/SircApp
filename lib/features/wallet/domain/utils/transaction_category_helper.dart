import 'package:material_ui/material_ui.dart';
import 'package:sirc/core/layout/app_layout.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/widgets/network_web_image.dart';

/// 交易品类与商家视觉辅助工具类。
///
/// 根据 [Transaction] 的 [category]、[moneyActionName] 提供对应的语义图标、
/// 主题配色、兜底商家图片及自适应宽窄屏的 Hero 头像组件。
abstract final class TransactionCategoryHelper {
  /// 品类对应的默认高质量商家/品类图片链接映射
  static const Map<String, String> _categoryImageUrls = {
    'food':
        'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=150&q=80',
    'income':
        'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?auto=format&fit=crop&w=150&q=80',
    'groceries':
        'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=150&q=80',
    'bills':
        'https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=150&q=80',
    'transport':
        'https://images.unsplash.com/photo-1557223562-6c77ef16210f?auto=format&fit=crop&w=150&q=80',
    'entertainment':
        'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=150&q=80',
    'shopping':
        'https://images.unsplash.com/photo-1472851294608-062f824d29cc?auto=format&fit=crop&w=150&q=80',
    'health':
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=150&q=80',
    'education':
        'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?auto=format&fit=crop&w=150&q=80',
    'home':
        'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=150&q=80',
    'subscription':
        'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=150&q=80',
    'refund':
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=150&q=80',
    'interest':
        'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&w=150&q=80',
  };

  /// 根据 [category] 或 [name] 获取最匹配的品类 Key。
  static String resolveCategory(String? category, {String? name}) {
    final cat = (category ?? '').trim().toLowerCase();
    if (cat.isNotEmpty && _categoryImageUrls.containsKey(cat)) {
      return cat;
    }
    final title = (name ?? '').toLowerCase();
    if (title.contains('coffee') ||
        title.contains('cafe') ||
        title.contains('咖啡') ||
        title.contains('餐') ||
        title.contains('食') ||
        title.contains('bistro') ||
        title.contains('lunch') ||
        title.contains('dinner')) {
      return 'food';
    }
    if (title.contains('salary') ||
        title.contains('薪') ||
        title.contains('income') ||
        title.contains('payment') ||
        title.contains('酬金') ||
        title.contains('收入')) {
      return 'income';
    }
    if (title.contains('market') ||
        title.contains('超市') ||
        title.contains('grocer') ||
        title.contains('市集')) {
      return 'groceries';
    }
    if (title.contains('subway') ||
        title.contains('metro') ||
        title.contains('taxi') ||
        title.contains('fuel') ||
        title.contains('地铁') ||
        title.contains('出行') ||
        title.contains('车') ||
        title.contains('加油')) {
      return 'transport';
    }
    if (title.contains('refund') || title.contains('退款')) {
      return 'refund';
    }
    if (title.contains('bill') ||
        title.contains('electric') ||
        title.contains('water') ||
        title.contains('phone') ||
        title.contains('internet') ||
        title.contains('电费') ||
        title.contains('水费') ||
        title.contains('话费') ||
        title.contains('宽带')) {
      return 'bills';
    }
    if (title.contains('book') ||
        title.contains('school') ||
        title.contains('书') ||
        title.contains('学')) {
      return 'education';
    }
    if (title.contains('cinema') ||
        title.contains('movie') ||
        title.contains('museum') ||
        title.contains('影院') ||
        title.contains('博')) {
      return 'entertainment';
    }
    if (title.contains('pharmacy') ||
        title.contains('medic') ||
        title.contains('药')) {
      return 'health';
    }
    if (title.contains('subscription') ||
        title.contains('plan') ||
        title.contains('订阅')) {
      return 'subscription';
    }
    if (title.contains('interest') || title.contains('利息')) {
      return 'interest';
    }
    return cat.isNotEmpty ? cat : 'shopping';
  }

  /// 获取品类对应的 Material 图标。
  static IconData getIcon(String? category, {String? name}) {
    final cat = resolveCategory(category, name: name);
    return switch (cat) {
      'food' => Icons.local_cafe_rounded,
      'income' => Icons.payments_rounded,
      'groceries' => Icons.local_grocery_store_rounded,
      'bills' => Icons.receipt_long_rounded,
      'transport' => Icons.directions_subway_rounded,
      'entertainment' => Icons.sports_esports_rounded,
      'shopping' => Icons.shopping_bag_rounded,
      'health' => Icons.medical_services_rounded,
      'education' => Icons.school_rounded,
      'home' => Icons.home_rounded,
      'subscription' => Icons.subscriptions_rounded,
      'refund' => Icons.replay_rounded,
      'interest' => Icons.trending_up_rounded,
      _ => Icons.swap_horiz_rounded,
    };
  }

  /// 获取品类专属的主题色。
  static Color getColor(BuildContext context, String? category, {String? name}) {
    final cat = resolveCategory(category, name: name);
    return switch (cat) {
      'food' => const Color(0xFFD97706),
      'income' => const Color(0xFF10B981),
      'groceries' => const Color(0xFF0D9488),
      'bills' => const Color(0xFFB45309),
      'transport' => const Color(0xFF2563EB),
      'entertainment' => const Color(0xFF7C3AED),
      'shopping' => const Color(0xFF9333EA),
      'health' => const Color(0xFFE11D48),
      'education' => const Color(0xFFEA580C),
      'home' => const Color(0xFFCA8A04),
      'subscription' => const Color(0xFF8B5CF6),
      'refund' => const Color(0xFF0891B2),
      'interest' => const Color(0xFF059669),
      _ => AppColors.ink(context),
    };
  }

  /// 获取品类专属的浅色背景底色。
  static Color getBackgroundColor(
    BuildContext context,
    String? category, {
    String? name,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cat = resolveCategory(category, name: name);
    if (isDark) {
      return getColor(context, cat, name: name).withValues(alpha: 0.15);
    }
    return switch (cat) {
      'food' => const Color(0xFFFEF3C7),
      'income' => const Color(0xFFD1FAE5),
      'groceries' => const Color(0xFFCCFBF1),
      'bills' => const Color(0xFFFDE68A),
      'transport' => const Color(0xFFDBEAFE),
      'entertainment' => const Color(0xFFEDE9FE),
      'shopping' => const Color(0xFFF3E8FF),
      'health' => const Color(0xFFFFE4E6),
      'education' => const Color(0xFFFFEDD5),
      'home' => const Color(0xFFFEF9C3),
      'subscription' => const Color(0xFFF3E8FF),
      'refund' => const Color(0xFFCFFAFE),
      'interest' => const Color(0xFFA7F3D0),
      _ => AppColors.line(context).withValues(alpha: 0.4),
    };
  }

  /// 获取品类对应的高清图片 URL（优先使用 [transaction.userIcon]）。
  static String getEffectiveImageUrl(Transaction transaction) {
    if (transaction.userIcon != null &&
        transaction.userIcon!.trim().isNotEmpty) {
      return transaction.userIcon!.trim();
    }
    return '';
  }

  /// 构建自适应宽窄屏的品类/商家头像组件。
  ///
  /// 在宽屏（[AppLayout.isWideWindow] 为 true）下通过 [HeroMode] 自动禁用 Hero 飞行，
  /// 避免主从左右分栏布局中发生夸窗格飞行或闪烁；
  /// 在窄屏下保留完整丝滑的 Hero 过渡动画。
  static Widget buildAdaptiveCategoryAvatar({
    required BuildContext context,
    required Transaction transaction,
    required String heroTag,
    double size = 36,
    double iconSize = 20,
    BorderRadius? borderRadius,
  }) {
    final radius = borderRadius ?? BorderRadius.circular(size > 40 ? 14 : 11);
    final iconData = getIcon(
      transaction.category,
      name: transaction.moneyActionName,
    );
    final iconColor = getColor(
      context,
      transaction.category,
      name: transaction.moneyActionName,
    );
    final bgColor = getBackgroundColor(
      context,
      transaction.category,
      name: transaction.moneyActionName,
    );
    final imageUrl = getEffectiveImageUrl(transaction);

    // 内部头像展示：有网络图片时展示图片，加载失败或离线时平滑回退至语义图标
    final avatarContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: NetworkWebImage(
          imageUrl,
          size: Size.square(size),
          fit: BoxFit.cover,
          fallbackWidget: Center(
            child: Icon(iconData, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );

    // 宽屏模式下禁用 Hero，窄屏模式启用 Hero
    final isWide = AppLayout.isWideWindow(context);
    return HeroMode(
      enabled: !isWide,
      child: Hero(
        tag: heroTag,
        flightShuttleBuilder: (
          flightContext,
          animation,
          direction,
          from,
          to,
        ) => ClipRRect(
          borderRadius: radius,
          child: NetworkWebImage(
            imageUrl,
            size: Size.square(size),
            fit: BoxFit.cover,
            fallbackWidget: Center(
              child: Icon(iconData, size: iconSize, color: iconColor),
            ),
          ),
        ),
        child: avatarContent,
      ),
    );
  }
}
