import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sirc/utils/logger.dart';

import 'size_reportable_container.dart';

/*
 * @description: ExpandablePageView can be used to wrap a child widget, and expand
 * itself to fit the child widget.
 *
 * Which is useful while using [PageView] and want it to expand to fit the height
 * of the child widget automatically. Whether the height of child widget is
 * become shorter or taller.
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/24
*/
class ExpandablePageView extends StatefulWidget {
  final double childAspectRatio;

  // the number of page
  late final int pageCount;

  final IndexedWidgetBuilder pageBuilder;

  // indicator builder
  final IndicatorBuilder? indicatorBuilder;

  // the listener of page scroll percentage
  final ValueChanged<double>? onPageScrollPercent;

  // indicator position offset to widget: dx means left offset, dy means bottom offset
  final Offset indicatorOffset;

  ExpandablePageView({
    Key? key,
    this.childAspectRatio = 1.0,
    required this.pageBuilder,
    required this.pageCount,
    this.indicatorBuilder,
    this.onPageScrollPercent,
    this.indicatorOffset = const Offset(0.0, 0.0),
  }) : super(key: key);

  @override
  _ExpandablePageViewState createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView> {
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
    final isIndicatorVisible =
        widget.indicatorBuilder != null && widget.pageCount > 1;
    final pageViewPaddingBottom =
    widget.indicatorOffset.dy < 0 && isIndicatorVisible
        ? -widget.indicatorOffset.dy
        : 0.0;
    final indicatorPaddingBottom =
    widget.indicatorOffset.dy > 0 && isIndicatorVisible
        ? widget.indicatorOffset.dy
        : 0.0;

    return LayoutBuilder(builder: (context, constraints) {
      final indicatorBuilder = widget.indicatorBuilder;
      return SizedBox(
        height: _currentPageHeight == 0
            ? constraints.minHeight
            : _currentPageHeight + pageViewPaddingBottom,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: pageViewPaddingBottom),
              child: PageView.builder(
                physics: const ClampingScrollPhysics(),
                controller: _pageViewController,
                itemBuilder: (context, index) {
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
                          setState(() {});
                          LogUtils.d(
                              "index: $index, size: $size, _viewPageHeightList: $_viewPageHeightList");
                        }
                      },
                      child: widget.pageBuilder(context, index),
                    ),
                  );
                },
                itemCount: widget.pageCount,
              ),
            ),
            if (isIndicatorVisible)
              Positioned(
                bottom: indicatorPaddingBottom,
                left: widget.indicatorOffset.dx,
                right: 0,
                child: Row(
                  children: [
                    indicatorBuilder!(context, (index) {
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

/// a indicator for [ExpandablePageView],which can scroll when the page is scrolling
class ScrollableIndicator extends StatelessWidget {
  final ValueChanged<int> onPageSelected;
  final double scrollPercentage;
  final Size indicatorSize;
  final Size indicatorBackgroundSize;
  final Color indicatorColor;
  final Color indicatorBackgroundColor;

  ScrollableIndicator({Key? key,
    required this.onPageSelected,
    required this.scrollPercentage,
    this.indicatorSize = const Size(50, 10),
    this.indicatorBackgroundSize = const Size(100, 10),
    this.indicatorColor = Colors.black,
    this.indicatorBackgroundColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    widget(BuildContext context, ValueChanged<int> onPageSelected,
        double scrollPercentage) {
      return Container(
        margin: const EdgeInsets.all(10),
        width: indicatorBackgroundSize.width,
        height: indicatorBackgroundSize.height,
        decoration: BoxDecoration(
          color: indicatorBackgroundColor,
          borderRadius: BorderRadius.all(
              Radius.circular(indicatorBackgroundSize.height / 2)),
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(
                  left: scrollPercentage *
                      (indicatorBackgroundSize.width - indicatorSize.width)),
              width: indicatorSize.width,
              height: indicatorSize.height,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius:
                BorderRadius.all(Radius.circular(indicatorSize.height / 2)),
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

/// indicator builder
/// [index] the index of the indicator
/// [onPageSelected] the callback when the page is selected
/// [scrollPercentage] the percentage of the page view scroll:
/// scrollPercentage = offset / the sum of  all page width, 0.0 is the start, 1.0 is the end
typedef IndicatorBuilder = Widget Function(BuildContext context,
    ValueChanged<int> onPageSelected, double scrollPercentage);
