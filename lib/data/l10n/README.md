# 强类型分层多语言架构规范 (Type-Safe Layered Localization)

> 📍 本目录为 SircApp 多语言/国际化资产与契约定义核心目录。
> 📖 完整详细的设计规范与架构演进说明请参考系统文档：[`doc/localization_architecture_guide.md`](file:///Users/jixiaoyong/dev/workspace/20-29-Personal/21-Tools/21.10-SircApp/doc/localization_architecture_guide.md)

---

## 核心设计要点速览

1. **契约接口防漏**：
   - 采用 Dart 原生 `abstract class LangKeys` 作为唯一契约规范；
   - 任何语言实现（`LanguagesZhCN`、`LanguagesEnUS`）只要漏写任何一个词条，**Dart 编译器会立刻报错标红**，100% 杜绝漏翻译。
2. **业务分层命名空间（Namespaces）**：
   - 业务文案按业务域切分（`Languages.auth`、`Languages.wallet`、`Languages.home`、`Languages.settings`、`Languages.common`）；
   - 彻底解决词条同名冲突和全局数百个词条造成的 IDE 补全卡顿；
   - 支持高频词与历史旧调用的扁平兼容层（如 `Languages.cancel` 直接代理到 `common.cancel`），保证历史业务代码 0 改动。
3. **智蛙式双语悬浮预览**：
   - 门面方法带有标准 DartDoc 注释：
     ```dart
     ///- [zh_CN] 原密码不正确或修改失败
     ///- [en_US] Original password incorrect or update failed
     static String get oldPasswordIncorrect => _current.auth.oldPasswordIncorrect;
     ```
   - 业务开发时鼠标悬浮在属性上即可查看双语实际内容，无需在文件之间切换。
4. **强类型参数与单复数**：
   - 带有参数的动态文本（如 `cardCount(int count)`）直接声明为强类型函数，不再依赖易错的 `%s` 或字符串拼接。

---

## 新增词条极简 SOP

1. **在对应契约中声明**（如 `keys/auth_keys.dart`）：
   ```dart
   String get myNewText;
   ```
2. **在双语实现类中分别补全**（`zh` / `en`）：
   - `zh`: `@override String get myNewText => '中文内容';`
   - `en`: `@override String get myNewText => 'English Content';`
3. **在门面类中暴露并添加双语注释**：
   ```dart
   ///- [zh_CN] 中文内容
   ///- [en_US] English Content
   static String get myNewText => _current.auth.myNewText;
   ```
   *保存后全工程即可直接调用：`Languages.auth.myNewText`。*

