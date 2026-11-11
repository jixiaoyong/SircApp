# SircApp

简体中文（默认） | [English](README.en.md)

![SircApp Web CI/CD](https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg)

## 简介与在线体验

SircApp 是一个使用 Flutter 实现的响应式金融界面与本地交互演示，支持手机与桌面布局、浅色/深色主题，以及中文/英文界面。**本项目不是真实银行，也不提供生产级金融服务。**

[在线体验](https://jixiaoyong.github.io/SircApp/)随已部署的 `master` 分支更新，可能与最新开发版本不同。

## 当前界面：窄屏与宽屏

以下图片截自本地运行的应用（2026-11-11），不是设计稿。已重新拍摄并保存为 WebP。两张斜对角拼图覆盖中英文与亮暗主题四种组合：同页面、同视口截图在同一原点叠放，以从顶部 2/3 宽到下部 1/3 宽的斜线互补分割，不平移、不重排内容。

**首页：左侧亮色中文，右侧暗色英文。**

![首页亮色中文与暗色英文斜对角对照](doc/imgs/home-diagonal.webp)

**钱包：左侧亮色英文，右侧暗色中文。**

![钱包亮色英文与暗色中文斜对角对照](doc/imgs/wallet-diagonal.webp)

**窄屏：首页（英文亮色）与钱包（中文暗色）。**

<p>
  <img src="doc/imgs/home-light-en-narrow.webp" alt="英文亮色窄屏首页" width="390" />
  <img src="doc/imgs/wallet-dark-zh-narrow.webp" alt="中文暗色窄屏钱包" width="390" />
</p>

**宽屏：详情页会分栏展示，而不是打开新页面**

![宽屏主题设置亮色英文与暗色中文反向斜切对照](doc/imgs/settings-appearance-wide.webp)

## 主要功能

- **响应式导航与布局：** 窄屏底部导航、宽屏侧边导航栏，以及自适应的首页和钱包区域。
- **首页概览：多张银行卡、本地化快捷入口、交易摘要、本地示例文章，以及按周/月切换的交易曲线。图表按日汇总收入绝对值与支出绝对值之和**，不是余额或净收入；金额轴从 0 开始并自适应范围，日期标签稀疏显示，区分未来日期和零金额，支持查看数据点。
- **钱包与卡片管理：** 首页和钱包共享选卡状态；支持本地新增、编辑、删除卡片，交易搜索、收支筛选、日期筛选与详情查看。
- **视觉与偏好：** 协调的浅色/深色界面、细微的卡片边缘光效、中英文界面，以及保存的外观和语言偏好。
- **有来源上下文的导航：**可从对应页面打开交易或文章详情。认证与金融快捷入口仅演示本地界面流程，并非完整银行业务。

## 快速开始

使用 [FVM](https://fvm.app/) 和 [`.fvmrc`](.fvmrc) 固定的 Flutter 版本（当前为 **3.47.9**）。Dart 使用该 Flutter SDK 自带的版本，不要沿用旧的 Flutter 3.24 / Dart 3.5 配置说明。

```sh
git clone https://github.com/jixiaoyong/SircApp.git
cd SircApp
fvm install
fvm flutter pub get
fvm flutter run -d chrome
```

构建 Web 发布版本：

```sh
fvm flutter build web --release
```

仓库包含 Android、iOS、Web 和 macOS 平台工程，但这不代表每次改动都已在所有原生平台上验证。原生构建需要对应平台工具链；iOS 需使用 macOS、Xcode，以及插件所需的 CocoaPods 配置。

## 演示数据与边界

- 卡片和交易使用**内存中的 Mock 数据**。生成的交易金额可能随应用会话变化；刷新或重启后，不保证卡片编辑或交易数据仍然保留。
- 展示的余额只是示例，并非真实账户余额。首页图表来自已加载的交易，而非银行后端，并排除无法解析日期的记录。
- 主题、语言等偏好单独持久化。演示认证使用普通本地偏好存储，**不是安全的凭据存储**；请勿输入真实密码、银行卡号、CVV 或其他敏感信息。
- 部分头像、图标和链接内容依赖网络资源。金融快捷入口不代表已实现真实转账、支付、投资或其他银行服务。

## 开发与测试

```sh
fvm flutter test
fvm flutter analyze
```

测试覆盖状态与控制器、本地化、导航、响应式布局、卡片管理、主题，以及图表聚合与交互。静态分析当前存在既有的 warning/info 诊断，不应视为零警告项目。

修改本地化接口或译文后，重新生成本地化访问代码：

```sh
fvm dart run tool/build_lang.dart
```

修改需要 Riverpod 代码生成的声明后，按需重新生成代码：

```sh
fvm dart run build_runner build --delete-conflicting-outputs
```

[Web CI](.github/workflows/main.yml) 在向 `master` 推送或提交以 `master` 为目标的 PR 时运行测试和 Web 发布构建，也支持手动运行。GitHub Pages 仅在 `master` 的推送构建成功后部署；本地提交或推送到 `dev` 不会触发部署。

## 架构与指南

- [`lib/features/`](lib/features/)：按功能组织认证、首页、钱包与设置代码；使用 Riverpod 管理状态，并按需划分仓库层与模型层。
- [`lib/core/`](lib/core/)：共享的本地化、存储、网络与主题基础设施。
- [`lib/routes/`](lib/routes/)：GoRouter 配置及保留来源上下文的详情导航。
- [`lib/widgets/`](lib/widgets/)：可复用的视觉与响应式组件。
- [`test/`](test/)：单元测试与 Widget 测试。
- [本地化开发指南](lib/l10n/README.md)与[本地化架构说明](doc/localization_architecture_guide.md)。

## 更多界面与设计致谢

应用还包含交易详情、卡片编辑与管理、外观和语言设置、个人资料/菜单页面，以及本地认证示例，可在运行的应用中体验；并非每个快捷入口都代表完整产品功能。

项目早期界面参考了[花瓣上的金融应用设计](https://huaban.com/pins/4619822724)，感谢原作者提供的设计灵感。后续界面基于 [UI 2.0 设计稿](design/ui-v2.0.html)迭代，完善了视觉风格与响应式布局。
