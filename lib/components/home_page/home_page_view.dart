import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/bean/pair.dart';
import 'package:sirc/components/home_page/home_page_state.dart';
import 'package:sirc/components/slide_menu/slide_menu_logic.dart';
import 'package:sirc/data/common_date.dart';
import 'package:sirc/utils/color_extension.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/utils/toast.dart';
import 'package:sirc/widgets/expandable_page_view.dart';
import 'package:sirc/widgets/footlights_for_bank_card.dart';
import 'package:sirc/widgets/jingang_widget.dart';
import 'package:sirc/widgets/line_graph.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/widgets/title_text.dart';

import 'home_page_logic.dart';

/*
* @description: Home page
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class HomePage extends StatelessWidget {
  final logic = Get.put(HomePageLogic());
  final state = Get.find<HomePageLogic>().state;

  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final slideMenuLogic = Get.find<SlideMenuLogic>();

    state.pageController =
        PageController(initialPage: 0, viewportFraction: 0.8);

    var _tabs = state.tabDatas;
    return DefaultTabController(
      length: _tabs.length,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  HomeTopBodyWidget(
                      state: state,
                      logic: logic,
                      slideMenuLogic: slideMenuLogic),
                ],
              ),
            ),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                pinned: true,
                toolbarHeight: MediaQuery.of(context).viewPadding.top,
                // elevation: 0,
                primary: false,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                bottom: TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                          color: Colors.indigoAccent.withOpacity(0.6),
                          width: 3.dp),
                      insets: EdgeInsets.symmetric(horizontal: 50.dp),
                    ),
                    tabs: _tabs.map((e) {
                      return Tab(
                        text: e.first,
                      );
                    }).toList()),
              ),
            ),
          ];
        },
        body: TabBarView(
            children: _tabs.map((e) {
          return SafeArea(
            top: false,
            bottom: false,
            child: Builder(builder: (context) {
              return CustomScrollView(
                key: PageStorageKey<String>(e.second.toString()),
                slivers: [
                  SliverOverlapInjector(
                    // This is the flip side of the SliverOverlapAbsorber
                    // above.
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
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
                                item: e, index: index));
                      },
                      childCount: 30,
                    ),
                  ),
                ],
              );
            }),
          );
        }).toList()),
      ),
    );
  }
}

class HomeTabViewListItemWidget extends StatelessWidget {
  const HomeTabViewListItemWidget({
    Key? key,
    required this.item,
    required this.index,
  }) : super(key: key);

  final Pair<String, int> item;
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
                color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                "${item.first} $index",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold),
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
                          borderRadius: BorderRadius.circular(5.dp)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 30.dp, bottom: 15.dp),
                      child: Container(
                        height: 15.dp,
                        decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(5.dp)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 120.dp),
                      child: Container(
                        height: 10.dp,
                        decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(5.dp)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class HomeTopBodyWidget extends StatelessWidget {
  const HomeTopBodyWidget({
    Key? key,
    required this.state,
    required this.logic,
    required this.slideMenuLogic,
  }) : super(key: key);

  final HomePageState state;
  final HomePageLogic logic;
  final SlideMenuLogic slideMenuLogic;

  @override
  Widget build(BuildContext context) {
    return Obx(() => SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.dp),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TitleText(text: "Dashboard".tr),
                    Expanded(child: Container()),
                    Padding(
                      padding: EdgeInsets.only(right: 10.dp),
                      child: GestureDetector(
                        onTap: () => slideMenuLogic.onMenuTap?.call(true),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.dp),
                          child: NetworkWebImage(
                            state.userAvatar.value,
                            size: Size(50.dp, 50.dp),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 255.dp,
                child: Stack(
                  children: [
                    FootlightsForBankCard(
                      screenWidth: CommonData.realScreenWidth,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 40.dp, 0, 35.dp),
                      child: PageView.builder(
                        controller: state.pageController,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.dp),
                            child: state.banks[index],
                          );
                        },
                        itemCount: state.banks.length,
                        onPageChanged: (index) {
                          logic.setBankIndex(index);
                        },
                      ),
                    ),
                    Positioned(
                        bottom: 20.dp,
                        right: 0,
                        left: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(state.banks.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                logic.jumpToPage(index);
                              },
                              child: Container(
                                width: 10.dp,
                                height: 10.dp,
                                margin: EdgeInsets.symmetric(horizontal: 5.dp),
                                decoration: BoxDecoration(
                                    color:
                                    (state.currentBankIndex.value == index
                                        ? Colors.white
                                        : "#ffb6c6d5".hexToColor)
                                        .withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(10.dp)),
                              ),
                            );
                          }, growable: false),
                        ))
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.dp),
                child: JingangWidget(
                  childAspectRatio: 0.7,
                  data: state.list,
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
                          NetworkWebImage(
                            data.imageUrl,
                            size: Size(40.dp, 40.dp),
                            fit: BoxFit.fitHeight,
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
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  indicatorBuilder:
                      (context, onPageSelected, scrollPercentage) {
                    return ScrollableIndicator(
                      onPageSelected: onPageSelected,
                      scrollPercentage: scrollPercentage,
                      indicatorColor: Colors.indigoAccent.withOpacity(0.6),
                      indicatorBackgroundColor:
                      Colors.indigoAccent.withOpacity(0.25),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.dp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleText(text: "February".tr),
                    SizedBox(
                      height: 200.dp,
                      width: double.infinity,
                      child: LineGraph(
                        data: state.dataChange,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TitleText(text: "Translations".tr),
                        const Spacer(),
                        GestureDetector(
                          child: const Icon(Icons.arrow_forward),
                          onTap: () {
                            // todo add some logic
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: 150.dp,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.dp, horizontal: 15.dp),
                            child: Container(
                              width: 120.dp,
                              padding: EdgeInsets.all(10.dp),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.dp),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12.withOpacity(0.1),
                                        spreadRadius: 5.dp,
                                        blurRadius: 5.dp)
                                  ]),
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
                                        color: Colors.black),
                                  ),
                                  const Spacer(),
                                  Text(
                                    index % 2 == 0
                                        ? "Money Send".tr
                                        : "Money Recharge".tr,
                                    style: TextStyle(
                                        fontSize: 12.dp, color: Colors.black54),
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
                      "Articles".tr,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class HomeTabList extends StatefulWidget {
  final List<Pair<String, int>> data;
  final ValueChanged<int> onTap;

  const HomeTabList({Key? key, required this.data, required this.onTap})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeTabListState();
  }
}

class _HomeTabListState extends State<HomeTabList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: widget.data.length, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
        labelColor: Colors.black,
        controller: _tabController,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
              color: Colors.indigoAccent.withOpacity(0.6), width: 3.dp),
          insets: EdgeInsets.symmetric(horizontal: 50.dp),
        ),
        tabs: widget.data.map((e) {
          return Tab(
            text: e.first,
          );
        }).toList());
  }
}
