# Agent 项目指引

## Flutter/Dart 命令

- 本项目使用 FVM 管理 Flutter SDK。执行任何 Flutter 或 Dart 命令前必须通过 FVM（例如 `fvm flutter ...`、`fvm dart ...`），不要直接调用全局 `flutter` 或 `dart`。
- 静态分析统一使用 `fvm flutter analyze --no-fatal-infos`：Flutter 3.50 起 `--fatal-infos` 默认开启，会把历史 info 级提示当成失败；info 暂不纳入门禁，仅 error / warning 阻断。

## 公共 API 文档注释

- 新增或实质修改的公共 API（公共类/枚举/扩展、构造函数、方法、顶层函数及 typedef）应使用中文 Dart 文档注释（`///`）说明用途；公共参数在注释中用 `[参数名]` 引用并说明其含义、约束或默认行为。优先覆盖公共工具类及纯格式化/转换函数。
- 注释应准确、简洁并与实现同步；无业务含义的生成代码、简单数据字段或无需额外解释的参数，不要求重复注释。不要为追求覆盖率批量补写低价值注释，避免仅按代码风格改写现有英文注释造成无关 diff。

## 国际化与 Mock 数据

- 所有面向用户的 UI 文案必须通过项目现有 `lib/l10n/` Languages 契约及中文、英文实现提供；组件不得硬编码双语条件。新增词条应同步修改 `keys/`、`impl/zh/`、`impl/en/`，然后运行 `dart run tool/build_lang.dart`。
- 双语业务内容（例如文章标题、摘要与正文）由 repository/model mapper 根据显式 `Locale` 统一映射为展示字段。页面只读取本地化字段，不自行判断 `zh/en`，也不直接访问双语 raw JSON。
- `Locale` 应显式传入数据层；需要响应应用语言状态时，可在 provider 层适配并将 locale 传给 repository。避免在数据层读取全局隐藏 locale 状态。
- 日期、金额等本地化格式使用 `intl` / Flutter localization，不在 widget 中拼接语言特定格式。
- 可复用的纯格式化/转换逻辑不得内嵌在 Widget 的 `build` 方法或类中，应抽至独立 utility/helper 并编写单元测试；所有面向用户的文本及单位必须经 `Languages` keys、中文与英文实现提供，不得硬编码。
- 中英文测试均需覆盖：至少验证关键文案、数据映射或可见页面在中文与英文环境下的结果。
