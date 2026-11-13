import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/localization/app_locale.dart';

class AboutDescription extends StatefulWidget {
  const AboutDescription({super.key, required this.onOpenUrl});

  final void Function(BuildContext context, String url) onOpenUrl;

  @override
  State<AboutDescription> createState() => _AboutDescriptionState();
}

class _AboutDescriptionState extends State<AboutDescription> {
  late final TapGestureRecognizer _githubRecognizer;
  late final TapGestureRecognizer _onlineRecognizer;
  late final TapGestureRecognizer _pictureRecognizer;

  @override
  void initState() {
    super.initState();
    _githubRecognizer = _recognizer('https://github.com/jixiaoyong/SircApp');
    _onlineRecognizer = _recognizer('https://jixiaoyong.github.io/SircApp');
    _pictureRecognizer = _recognizer('https://huaban.com/pins/4619822724');
  }

  TapGestureRecognizer _recognizer(String url) =>
      TapGestureRecognizer()..onTap = () => widget.onOpenUrl(context, url);

  @override
  void dispose() {
    _githubRecognizer.dispose();
    _onlineRecognizer.dispose();
    _pictureRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final description = Languages.settings.aboutPageDescription;
    final linkStyle = TextStyle(color: Theme.of(context).colorScheme.secondary);

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        children: _buildDescriptionSpans(description, linkStyle),
      ),
    );
  }

  List<InlineSpan> _buildDescriptionSpans(String text, TextStyle linkStyle) {
    final spans = <InlineSpan>[];
    final markers = <(String, String, TapGestureRecognizer)>[
      ('{github}', 'Github.com/jixiaoyong/SircApp', _githubRecognizer),
      ('{online}', 'jixiaoyong.github.io/SircApp', _onlineRecognizer),
      ('{picture}', 'a picture', _pictureRecognizer),
    ];
    var remaining = text;
    while (remaining.isNotEmpty) {
      final match = markers
          .map((marker) => (marker, remaining.indexOf(marker.$1)))
          .where((entry) => entry.$2 >= 0)
          .fold<((String, String, TapGestureRecognizer), int)?>(
            null,
            (earliest, entry) =>
                earliest == null || entry.$2 < earliest.$2 ? entry : earliest,
          );
      if (match == null) {
        spans.add(TextSpan(text: remaining));
        break;
      }
      if (match.$2 > 0) {
        spans.add(TextSpan(text: remaining.substring(0, match.$2)));
      }
      final marker = match.$1;
      spans.add(
        TextSpan(text: marker.$2, recognizer: marker.$3, style: linkStyle),
      );
      remaining = remaining.substring(match.$2 + marker.$1.length);
    }
    return spans;
  }
}
