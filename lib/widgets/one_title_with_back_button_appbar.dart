import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:sirc/core/theme/app_theme.dart';

/*
* @description: common app bar with one title and back button
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class OneTitleWithBackButtonAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  const OneTitleWithBackButtonAppBar({super.key, this.title = '', this.onBack});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (onBack != null) {
            onBack!();
          } else {
            Navigator.of(context).maybePop();
          }
        },
      ),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

@Preview(name: 'One Title With Back Button AppBar - Light')
Widget oneTitleWithBackButtonAppBarLightPreview() {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    themeMode: ThemeMode.light,
    home: const Scaffold(body: OneTitleWithBackButtonAppBar(title: 'Test')),
  );
}

@Preview(name: 'One Title With Back Button AppBar - Dark')
Widget oneTitleWithBackButtonAppBarDarkPreview() {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    themeMode: ThemeMode.dark,
    home: const Scaffold(body: OneTitleWithBackButtonAppBar(title: 'Test')),
  );
}
