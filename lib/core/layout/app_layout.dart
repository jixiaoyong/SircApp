import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

/// Application layout thresholds and commonly used content widths.
abstract final class AppLayout {
  /// Existing application-wide compact/wide boundary.
  static const double wideWindowWidth = 840;

  /// Common maximum widths for page content; these do not scale with viewport.
  static const double formContentMaxWidth = 520;
  static const double standardContentMaxWidth = 1017;

  /// Whether the available logical [width] uses the app's wide layout.
  ///
  /// Pass parent constraints for local layouts, not the window width.
  /// This is a layout classification, not a phone/tablet hardware check.
  static bool isWideWidth(double width) => width >= wideWindowWidth;

  /// Window-level decision, intentionally independent of any [LayoutScope].
  /// This classifies available logical width, not the physical device type.
  static bool isWideWindow(BuildContext context) =>
      isWideWidth(MediaQuery.sizeOf(context).width);

  /// Container-level query that respects the nearest [LayoutScope].
  static ResponsiveQuery containerQuery(BuildContext context) =>
      ResponsiveQuery.of(context);
}
