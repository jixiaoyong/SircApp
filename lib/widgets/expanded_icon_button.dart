import 'package:flutter/material.dart';
import 'package:sirc/utils/size_extension.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class ExpandedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double height;
  final double maxWidth;
  final List<Color> colors;
  final String text;
  double? minWidth;
  bool? isExpanded = false;

  ExpandedIconButton(
      {Key? key,
      required this.icon,
      required this.onPressed,
      required this.height,
      required this.maxWidth,
      this.minWidth,
      required this.colors,
      required this.text,
      this.isExpanded})
      : super(key: key) {
    minWidth ??= height;
  }

  @override
  State<ExpandedIconButton> createState() => _ExpandedIconButtonState();
}

class _ExpandedIconButtonState extends State<ExpandedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double get _width =>
      widget.isExpanded == true ? widget.maxWidth : widget.minWidth!;
  late double _trueWidth;

  @override
  void initState() {
    var minWidth = widget.minWidth!;

    _trueWidth = widget.height;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _controller.addListener(() {
      setState(() {
        _trueWidth = (_width - minWidth) * _controller.value + minWidth;
        if (_trueWidth > widget.maxWidth) {
          _trueWidth = widget.maxWidth;
        }
      });
    });

    if (widget.isExpanded == true) {
      _controller.forward();
    }

    super.initState();
  }

  @override
  void didUpdateWidget(ExpandedIconButton oldWidget) {
    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded == true) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: _trueWidth,
      padding: widget.isExpanded == true
          ? EdgeInsets.all(0.1 * widget.height)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(widget.height / 2)),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Stack(
          children: <Widget>[
            if (widget.isExpanded == true)
              Positioned(
                left: 0.5 * widget.height,
                child: Container(
                  height: widget.height,
                  padding: EdgeInsets.only(bottom: 0.1 * widget.height),
                  alignment: Alignment.center,
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: widget.isExpanded == true
                  ? (_trueWidth - widget.height * 0.9)
                  : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                height: widget.height * 0.9,
                width: widget.height * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isExpanded == true
                      ? Colors.white
                      : Colors.transparent,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isExpanded == true
                      ? widget.colors[0]
                      : Colors.white,
                  size: widget.height * 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
