import 'package:flutter/widgets.dart';

/*
* @description: a widget that can report its size to its parent automatically
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/24
*/
class SizeReportableContainer extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size?> onSizeChange;

  SizeReportableContainer(
      {Key? key, required this.child, required this.onSizeChange})
      : super(key: key);

  @override
  State<SizeReportableContainer> createState() =>
      _SizeReportableContainerState();
}

class _SizeReportableContainerState extends State<SizeReportableContainer> {
  Size? _oldSize = null;

  @override
  Widget build(BuildContext context) {
    // get the size of the child
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (!mounted) {
        return;
      }
      final Size? size = context.size;
      if (_oldSize != size) {
        _oldSize = size;
        widget.onSizeChange(size);
      }
    });
    return Container(
      child: widget.child,
    );
  }
}
