import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

/// Application layout thresholds and commonly used content widths.
abstract final class AppLayout {
  /// Existing application-wide compact/wide boundary.
  static const double wideWindowWidth = 840;

  /// Common maximum widths for page content; these do not scale with viewport.
  static const double formContentMaxWidth = 520;
  static const double standardContentMaxWidth = 1017;

  /// Window-level decision, intentionally independent of any [LayoutScope].
  static bool isWideWindow(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wideWindowWidth;

  /// Container-level query that respects the nearest [LayoutScope].
  static ResponsiveQuery containerQuery(BuildContext context) =>
      ResponsiveQuery.of(context);
}
