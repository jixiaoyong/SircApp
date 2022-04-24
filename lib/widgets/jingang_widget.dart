import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:sirc/utils/logger.dart';

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
class ImgText {
  final String imageUrl;
  final String title;

  ImgText(this.imageUrl, this.title);
}

main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: JingangApp(),
      ),
    ),
  );
}

class JingangApp extends StatefulWidget {
  const JingangApp({Key? key}) : super(key: key);

  @override
  State<JingangApp> createState() => _JingangAppState();
}

class _JingangAppState extends State<JingangApp> {
  final list = List.generate(28, (index) {
    var data = ImgText(
        "https://www.bing.com/th/id/ABT4B60F8D67F10805ACFA316E3A1A576953BF17EBFF560304B89FB2B7190DFB925?qlt=90&pid=InlineBlock",
        "title$index");
    return data;
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: JingangWidget(
        childCount: list.length,
        itemBuilder: (context, index, pageIndex, data) {
          return Container(
            margin: const EdgeInsets.all(5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  data.imageUrl,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
                Text(
                  data.title,
                  overflow: TextOverflow.clip,
                )
              ],
            ),
          );
        },
        data: list,
        childAspectRatio: 0.55,
        indicatorBuilder: (context, onPageSelected, scrollPercentage) {
          return ScrollableIndicator(
            onPageSelected: onPageSelected,
            scrollPercentage: scrollPercentage,
          );
        },
      ),
    );
  }
}

class JingangWidget<T> extends StatefulWidget {
  final List<T> data;

  // the number of all children
  final int childCount;

  final double childAspectRatio;

  // the number of children in one page
  final int childCountPerRow;

  // the number of rows in one page
  final int rowCountPerPage;

  // the number of page
  late final int pageCount;

  late final int _childCountPerPage;

  // item builder
  final JingangItemWidgetBuilder itemBuilder;

  // indicator builder
  final IndicatorBuilder? indicatorBuilder;

  // the listener of page scroll percentage
  final ValueChanged<double>? onPageScrollPercent;

  JingangWidget({
    Key? key,
    required this.data,
    required this.childCount,
    this.childCountPerRow = 6,
    this.rowCountPerPage = 2,
    this.childAspectRatio = 1.0,
    required this.itemBuilder,
    this.indicatorBuilder,
    this.onPageScrollPercent,
  }) : super(key: key) {
    _childCountPerPage = childCountPerRow * rowCountPerPage;
    pageCount = (childCount / _childCountPerPage).ceil();
  }

  @override
  _JingangWidgetState createState() => _JingangWidgetState();
}

class _JingangWidgetState extends State<JingangWidget> {
  late PageController _pageViewController;
  late final List<double?> _viewPageHeightList;

  var _currentPageHeight = 0.0;

  // the current page scroll percentage in total page, 0.0 - 1.0
  double _pageScrollPercentage = 0.0;
  int currentPage = 0;

  @override
  void initState() {
    _viewPageHeightList = List.generate(widget.pageCount, (index) {
      return null;
    });

    _pageViewController = PageController(initialPage: currentPage);
    _pageViewController.addListener(() {
      final pageIndexPercent = _pageViewController.page ?? 0;

      _pageScrollPercentage = pageIndexPercent / (widget.pageCount - 1);
      widget.onPageScrollPercent?.call(_pageScrollPercentage);

      if (pageIndexPercent % 1 != 0) {
        // Does not handle the case where the page is just on the edge

        // estimate which direction the page is scrolling to
        if (_pageViewController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          currentPage = pageIndexPercent.floor();
          final currentPageHeight = _viewPageHeightList[currentPage]!;

          var currentPageScrollPercentage =
              pageIndexPercent - pageIndexPercent.floor();
          final nextPageHeight =
              _viewPageHeightList[pageIndexPercent.floor() + 1] ??
                  currentPageHeight;
          _currentPageHeight = currentPageHeight +
              currentPageScrollPercentage *
                  (nextPageHeight - currentPageHeight);
        } else {
          currentPage = pageIndexPercent.ceil();
          final currentPageHeight = _viewPageHeightList[currentPage]!;

          var currentPageScrollPercentage =
              pageIndexPercent.ceil() - pageIndexPercent;
          final previousPageHeight =
              _viewPageHeightList[pageIndexPercent.ceil() - 1] ??
                  currentPageHeight;
          _currentPageHeight = currentPageHeight +
              currentPageScrollPercentage *
                  (previousPageHeight - currentPageHeight);
        }
      } else {
        // handle the case where the page is just on the edge
        currentPage = pageIndexPercent.toInt();
        _currentPageHeight = _viewPageHeightList[currentPage]!;
      }

      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final indicatorBuilder = widget.indicatorBuilder;
      return SizedBox(
        height: _currentPageHeight == 0
            ? constraints.minHeight
            : _currentPageHeight,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            PageView.builder(
              physics: const ClampingScrollPhysics(),
              controller: _pageViewController,
              itemBuilder: (context, index) {
                final int childIndexStart = index * widget._childCountPerPage;
                final int childIndexExpectEnd =
                    childIndexStart + widget._childCountPerPage - 1;
                final int childIndexEnd =
                    childIndexExpectEnd > widget.childCount
                        ? widget.childCount - 1
                        : childIndexExpectEnd;
                return OverflowBox(
                  minHeight: 0,
                  maxHeight: double.infinity,
                  alignment: Alignment.topCenter,
                  child: SizeReportableContainer(
                    onSizeChange: (size) {
                      if (size != null) {
                        _viewPageHeightList[index] = size.height;
                        if (index == currentPage) {
                          _currentPageHeight = size.height;
                        }
                        LogUtils.d(
                            "index: $index, size: $size, _viewPageHeightList: $_viewPageHeightList");
                      }
                    },
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: widget.childCountPerRow,
                          childAspectRatio: widget.childAspectRatio),
                      itemBuilder: (context, subIndex) {
                        // the index of the child in the total children
                        final int childIndex = childIndexStart + subIndex;
                        var data = widget.data[childIndex];
                        return widget.itemBuilder(
                            context, index, subIndex, data);
                      },
                      itemCount: childIndexEnd - childIndexStart + 1,
                      shrinkWrap: true,
                    ),
                  ),
                );
              },
              itemCount: widget.pageCount,
            ),
            if (indicatorBuilder != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    indicatorBuilder(context, (index) {
                      _pageViewController.jumpToPage(index);
                    }, _pageScrollPercentage)
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
              ),
          ],
        ),
      );
    });
  }
}

/// a indicator for [JingangWidget],which can scroll when the page is scrolling
class ScrollableIndicator extends StatelessWidget {
  final ValueChanged<int> onPageSelected;
  final double scrollPercentage;
  final double indicatorHeight;
  final double indicatorBackgroundWidth;
  final double indicatorWidth;
  final Color indicatorColor;
  final Color indicatorBackgroundColor;

  ScrollableIndicator(
      {Key? key,
      required this.onPageSelected,
      required this.scrollPercentage,
      this.indicatorHeight = 10,
      this.indicatorBackgroundWidth = 100,
      this.indicatorWidth = 50,
      this.indicatorColor = Colors.black,
      this.indicatorBackgroundColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    widget(BuildContext context, ValueChanged<int> onPageSelected,
        double scrollPercentage) {
      return Container(
        margin: const EdgeInsets.all(10),
        width: indicatorBackgroundWidth,
        decoration: BoxDecoration(
          color: indicatorColor,
          borderRadius: BorderRadius.all(Radius.circular(indicatorHeight / 2)),
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(
                  left: scrollPercentage *
                      (indicatorBackgroundWidth - indicatorWidth)),
              width: indicatorWidth,
              height: indicatorHeight,
              decoration: BoxDecoration(
                color: indicatorBackgroundColor,
                borderRadius:
                    BorderRadius.all(Radius.circular(indicatorHeight / 2)),
              ),
            )
          ],
        ),
      );
    }

    return Container(
      child: widget(context, onPageSelected, scrollPercentage),
    );
  }
}

/// jingang item builder
/// [index] is the index of the child in the total children
/// [pageIndex] is the index of the page
/// [data] is the data of the item
typedef JingangItemWidgetBuilder<T> = Widget Function(
    BuildContext context, int index, int pageIndex, T data);

/// indicator builder
/// [index] the index of the indicator
/// [onPageSelected] the callback when the page is selected
/// [scrollPercentage] the percentage of the page view scroll:
/// scrollPercentage = offset / the sum of  all page width, 0.0 is the start, 1.0 is the end
typedef IndicatorBuilder = Widget Function(BuildContext context,
    ValueChanged<int> onPageSelected, double scrollPercentage);

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
