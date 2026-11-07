import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_locale.dart';
import '../../../utils/size_extension.dart';
import '../../../widgets/network_web_image.dart';
import '../../../widgets/one_title_with_back_button_appbar.dart';
import '../controllers/settings_controller.dart';

/*
* @description: 通知中心页面（Riverpod 现代架构）
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19 (Refactored to Riverpod 2.x)
*/
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听多语言变化以实时刷新界面文案
    ref.watch(localeProvider);

    final state = ref.watch(notificationsControllerProvider);
    final notifier = ref.read(notificationsControllerProvider.notifier);
    final groups = state.notificationGroups;

    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(
        title: Languages.notifications,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.dp, vertical: 10.dp),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Languages.category,
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.dp),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.dp),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: DropdownButton<int>(
                      value: state.currentCategoryIndex,
                      items: state.categories.map((e) {
                        return DropdownMenuItem(
                          value: state.categories.indexOf(e),
                          child: Text(e),
                        );
                      }).toList(),
                      onChanged: (value) {
                        notifier.setCategory(value ?? 0);
                      },
                      underline: Container(),
                    ),
                  ),
                ],
              ),
              ...groups.asMap().entries.map((entry) {
                final int index = entry.key;
                final (icon, title, items) = entry.value;
                final bool isSelected = state.currentExpandIndex == index;

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 15.dp, horizontal: 5.dp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.dp),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                        offset: const Offset(0.0, 1.0),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.dp),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.dp, horizontal: 5.dp),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.accents.elementAt(
                                Colors.accents.length % (3 * index + 3),
                              ),
                              child: Icon(
                                icon,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(title),
                            trailing: Icon(
                              isSelected
                                  ? Icons.keyboard_arrow_up_outlined
                                  : Icons.keyboard_arrow_down_outlined,
                            ),
                            onTap: () {
                              notifier.setIndexExpand(index);
                            },
                          ),
                          if (isSelected)
                            ...items.asMap().entries.map((subEntry) {
                              final int subIndex = subEntry.key;
                              final subItem = subEntry.value;

                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.dp),
                                child: ListTile(
                                  leading: Container(
                                    width: 60.dp,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.dp),
                                      color: Colors.blueAccent.withValues(
                                        alpha: 1 / (subIndex + 1),
                                      ),
                                    ),
                                    child: Center(
                                      child: NetworkWebImage(
                                        subItem.userIcon ?? "",
                                        size: Size(40.dp, 40.dp),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  title: Text(subItem.moneyActionName ?? ""),
                                  trailing: Text(
                                    "\$${subItem.moneyAmount?.toStringAsFixed(2) ?? ""}",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
