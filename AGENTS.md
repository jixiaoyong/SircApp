# Agent 项目指引

## Flutter/Dart 命令

- 本项目使用 FVM 管理 Flutter SDK。执行任何 Flutter 或 Dart 命令前必须通过 FVM（例如 `fvm flutter ...`、`fvm dart ...`），不要直接调用全局 `flutter` 或 `dart`。
- 静态分析统一使用 `fvm flutter analyze --no-fatal-infos`：Flutter 3.50 起 `--fatal-infos` 默认开启，会把历史 info 级提示当成失败；info 暂不纳入门禁，仅 error / warning 阻断。

## 国际化与 Mock 数据

- 所有面向用户的 UI 文案必须通过项目现有 `lib/l10n/` Languages 契约及中文、英文实现提供；组件不得硬编码双语条件。新增词条应同步修改 `keys/`、`impl/zh/`、`impl/en/`，然后运行 `dart run tool/build_lang.dart`。
- 双语业务内容（例如文章标题、摘要与正文）由 repository/model mapper 根据显式 `Locale` 统一映射为展示字段。页面只读取本地化字段，不自行判断 `zh/en`，也不直接访问双语 raw JSON。
- `Locale` 应显式传入数据层；需要响应应用语言状态时，可在 provider 层适配并将 locale 传给 repository。避免在数据层读取全局隐藏 locale 状态。
- 日期、金额等本地化格式使用 `intl` / Flutter localization，不在 widget 中拼接语言特定格式。
- 中英文测试均需覆盖：至少验证关键文案、数据映射或可见页面在中文与英文环境下的结果。
