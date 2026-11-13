import 'package:material_ui/material_ui.dart';

class CommonTextButton extends StatelessWidget {
  const CommonTextButton({
    super.key,
    required this.isButtonEnabled,
    required this.onTap,
    required this.text,
  });

  final bool isButtonEnabled;
  final GestureTapCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 50),
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: isButtonEnabled ? onTap : null,
          child: Text(text),
        ),
      ),
    );
  }
}
