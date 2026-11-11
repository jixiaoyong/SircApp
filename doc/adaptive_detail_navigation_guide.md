# GoRouter 自适应主详情导航：实现与复用指南

调研日期：2026-11-11。以当日工作区实际代码为准，项目 `pubspec.lock` 中的 `go_router` 为 **14.8.1**。本文只记录现状与接入经验，不代表已引入新依赖或完成原生/Web 全平台验证。

## 1. 结论与目标场景

当前实现是 **GoRouter 路由机制 + 自定义自适应布局 + Page/Route 生命周期适配**的组合，不是 GoRouter 自带的“一键主详情组件”。

- 窄屏：点击来源页中的项目，进入可返回的详情页面；详情期间隐藏底部导航。
- 宽屏：左侧保留来源页，右侧显示详情，外层导航 Rail 仍可使用；不是额外弹出一个覆盖全屏的详情。
- 拖动窗口跨过断点：保持当前 URL，移动同一个详情 Navigator 子树，尽量保留输入与页面状态。
- 从首页、钱包、历史、个人资料进入交易详情时，保留各自来源，而不是统一跳去钱包分支。

GoRouter 提供 URL 匹配、嵌套路由、独立分支栈和自定义 Page 的基础能力；布局比例、同级详情替换、返回目标、跨断点状态和交易数据恢复仍需应用决定。项目已有 `flutter_screenutil_plus`，它的局部响应式查询也不是路由状态解决方案。

## 2. 当前代码职责与真实结构

相关文件（相对于仓库根目录）：

- [`lib/routes/app_router.dart`](../lib/routes/app_router.dart)：`createAppRouter`、五个 `StatefulShellBranch`、分支内 `ShellRoute`、来源与详情路由、私有 `_adaptiveDetailPage` 及两种自适应 Page/统一 Route。**目前未拆出** `adaptive_detail_page.dart`**。**
- [`lib/core/layout/adaptive_detail_layout.dart`](../lib/core/layout/adaptive_detail_layout.dart)：`AdaptiveDetailLayout`，只管理来源/详情区域布局、挂载、语义与详情子树的 `GlobalKey`，不解析 URL 和交易参数。
- [`lib/core/layout/app_layout.dart`](../lib/core/layout/app_layout.dart)：窗口断点 `wideWindowWidth = 840`，`isWideWindow` 使用 `MediaQuery.sizeOf(context).width`；局部布局另用 `containerQuery`。
- [`lib/features/home/presentation/main_page.dart`](../lib/features/home/presentation/main_page.dart)：底部导航/Rail/抽屉入口，调用 `navigationShell.goBranch(index)`；直接承载 `StatefulNavigationShell`，不再另造五页 `IndexedStack`。
- [`lib/routes/source_detail_navigation.dart`](../lib/routes/source_detail_navigation.dart)：`openSourceDetail`，从当前路径首段推导来源；根页进入用 `push`，已在详情时用 `replace`。
- [`lib/features/home/presentation/menu_page.dart`](../lib/features/home/presentation/menu_page.dart) 与 [`person_page.dart`](../lib/features/home/presentation/person_page.dart)：各自的详情选择策略，部分宽屏同级切换使用 `Router.neglect`。
- [`lib/features/wallet/presentation/transaction_detail_page.dart`](../lib/features/wallet/presentation/transaction_detail_page.dart)：`TransactionDetailPage.fromExtra` 负责业务参数兼容与缺参空态。

外层 `StatefulShellRoute.indexedStack` 保持五个分支的独立导航状态。每个分支内部再通过 `ShellRoute` 将其内层 Navigator 作为 `detail: child` 交给布局。

**不要将 Shell 的 `child` 理解成固定的“一个详情 Widget”，也不要假设左侧主页一定就是内层 Navigator 的根页面。**它在这里通常是整个内层 Navigator 子树。将它放右侧，等于将该 Navigator 的页面、遮罩与转场区域限制在右窗格。

### 来源窗格的两种策略

**首页** `/main`**、钱包** `/wallet`**、历史** `/history`**、个人资料** `/person`**：**

- `keepPrimaryMounted: true`。
- 真实来源 Widget 在 Shell 的 `primary` 中，位于详情 Navigator 外。
- 来源根路由的页面内容是 `SizedBox.shrink()`，不是第二份真实来源页。
- 窄屏无详情显示来源、有详情 `Offstage` 隐藏来源；来源仍挂载。无详情时详情 Navigator 被 `Offstage` 隐藏而非销毁。

**菜单** `/menu`**：**

- 未设置该参数，使用默认 `false`。
- 窄屏布局直接返回详情 Navigator，根路由是 `MenuPage()`；打开详情后该根页留在导航栈下层。
- 宽屏 Shell 外侧挂载 `MenuPage(listOnly: true)`，根路由改为空内容。
- 因而窄/宽屏的来源菜单是两处不同挂载位置，**不能承诺两者是同一个 Menu Element 或天然共享局部滚动状态**。已有“宽屏保持 Menu 实例”的测试，不能扩展解读为跨断点 Menu 实例永远不变。

### 窗口断点与窗格宽度不要混用

`840` 是窗口逻辑像素断点，不是设备型号，也不是右侧扣除 Rail 后的内容宽度。窗口宽度 `839` 为窄屏、`840` 即为宽屏。

宽屏有详情时，`LayoutBuilder` 按**局部父约束**分配宽度：左右各 `(maxWidth - 1) / 2`，中间为 1 逻辑像素分隔线；无详情时来源占满局部宽度。即使局部容器只有 320，窗口已达到 840，布局仍按宽屏分栏为两侧各 159.5。不要用局部 320 再触发一次“窄屏路由”判断。

## 3. 用户动作与页面生命周期

以钱包交易为例：

1. 打开 `/wallet`：Shell 外的 `WalletPage` 显示，内层 Navigator 的空根页隐藏。
2. 点击交易：`openSourceDetail(context, 'transaction', extra: ...)` 从来源根页 `push` 到 `/wallet/transaction`；项目开启 `GoRouter.optionURLReflectsImperativeAPIs = true`，让命令式路由也反映到 Web URL。
3. 宽屏：来源仍在左侧，详情在右侧无转场显示；窄屏：来源保留挂载但不可见，详情使用 Material 平台转场。
4. 继续选另一笔交易：当前已不是来源根路径，helper 改用 `replace`；不会每次累加一层同级交易详情，`extra` 则更新为新记录。
5. 将窗口依次调整到 839、840、390、1200：不做 `go`/`push`，只重排现有详情子树并更新 Page 配置，URL 不变。
6. 返回：通常弹出内层详情，露出原来源。独立深链进入的详情也有匹配的来源根路由；不要把浏览器历史中的“上一网站”与应用内来源根页混为一谈。
7. 切换到其他分支再回来：`goBranch` 恢复该分支上次导航状态，而不是每次重新创建来源。当前 `MainPage` 未传 `initialLocation: true`，重复点当前分支不主动重置到根页。

菜单宽屏连续切换语言、外观等采用“首次 push、后续同级 replace + neglect”；窄屏入口通常 push。个人资料有独立判断，且把交易详情排除在部分同级设置替换规则之外。**不要声称所有入口都已统一使用** `openSourceDetail`**。**

## 4. 跨断点保留状态：两层机制缺一不可

### 布局层：保留子树身份

`AdaptiveDetailLayout` 的 State 持有一个稳定 `GlobalKey`，放在包裹 `detail` 的 `KeyedSubtree` 上。窄屏直接返回 detail 与宽屏 Row 内 detail 的树位置不同，GlobalKey 用于移动同一个详情子树，而不是重新创建 Navigator 和输入框。

`keepPrimaryMounted: true` 则通过 `Offstage` 保持来源存在。`Offstage` 不等于 dispose，也不代表业务监听自动停止；后续接入订阅、视频等仍需考虑隐藏时的资源行为。

### 路由层：允许 Page 配置更新，而不是替换 Route

简单地在断点两侧切换标准 `MaterialPage` 与 `NoTransitionPage` 不够：默认 `Page.canUpdate` 涉及类型与 key，类型变化可能导致 Route 重建。

当前私有 `_AdaptiveDetailMaterialPage` 和 `_AdaptiveDetailNoTransitionPage`：

- 都接收 `state.pageKey`。
- 双向覆盖 `canUpdate`，允许这两种类型在 key 相同时更新。
- `createRoute` 都调用 `_adaptiveDetailPageRoute`，创建共同的 `_AdaptiveDetailPageRoute`。
- Route 的 builder 每次读取 `route.settings` **中最新 Page 的 child**，不能闭包捕获创建时的 `page.child`，否则 `replace` 或窗口更新可能仍展示旧内容/旧回调。
- Route 根据当前 settings 判断转场：宽屏时长为零并直接显示 child，窄屏使用 Material 路由默认的平台转场。

布局 GlobalKey 解决跨树位置身份，Page/Route 适配解决 Navigator 页面身份；仅做好其中一层不能替代另一层。

状态保留有前提：对应布局 State、Route 与 key 没被销毁或改变。页面被 pop、切换不同业务 Widget/key、登出移除分支、刷新/重启之后不承诺保留。`replace` 复用 Page key 也不意味着 Flutter 会跨不同 Widget 类型保留所有 State。

对 iOS 而言，MaterialPageRoute 使用的是 Flutter 对应平台的转场实现，不等于原生 `UINavigationController`。本次没有验证 iOS 交互式侧滑返回、取消手势或原生恢复；不能从 Widget 返回测试推导这些手势全部通过。

## 5. 最小接入步骤

### 增加一个同来源详情

1. 在 [`app_routes.dart`](../lib/routes/app_routes.dart) 中按现有惯例定义路径；详情使用来源前缀，例如 `/wallet/<segment>`，不要无故挂到根 Navigator。
2. 在 `app_router.dart` 对应来源根路由的 `routes` 中注册子 `GoRoute`。
3. 无特殊参数的详情参考 `_adaptiveDetailRoute(path, buildDetail, source: ...)`；有 path/query/extra 参数的详情参考文章或交易路由，在 `pageBuilder` 内解析并调用当前私有 `_adaptiveDetailPage(context: context, key: state.pageKey, child: detail)`。
4. 该 helper 只在 `app_router.dart` 所属 Dart library 内可用，不是可从任意文件 import 的公开 API。本项目尚未进行独立 Page 文件抽取；复制到其他项目时需明确迁移这一组相关 Page/Route 实现。
5. 同级选择需要避免堆栈时，从适合的来源上下文调用 `openSourceDetail`；它假设 URL 首段就是来源，不适用于任意多级嵌套根路径。参数尽量让业务页面/仓储解释，不让通用布局依赖交易、卡片或 Riverpod Provider。
6. 明确返回目标：普通来源根页、卡片管理页，还是上一个详情；不要仅因为“能 pop”就忽略业务要求。
7. 添加实际点击、深链、缺参、同级替换、跨断点输入保留测试，不只是断言能找到详情 Widget。

### 增加一个来源分支

1. 为简单来源参考 `_sourceBranch(source, list)`；目前其交易/文章/卡片注册带有既有业务条件，不是无限通用的自动生成器。
2. 在 `StatefulShellRoute` 的 branches、`MainPage` 导航项及相关抽屉映射中保持顺序一致，补齐根路径的底栏可见性判断。
3. 明确 `keepPrimaryMounted` 策略。true 时真实来源放 Shell 外、内层根路由为空；false 时必须在窄屏 detail Navigator 的根路由提供来源页面。不要两边都放完整来源然后误以为是同一个实例。
4. 给 `primaryPaneKey` 明确且唯一的测试标识；稳定保存布局与详情 key，不要在 build 中创建新 GlobalKey。
5. 验证分支切换不清空详情栈、左窗格点击不被内层 Navigator 的语义遮罩屏蔽，来源与详情的 Hero 不产生重复 tag 冲突。

## 6. 返回策略与 Web 历史

- `push`：在当前配置上增加详情，适合首次从来源进入且需要返回。
- `replace`：替换栈顶并复用其 Page key，适合同级选择；与 `pushReplacement` 创建新 Page key 不同。保留的是可更新页面身份，不是任意业务数据的永久快照。
- `go`：按目标 URL 重建相应匹配页面配置，不等同于“在当前栈加一页”；适合无法 pop 时跳回确定的来源等场景。
- `Router.neglect`：控制这次路由更新的浏览器历史跟踪，不是布局或 Widget 保活手段，也不意味着 URL 一定不变化。当前设置页用它减少宽屏同级选择污染浏览器历史；交易 helper 未加此包装，不可笼统宣称所有同级详情的 Web 历史完全一致。
- `_adaptiveDetailRoute`：宽屏回调通过挂入详情后的 `detailContext` 找内层 Navigator，能 pop 则 pop，否则 go 到来源；不能拿 Shell 外的 context 随意 pop 外层导航。窄屏传 null，由详情页面沿用自身返回逻辑。
- 卡片编辑有额外业务约定：个人来源、编辑已有卡、或 `from=cards` 时返回管理页，使用 `replace`；`PopScope` 让系统返回也遵守这个约定。不是所有详情都返回来源根页。

官方导航文档对命令式导航的浏览器历史仍有专门提醒。Widget 测试中的 URI 与 `canPop` 断言不能替代浏览器地址栏、后退、前进、刷新测试。

## 7. 参数、深链与业务边界

交易路由为 `<source>/transaction`，目前**没有交易稳定 ID 的路径参数**。`TransactionDetailPage.fromExtra` 兼容裸 `Transaction` 和 `{'data': transaction, 'heroTag': ...}`；非法数据变为 null，非法 Hero tag 回退到 `'default'`。

因此复制交易 URL 或刷新后，只能保证路由可匹配；缺少 `extra` 时显示交易不可用的业务空态，而不是由路由伪造交易。没有稳定 ID、持久仓储/后端与必要的序列化机制，不能宣称完整恢复深链数据。官方提到复杂 extra 的浏览器序列化可能需要 codec，但 codec 本身也不等于业务持久化。

文章使用 `/main/article/:id` 与本地静态示例，卡片编辑使用 `edit-card/:id`；它们也仍受当前演示数据及认证状态限制。当前认证 redirect 会将匿名业务 URL 导向登录，不能在未验证的情况下承诺登录后自动回原深链。

## 8. 官方与现成方案对比

### 方案一：GoRouter 官方 ShellRoute / StatefulShellRoute，加应用布局

[ShellRoute 14.8.1 API](https://pub.dev/documentation/go_router/14.8.1/go_router/ShellRoute-class.html) 与[官方 shell_route.dart 示例](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/shell_route.dart)说明内层 Navigator、外层 UI 和 `parentNavigatorKey` 的关系。

[StatefulShellRoute API](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html) 与[官方 stateful_shell_route.dart 示例](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart)展示多分支独立导航栈、`goBranch` 恢复分支。另有[自定义分支容器示例](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/others/custom_stateful_shell_route.dart)，演示定制 Navigator 容器，不是开箱即用的跨断点主详情。

这些都是可直接借鉴的官方基础。此次核验到的示例没有把本项目的“同来源左右分栏 + 同级替换 + 跨 Page 类型保留详情 + 业务返回”整体封装为一个组件。本项目就是沿用官方基础后补齐这部分策略；维护面较小，但必须理解 Navigator/Page 生命周期。

注意：GitHub main 和 latest 文档会变化；本地仍以锁定的 14.8.1 API 为准，不应照抄官方 main 的新 import 或新参数而假定当前项目可编译。

### 方案二：AdaptiveScaffold 布局，与 GoRouter 自行组合

官方发布的 [`flutter_adaptive_scaffold`](https://pub.dev/packages/flutter_adaptive_scaffold) 提供断点、导航元素及 `body`/`secondaryBody` 双栏，调研页面显示 **0.3.3+1 且已 discontinued**。它是布局层工具，不自动定义来源 URL、同级详情替换、深链数据与返回策略，不建议为了本项目现有小规模布局新引入这个已停止更新的包。

有可阅读的[社区 GoRouter + AdaptiveScaffold 主详情组合示例](https://stackoverflow.com/questions/76584957/using-adaptivescaffold-from-flutter-adaptive-scaffold-with-go-router-to-show-a-l)，将来源、详情组织为 `AdaptiveLayout` 的 body 与 secondaryBody。它证实这一组合模式可用，但不是官方完整产品级实现；示例按不同断点使用不同 slot key、在详情配置中重新构建来源，不能据此直接承诺来源和表单 State 跨断点不重建。

适用场景是需要较完整的 Material 自适应槽位和动画，并愿意自己维护路由/状态桥接。相较本项目，它减少一部分视觉布局代码，却不消除核心导航决策。

### 方案三：第三方 adaptive_scaffold_router 的 GoRouter 导航壳

[`adaptive_scaffold_router`](https://pub.dev/packages/adaptive_scaffold_router) 调研页面显示 **0.3.1**。其 `AdaptiveNavigationShell` 明确接收 GoRouter 的 `StatefulNavigationShell`，支持底栏/Rail/Drawer 自适应；底层保留 `AdaptiveScaffold` 的双栏布局能力。

此次同时查看了[组件源码](https://github.com/igloodev/adaptive_scaffold_router/blob/master/lib/src/adaptive_navigation_shell.dart)与[示例](https://github.com/igloodev/adaptive_scaffold_router/blob/master/example/lib/main.dart)：适配壳把同一个 navigationShell 放入稳定 body，并通过 `goBranch` 切换。**它提供现成的 GoRouter 自适应导航外壳，但不能等同于现成的完整主详情路由状态方案。**其高层壳并未替本项目决定来源详情 URL、交易 extra、卡片返回、两种 Page 的统一 Route；底层 `secondaryBody` 能分栏，也仍需要应用组织详情。

另一个迁移差异：此次看到的源码重复点击当前分支时传 `initialLocation: true`，会回分支初始位置；本项目只调用 `goBranch(index)`。不能仅替换外壳而忽略这一行为变化。

包的维护活跃度、兼容 14.8.1 的完整依赖约束、iOS/Web 细节与边界测试未做全面审计。pub.dev 显示的版本只是本次页面观测，不据此宣称它是“最新/最佳/最成熟”的选择，也不直接采用 README 对其他项目的比较结论。

### 推荐

当前优先保留项目实现与现有测试，不为“已经能实现的主详情”立即添加依赖。复用时先分清：**导航外壳自适应、窗格布局自适应、路由状态自适应是三个不同问题。**

若未来需要多级 Rail/Drawer、折叠屏分隔避让、更多 Material 槽位动画，再对第三方方案做隔离试验；验证它能否保持当前来源、同级替换、表单状态及 Web 历史语义后再考虑迁移，而不是把 split view 截图当作路由问题已解决。

## 9. 踩坑与最小验证清单

- 只在宽屏 Row 里新建详情、窄屏再创建一次详情：容易丢 Navigator 与输入状态。检查 Element 身份和实际输入值，不仅检查类型存在。
- 只共用 Page key，但标准 Page 类型发生变化：仍可能重建 Route。核实 `canUpdate` 与统一 Route。
- 统一 Route 捕获首次 child：详情替换后可能仍展示旧交易或过时回调。连续选择不同记录并断言内容。
- 给业务详情设置根 `parentNavigatorKey`：可能覆盖 Rail/来源并改变 Hero 边界，破坏右窗格局部转场。
- 主页面已有一份，又把同一页面当内层根页：可能得到两份 State、两个滚动位置和重复 Hero。
- 只看 Flutter Widget 存在：Web 语义 DOM 可能仍被嵌套 Navigator 的遮罩挡住；检查左窗格与 Rail 的语义可达性，浏览器中再核验实际点击。
- 将窗口断点改为局部宽度判断：扣除 Rail 后可能与外层导航产生两套不同模式。
- 将宽屏“无转场”误解为没发生路由：URL、栈、Page 仍存在，只是视觉上分栏。

已有测试入口：

- [`test/core/layout/adaptive_detail_layout_test.dart`](../test/core/layout/adaptive_detail_layout_test.dart)：839/840、keepPrimaryMounted 两策略、hasDetail 两状态，以及窗口宽而局部仅 320 的均分尺寸。
- [`test/routes/source_detail_test.dart`](../test/routes/source_detail_test.dart)：四来源真实 Element 保留、连续交易替换、839/840/390/1200 跨断点、来源与 Rail 语义、文章以及卡片管理返回。
- [`test/routes/app_router_test.dart`](../test/routes/app_router_test.dart)：菜单输入跨断点、分支栈、深链、认证、缺参空态、同级设置和业务返回等。
- [`test/routes/tab_hero_test.dart`](../test/routes/tab_hero_test.dart)：分支切换与交易 Hero 身份。
- [`test/core/layout/app_layout_test.dart`](../test/core/layout/app_layout_test.dart) 与 [`test/app_window_layout_test.dart`](../test/app_window_layout_test.dart)：窗口/局部布局约束。

后续修改应用代码时可从最小集合开始（本次仅文档，**未执行以下测试或构建**）：

```sh
fvm flutter test test/core/layout/adaptive_detail_layout_test.dart test/core/layout/app_layout_test.dart
fvm flutter test test/routes/source_detail_test.dart test/routes/app_router_test.dart test/routes/tab_hero_test.dart
```

人工回归至少覆盖：窄屏进入并输入 → 拉宽 → 点同级 → 缩窄 → 页面/系统返回；另测独立 URL 打开、刷新缺参、浏览器后退/前进、分支来回切换、左窗格实际点击。iOS 额外测试侧滑返回及中途取消，不用 Android 系统返回结果替代。

验证边界：上述为已阅读的测试覆盖，不是本次执行报告。另有既知 `wallet12` 钱包尺寸断言失败记录，不能宣称整个套件已全绿；本次文档工作没有重现或定位该失败，也没有顺手修改业务布局。

## 10. 参考资料与文档位置

除前文链接，还核验了：

- [GoRouter 14.8.1 replace API](https://pub.dev/documentation/go_router/14.8.1/go_router/GoRouter/replace.html)：同一 Page key 与 pushReplacement 的区别。
- [GoRouter 导航文档](https://pub.dev/documentation/go_router/latest/topics/Navigation-topic.html)：go/push、浏览器历史、Router.neglect、extra 序列化边界。

本仓库已有 `doc/localization_architecture_guide.md`，README 也链接 `doc/`；此次未发现承载文档的 `Docker/` 目录，因此按已有约定将本文放在 `doc/adaptive_detail_navigation_guide.md`，没有另建 Docker 目录或更改应用代码。
