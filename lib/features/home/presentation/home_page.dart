import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/home_controller.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/utils/color_extension.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/utils/toast.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/widgets/expandable_page_view.dart';
import 'package:sirc/widgets/footlights_for_bank_card.dart';
import 'package:sirc/widgets/jingang_widget.dart';
import 'package:sirc/widgets/line_graph.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/widgets/title_text.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final homeState = ref.watch(homeControllerProvider);
    final userAvatar = ref.watch(
      navigationControllerProvider.select((s) => s.userAvatar),
    );
    final tabs = [
      (Languages.follow, 0x0),
      (Languages.hot, 0x1),
      (Languages.explore, 0x2),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  HomeTopBodyWidget(
                    homeState: homeState,
                    userAvatar: userAvatar,
                  ),
                ],
              ),
            ),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                pinned: true,
                toolbarHeight: MediaQuery.of(context).viewPadding.top,
                primary: false,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                bottom: TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: Colors.indigoAccent.withValues(alpha: 0.6),
                      width: 3.dp,
                    ),
                    insets: EdgeInsets.symmetric(horizontal: 50.dp),
                  ),
                  tabs: tabs.map((e) {
                    return Tab(
                      text: e.$1,
                    );
                  }).toList(),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          children: tabs.map((e) {
            return SafeArea(
              top: false,
              bottom: false,
              child: Builder(
                builder: (context) {
                  return CustomScrollView(
                    key: PageStorageKey<String>(e.$2.toString()),
                    slivers: [
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context,
                        ),
                      ),
                      SliverFixedExtentList(
                        itemExtent: 120.dp,
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Toast.showDefaultToast();
                              },
                              child: HomeTabViewListItemWidget(
                                tabTitle: e.$1,
                                index: index,
                              ),
                            );
                          },
                          childCount: 30,
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// 首页顶部可滚动内容区
class HomeTopBodyWidget extends ConsumerWidget {
  const HomeTopBodyWidget({
    super.key,
    required this.homeState,
    required this.userAvatar,
  });

  final HomeState homeState;
  final String userAvatar;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.dp),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TitleText(text: Languages.dashboard),
                Expanded(child: Container()),
                Padding(
                  padding: EdgeInsets.only(right: 10.dp),
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(navigationControllerProvider.notifier)
                          .openDrawer();
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.dp),
                      child: NetworkWebImage(
                        userAvatar,
                        size: Size(50.dp, 50.dp),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const HomeBankCardCarousel(),
          Padding(
            padding: EdgeInsets.only(top: 10.dp),
            child: JingangWidget(
              // 行高由图标和两行文字决定，不随每列宽度增长。
              mainAxisExtent: 80,
              childAspectRatio: 0.7,
              data: homeState.quickActions,
              indicatorOffset: Offset(0, -2.dp),
              itemBuilder:
                  (BuildContext context, int index, int pageIndex, data) {
                return GestureDetector(
                  onTap: () {
                    Toast.showDefaultToast();
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 40.dp,
                        child: NetworkWebImage(
                          data.imageUrl,
                          fit: BoxFit.contain,
                          isAvatar: false,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.dp),
                        child: Text(
                          data.title,
                          overflow: TextOverflow.clip,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1,
                            fontSize: 11.sp,
                            color: "#ffb6c6d5".hexToColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              indicatorBuilder: (context, onPageSelected, scrollPercentage) {
                return ScrollableIndicator(
                  onPageSelected: onPageSelected,
                  scrollPercentage: scrollPercentage,
                  indicatorColor: Colors.indigoAccent.withValues(alpha: 0.6),
                  indicatorBackgroundColor:
                      Colors.indigoAccent.withValues(alpha: 0.25),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.dp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleText(text: Languages.february),
                Builder(
                  builder: (context) {
                    final weekLabels = [
                      Languages.mon,
                      Languages.tues,
                      Languages.wed,
                      Languages.thur,
                      Languages.fri,
                      Languages.satu,
                      Languages.sun,
                    ];
                    return SizedBox(
                      height: 200.dp,
                      width: double.infinity,
                      child: LineGraph(
                        data: List.generate(
                          homeState.weeklyPercentages.length,
                          (index) => (
                            weekLabels[index % weekLabels.length],
                            homeState.weeklyPercentages[index],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TitleText(text: Languages.translations),
                    const Spacer(),
                    GestureDetector(
                      child: const Icon(Icons.arrow_forward),
                      onTap: () {
                        // 保留后续扩展逻辑
                      },
                    ),
                  ],
                ),
                SizedBox(
                  // 扣除内外各 20 的纵向留白后，为图标、金额和双行标签
                  // 保留 120 逻辑像素；默认字体行高下内容至少需要 113。
                  height: 160.dp,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.dp,
                          horizontal: 15.dp,
                        ),
                        child: Container(
                          width: 120.dp,
                          padding: EdgeInsets.all(10.dp),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.dp),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withValues(alpha: 0.1),
                                spreadRadius: 5.dp,
                                blurRadius: 5.dp,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.run_circle_outlined,
                                color: Colors.blue,
                                size: 50.dp,
                              ),
                              Text(
                                r"-$20",
                                style: TextStyle(
                                  fontSize: 20.dp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                index % 2 == 0
                                    ? Languages.moneySend
                                    : Languages.moneyRecharge,
                                style: TextStyle(
                                  fontSize: 12.dp,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    scrollDirection: Axis.horizontal,
                  ),
                ),
                Text(
                  Languages.articles,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 按局部可用宽度显示一张露边或多张银行卡，卡片高度不随宽度增长。
class HomeBankCardCarousel extends ConsumerWidget {
  const HomeBankCardCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final homeState = ref.watch(homeControllerProvider);
    return SizedBox(
      height: 255.dp,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          if (!width.isFinite || width <= 0) return const SizedBox.shrink();
          // 每页含左右各 10 的间距，卡片本体最大 400 逻辑像素。
          final fraction = (width * 0.8).clamp(0.0, 420.0) / width;
          return Stack(
            children: [
              FootlightsForBankCard(screenWidth: width),
              _HomeBankCardPages(
                // fraction 不可变；重建分页状态让 Flutter 正常解绑并释放旧控制器。
                key: ValueKey(fraction),
                viewportFraction: fraction,
                homeState: homeState,
                onPageChanged: (index) => ref
                    .read(homeControllerProvider.notifier)
                    .setBankIndex(index),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeBankCardPages extends StatefulWidget {
  const _HomeBankCardPages({
    super.key,
    required this.viewportFraction,
    required this.homeState,
    required this.onPageChanged,
  });

  final double viewportFraction;
  final HomeState homeState;
  final ValueChanged<int> onPageChanged;

  @override
  State<_HomeBankCardPages> createState() => _HomeBankCardPagesState();
}

class _HomeBankCardPagesState extends State<_HomeBankCardPages> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: widget.homeState.currentBankIndex,
      viewportFraction: widget.viewportFraction,
      // resize 后以业务选中索引为准，不恢复旧尺寸对应的 PageStorage 位置。
      keepPage: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _localizedBankName(String bankName) {
    switch (bankName) {
      case 'CNSS':
        return Languages.cnss;
      case 'DXSS':
        return Languages.dxss;
      case 'CID':
        return Languages.cid;
      default:
        return bankName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = widget.homeState;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 20.dp, 0, 35.dp),
          child: PageView.builder(
            controller: _controller,
            itemCount: homeState.banks.length,
            onPageChanged: widget.onPageChanged,
            itemBuilder: (context, index) {
              final card = homeState.banks[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.dp),
                child: BankCardWidget(
                  bankName: _localizedBankName(card.bankName),
                  cardNumber: card.cardNumber,
                  ownerName: card.ownerName,
                  expirationDate: card.expirationDate,
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 20.dp,
          right: 0,
          left: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(homeState.banks.length, (index) {
              return GestureDetector(
                key: ValueKey('bank-card-indicator-$index'),
                onTap: () => _controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                ),
                child: Container(
                  width: 10.dp,
                  height: 10.dp,
                  margin: EdgeInsets.symmetric(horizontal: 5.dp),
                  decoration: BoxDecoration(
                    color: (homeState.currentBankIndex == index
                            ? Colors.white
                            : "#ffb6c6d5".hexToColor)
                        .withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10.dp),
                  ),
                ),
              );
            }, growable: false),
          ),
        ),
      ],
    );
  }
}

/// 首页文章/列表骨架项
class HomeTabViewListItemWidget extends StatelessWidget {
  const HomeTabViewListItemWidget({
    super.key,
    required this.tabTitle,
    required this.index,
  });

  final String tabTitle;
  final int index;

  @override
  Widget build(BuildContext context) {
    var bgColor = Colors.grey.shade200;
    return Container(
      margin: EdgeInsets.all(10.dp),
      height: 100.dp,
      color: Colors.transparent,
      child: Row(
        children: [
          Container(
            width: 100.dp,
            height: 100.dp,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "$tabTitle $index",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.dp, vertical: 5.dp),
              child: SizedBox(
                height: 100.dp,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 30.dp,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(5.dp),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 30.dp, bottom: 15.dp),
                      child: Container(
                        height: 15.dp,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(5.dp),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 120.dp),
                      child: Container(
                        height: 10.dp,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(5.dp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
