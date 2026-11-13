import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

/// Source-local detail navigation: replace siblings instead of stacking them.
void openSourceDetail(BuildContext context, String segment, {Object? extra}) {
  final router = GoRouter.of(context);
  final reported = router.routeInformationProvider.value.uri.path;
  final current = reported.isEmpty || reported == '/'
      ? router.routerDelegate.currentConfiguration.uri.path
      : reported;
  final source =
      '/${current.split('/').where((part) => part.isNotEmpty).first}';
  final location = '$source/$segment';
  if (current != source) {
    router.replace<void>(location, extra: extra);
  } else {
    router.push<void>(location, extra: extra);
  }
}
