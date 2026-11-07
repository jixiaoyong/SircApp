import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/bean/money_operate_bean.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/mock/mock_utils.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/number_extension.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/widgets/title_text.dart';

/// 个人中心页面，用户信息展示、流水列表与通用信息
class PersonPage extends ConsumerStatefulWidget {
  const PersonPage({super.key});

  @override
  ConsumerState<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends ConsumerState<PersonPage> {
  int _selectedMoneyIndex = 0;

  late List<MoneyOperateBean> _moneyOperateList;

  @override
  void initState() {
    super.initState();
    _moneyOperateList = MockUtils.moneyOperateList
        .map(
          (e) => e.copyWith(
            userIcon:
                "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80",
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final navState = ref.watch(navigationControllerProvider);

    final generalInformationList = [
      (Icons.email_outlined, "E-mail".tr),
      (Icons.phone_outlined, "Phone Number".tr),
      (Icons.location_on_outlined, "Local Address".tr),
      (Icons.credit_card_outlined, "Card Credit".tr),
    ];

    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.dp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      ref
                          .read(navigationControllerProvider.notifier)
                          .openDrawer();
                    },
                    icon: const Icon(Icons.more_horiz_rounded),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.dp),
                child: GestureDetector(
                  onTap: () {
                    ref.read(navigationControllerProvider.notifier).openDrawer();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.dp),
                    child: NetworkWebImage(
                      navState.userAvatar,
                      size: Size(100.dp, 100.dp),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10.dp, 0, 8.dp),
                child: Text(
                  navState.userName,
                  style: TextStyle(fontSize: 20.sp, color: Colors.black),
                ),
              ),
              Text(
                "Total Spending".tr,
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.dp, bottom: 30.dp),
                child: Text(
                  "\$90,960",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 200.dp,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _moneyOperateList.length,
                  itemBuilder: (context, index) {
                    final heroTag = "heroTag_$index";
                    final data = _moneyOperateList[index];
                    final isSelected = _selectedMoneyIndex == index;
                    final textColor = isSelected ? Colors.white : Colors.black;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMoneyIndex = index;
                        });
                        Navigator.of(context).pushNamed(
                          AppRoutes.HISTORY_DETAILS,
                          arguments: {
                            "data": data,
                            "heroTag": heroTag,
                          },
                        );
                      },
                      child: Container(
                        height: 200.dp,
                        width: 150.dp,
                        margin: EdgeInsets.symmetric(
                          vertical: 15.dp,
                          horizontal: 10.dp,
                        ),
                        padding: EdgeInsets.all(10.dp),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(10.dp),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.3),
                              blurRadius: 10.dp,
                              offset: const Offset(0, 5),
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: heroTag,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50.dp),
                                child: NetworkWebImage(
                                  data.userIcon!,
                                  size: Size.square(50.dp),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5.dp),
                              child: Text(
                                data.moneyAmount.toFormatedMoneyStr,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              data.moneyActionName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: textColor,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 2.dp),
                              child: Text(
                                data.time!,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: textColor.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10.dp,
                  vertical: 20.dp,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.dp),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.3),
                      blurRadius: 10.dp,
                      spreadRadius: .6.dp,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleText(text: "General Information".tr),
                    ...generalInformationList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.ABOUT);
                        },
                        child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            vertical: 10.dp,
                            horizontal: 20.dp,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius:
                                          BorderRadius.circular(5.dp),
                                    ),
                                    padding: EdgeInsets.all(5.dp),
                                    child: Icon(item.$1),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.dp),
                                    child: Text(item.$2),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_forward_ios_rounded),
                                ],
                              ),
                              if (index != generalInformationList.length - 1)
                                Container(
                                  height: 1,
                                  margin: EdgeInsets.only(top: 10.dp),
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
