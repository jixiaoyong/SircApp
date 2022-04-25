import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'expandable_page_view.dart';

class ImgText {
  final String imageUrl;
  final String title;

  ImgText(this.imageUrl, this.title);
}

main() {
  final list = List.generate(28, (index) {
    var data = ImgText(
        "https://www.bing.com/th/id/ABT4B60F8D67F10805ACFA316E3A1A576953BF17EBFF560304B89FB2B7190DFB925?qlt=90&pid=InlineBlock",
        "title$index");
    return data;
  });
  runApp(
    MaterialApp(
      home: Scaffold(
        body: JingangWidget<ImgText>(
          data: list,
          itemBuilder: (BuildContext context, int index, int pageIndex, data) {
            return Container(
              margin: const EdgeInsets.all(5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    data.imageUrl,
                    height: 40,
                    width: 40,
                    fit: BoxFit.fitHeight,
                  ),
                  Text(
                    data.title,
                    overflow: TextOverflow.clip,
                  )
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}

/*
* @description: “金刚位”: a widget contains pages, which layout children in a grid,
*  can scroll horizon
*
* feat: when user scroll between pages has different height, the widget will change
* height to fit the height of the page automatically.
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/24
*/
class JingangWidget<T> extends StatefulWidget {
  final List<T> data;
  final IndicatorBuilder? indicatorBuilder;
  final double childAspectRatio;
  final int childCountPerPage;
  final int childCountPerRow;

  // indicator position offset to widget: dx means left offset, dy means bottom offset
  final Offset indicatorOffset;

  final ExpandablePageItemBuilder itemBuilder;

  // item builder
  const JingangWidget(
      {Key? key,
      required this.data,
      required this.itemBuilder,
      this.indicatorBuilder,
      this.indicatorOffset = const Offset(0, 0),
      this.childAspectRatio = 0.55,
      this.childCountPerRow = 6,
      this.childCountPerPage = 12})
      : super(key: key);

  @override
  State<JingangWidget> createState() => _JingangWidgetState();
}

class _JingangWidgetState extends State<JingangWidget> {
  @override
  Widget build(BuildContext context) {
    var childCount = widget.data.length;

    return Container(
      child: ExpandablePageView(
        pageBuilder: (context, index) {
          final int childIndexStart = index * widget.childCountPerPage;
          final int childIndexExpectEnd =
              childIndexStart + widget.childCountPerPage - 1;
          final int childIndexEnd = childIndexExpectEnd > childCount - 1
              ? childCount - 1
              : childIndexExpectEnd;
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.childCountPerRow,
                childAspectRatio: widget.childAspectRatio),
            itemBuilder: (context, subIndex) {
              // the index of the child in the total children
              final int childIndex = childIndexStart + subIndex;
              var data = widget.data[childIndex];
              return widget.itemBuilder(context, subIndex, index, data);
            },
            itemCount: childIndexEnd - childIndexStart + 1,
            shrinkWrap: true,
          );
        },
        pageCount: (widget.data.length / widget.childCountPerPage).ceil(),
        childAspectRatio: widget.childAspectRatio,
        indicatorOffset: widget.indicatorOffset,
        indicatorBuilder: widget.indicatorBuilder ??
            (context, onPageSelected, scrollPercentage) {
              return ScrollableIndicator(
                onPageSelected: onPageSelected,
                scrollPercentage: scrollPercentage,
              );
            },
      ),
    );
  }
}

/// jingang item builder
/// [index] is the index of the child in the total children
/// [pageIndex] is the index of the page
/// [data] is the data of the item
typedef ExpandablePageItemBuilder<T> = Widget Function(
    BuildContext context, int index, int pageIndex, T data);
