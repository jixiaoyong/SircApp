# OpenHarmony 开发

## 已确认的基线与验收范围

本记录以 2026-11-17 当前仓库配置为准：FVM `ohos/oh-3.47.9-dev`、DevEco Studio 配套工具链、HarmonyOS SDK API 26。用户于 19:36 确认真实 Cursor / VS Code IDE 启动正常；此前真实 DAP 验收覆盖 build、install、appStarted、首页渲染、钱包导航和 hotReload，真实 Cursor 调试会话的 `user-dart hot_reload` 也已成功。用户随后明确确认 **hotRestart 实测通过**，该结论来自用户当前 IDE 会话的手动验收，而非 Shell success 通知推断。用户同时说明此前几次关闭是主动停止/重新打开应用，不能据此认定 crash；网络图片加载仍待专项验收。

**后续独立问题（19:41:57 后）**：被忽略的本机 `build-profile.json5` 配置发生外部来源修改，后续 HAP direct install 的输出正文报 `9568337 install parse unexpected`；虽然 hdc 退出码为 0，仍应判定该次安装失败。HAP ZIP 完整，已知 module.json 的 minAPIVersion / targetAPIVersion 为 `260000026`，但根因未定；不能仅据此回滚 API、归咎用户或否定此前 IDE 成功的事实。本次只记录这项未解决问题，不修改签名配置、不重新运行/安装或启动 DAP，避免干扰用户当前会话。

成功标准应按顺序核对：设备发现 → 依赖获取 → 签名构建 → 安装 → 非白屏首帧 → 基本交互 → 热重载 / 热重启；不能只凭 `Built signed hap` 宣称整个运行链路正常。

## 1. 本机工具链与 FVM

- 安装 DevEco Studio，并通过 **SDK Manager** 安装 HarmonyOS SDK API 26 及所需组件。当前 `Contents/sdk/default/sdk-pkg.json` 的 `apiVersion` 为 `26`、`platformVersion` 为 `26.0.0`。
- 从仓库根目录执行 `fvm use`，确保 `.fvm/flutter_sdk` 链接存在。项目 `.vscode/settings.json` 的 `dart.flutterSdkPath` 使用相对路径 `.fvm/flutter_sdk`，不写个人 SDK 绝对路径、不使用全局 Flutter 替代。
- `DEVECO_SDK_HOME` 与 Flutter 的 `ohos-sdk` 均指向包含 `default/` 的 SDK 根 **`/Applications/DevEco-Studio.app/Contents/sdk`**，不能指向 `Contents/sdk/default`。后者会使 SDK 枚举层级不匹配。
- 默认约定 macOS DevEco 安装在 `/Applications/DevEco-Studio.app`；其他位置需要同步调整下文的终端及 IDE 设置。

以下命令在仓库根目录的同一个终端执行；保留原 PATH，避免丢失 FVM 或其他本机工具：

```sh
export DEVECO_SDK_HOME="/Applications/DevEco-Studio.app/Contents/sdk"
export NODE_HOME="/Applications/DevEco-Studio.app/Contents/tools/node"
export PATH="$DEVECO_SDK_HOME/default/openharmony/toolchains:/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin:/Applications/DevEco-Studio.app/Contents/tools/ohpm/bin:$NODE_HOME/bin:$PATH"
command -v fvm node npm hvigorw ohpm hdc
fvm flutter config --ohos-sdk "$DEVECO_SDK_HOME"
fvm flutter --version
fvm flutter doctor -v
hdc list targets
fvm flutter devices
```

`fvm flutter config` 会修改当前 FVM SDK 使用的 Flutter 配置，不是仓库文件；已有其他项目时留意共享影响。不要混入旧 HarmonyOS CLI 的 Hvigor、SDK 或相互冲突的 `HOS_SDK_HOME`。Doctor 曾识别 PATH 中另一套 API 18，而 Hvigor 使用 DevEco 的 SDK；Doctor 输出与实际构建工具来源都要核对，不应仅凭一处版本信息猜配置字符串。

## 2. 签名与本机文件

首次克隆且真实文件尚不存在时，复制安全模板（已有签名文件不要覆盖）：

```sh
cp ohos/build-profile.json5.example ohos/build-profile.json5
```

用 DevEco Studio 打开 `ohos/`，在 **Signing Config** 中按 IDE 提示启用自动签名、生成/选择本机 debug 签名，必要时完成账号登录与设备授权。模板的 `signingConfigs` 为空，仅复制文件还不能得到可安装的签名 HAP。模板保留 API 26 的产品、模块与构建模式，最终以 DevEco 配套工具实际支持的格式为准，不要套用旧 Hvigor 要求的版本字符串。

- `ohos/build-profile.json5`、`local.properties`、证书、私钥、签名口令仅保留本机，不写入文档、日志或 Notion。
- `ohos/.gitignore` 忽略真实 `build-profile.json5`、`local.properties`、`.deveco-tmp/`、`.hvigor/`、构建与依赖缓存；根 `.gitignore` 还忽略 `.p12` 等凭据。安全模板 `build-profile.json5.example` 应跟踪。
- `.gitignore` 对已经跟踪的文件不生效；提交前同时检查索引，不能只看忽略规则。不要为了清理而 reset 用户其他暂存改动。

```sh
git check-ignore -v ohos/build-profile.json5 ohos/local.properties ohos/.deveco-tmp/probe
git ls-files ohos/build-profile.json5 ohos/local.properties
```

第二条命令正常应无输出。签名材料优先保存在仓库外；不能假设任意扩展名的证书或私钥都已被忽略。

## 3. Cursor / VS Code：F5 调试

最终环境入口是 `.vscode/settings.json` 的 **`dart.env`**，不是仅 `launch.json.env`，也不是只改 `terminal.integrated.env.osx`。当前 `launch.json` 只选择 `lib/main.dart` 与 Debug / Release / Profile 模式，没有重复配置 OHOS 环境。

当前 `dart.env` 包含：

- `DEVECO_SDK_HOME`：`/Applications/DevEco-Studio.app/Contents/sdk`。
- `NODE_HOME`：`/Applications/DevEco-Studio.app/Contents/tools/node`。
- `PATH` 依次包含 SDK `default/openharmony/toolchains`（提供 hdc）、DevEco `tools/hvigor/bin`、`tools/ohpm/bin`、`tools/node/bin`、`/opt/homebrew/bin`、`/usr/local/bin` 与标准系统目录。

已只读核实本机 Dart-Code **3.146.0**：扩展 `package.json` 声明 `dart.env` 用于所有 Dart/Flutter 子进程；`out/dist/extension.js` 的 `setupToolEnv` 将其直接合并，`safeSpawn` 再覆盖继承环境，pub、daemon、调试适配器均使用工具环境。因此可以覆盖 Flutter 设备发现、依赖获取和调试启动，而非仅最后一步 run。不要臆造 `dart.flutterEnv` 等当前 manifest 未声明的字段。

**该版本 `dart.env` 不展开 `${env:PATH}`**：PATH 是字面量覆盖，不是自动拼接。当前配置使用显式 DevEco、Homebrew 和系统目录；若 FVM 或其他必要工具位于自定义目录，追加真实目录，不能填写占位符指望展开。IDE 选用 Flutter SDK 靠 `.fvm/flutter_sdk`，不是靠 PATH 中的全局 Flutter。终端的 `terminal.integrated.env.osx.PATH` 支持 `${env:PATH}`，当前已保留原 PATH；修改它仅影响之后新建的终端，不能修复已经运行的 Flutter daemon。

1. 完成 SDK 与本机签名，启动 DevEco 模拟器或连接已授权设备。
2. 首次打开或修改环境后执行 **Developer: Reload Window**，让旧 Flutter daemon 退出并用新环境重建；终端配置变更后另开终端。只改配置不会更新旧子进程环境。
3. 状态栏选择实际 OHOS 设备（设备 ID 以 `fvm flutter devices` 为准），选 **SircApp (Debug)**，按 **F5**。不要误选 iOS / Chrome。
4. 用 Debug 工具栏热重载验证；当前 `dart.hotReloadOnSave` 为 `manual`，保存不会自动触发。需要重新执行 `main()` 时使用 **Flutter: Hot Restart**。
5. 同一模拟器避免多条并行 run / DAP 会话互相重装应用。只停止确认属于自己的旧调试会话，不能随意杀其他开发进程。

## 4. 命令行复现与验证

沿用第 1 节同一终端的环境，在仓库根目录执行：

```sh
fvm flutter pub get
fvm flutter devices
fvm flutter build hap --debug
fvm flutter run -d <设备ID>
```

替换设备 ID，不要照抄历史模拟器端口。单独 build 用于区分构建失败与运行失败；日常 `run` 本身也会构建、安装和调试。按实际风险补充 `fvm flutter analyze --no-fatal-infos` 和相关测试；静态分析通过不等于 OHOS 原生插件可用。

首次增加/修改原生插件依赖后，执行 pub get 并停止旧应用，重新完整构建、安装；仅热重载不能注册新增原生插件。不要修改共享 FVM SDK 或 pub cache 源码来掩盖项目依赖问题。

## 5. 构建失败与启动白屏要分层处理

本次经历的是多个独立问题，不是一个错误贯穿到底：

- **`npm` 找不到 / `installHvigorPlugin` 失败**：Flutter 子进程缺少 DevEco Node/npm 的 PATH。交互式 shell 能运行 npm，不代表从桌面启动的 IDE daemon 能运行。修复项目 `dart.env`，Reload Window 后重试。
- **`00306042` 版本格式校验**：历史上混用了旧 CLI Hvigor 与新版 DevEco SDK。先查 `command -v hvigorw` 和实际构建来源，统一配套工具；不能据此盲改为旧版要求的 `平台版本(API号)` 字符串，也不能把这个错误码一概解释成同一原因。
- **`00303312` SDK 不匹配 / 找不到 SDK**：本次曾因把 `DEVECO_SDK_HOME` 指向 `Contents/sdk/default` 导致。恢复到 `Contents/sdk`，核对 API 26 元数据、Flutter 配置与 Hvigor 来源；`local.properties` 中单个路径正确不代表两条链路均正确。
- **签名失败 / 无法安装**：模板不含真实签名。检查 DevEco 自动签名、证书有效性、设备授权和本机真实配置；不要把含密码的文件提交作“修复”。
- **HAP 已构建、但白屏且有 `MissingPluginException`**：属于原生插件注册/实现问题，不能继续当成 SDK 或签名失败。`main()` 在 `runApp()` 前等待 `SharedPreferences.getInstance()`；若 OHOS 实现缺失，此处异常会阻止首帧，且当前 `FlutterError.onError` 尚未安装，需直接查看调试异常堆栈。

当前 `pubspec.yaml` 保留上游插件，同时显式声明 OHOS federated 实现：`shared_preferences_ohos`、`path_provider_ohos`、`url_launcher_ohos`、`webview_flutter_ohos`。这是跨平台 API 包与平台实现包共存，不是要删掉 Android/iOS 包；部分上游尚未将 OHOS 声明为默认实现，需显式依赖生成平台注册。实际版本以 `pubspec.yaml` / `pubspec.lock` 为准，不能把“其他平台实现同时存在”当作冲突。

## 6. 本次启动日志如何判断

- `Built signed hap` 仅说明签名产物生成；安装、VM Service 连接、页面出现与可交互需要分别确认。不同日志流可能交错显示，不要只据行顺序推断生命周期异常。
- `initialControllerProvider -> InitialState` 每隔约 1 秒出现，符合现有非首次启动页的 **3 秒自动跳转倒计时**：`InitialPage.initState` 在非首次状态调用 `startAutoNavigateCountdown`；控制器设置 3 秒并通过 `Timer.periodic(Duration(seconds: 1))` 更新至 0 后取消计时。跳转前防重入和“已非首次”标志也会再更新状态。
- `AppLogProviderObserver.didUpdateProvider` 仅记录 `newValue.runtimeType`，所以变化中的秒数没有打印出来，看起来始终是 `InitialState`；这不是每秒重新初始化应用。若离开启动页后仍无限持续，则不符合这段三秒计时的预期，应进一步检查是否反复创建页面或重复启动倒计时。
- wallet / home provider 更新属于正常状态流；articles 的 `AsyncData` 表示数据已加载，不是错误，也不能证明网络图片一定成功。
- `AppInit` 只在 `main()` 中、读取 SharedPreferences 后且 `runApp()` 前记录。约一分钟后再次出现意味着入口重新执行，可能来自 **热重启、停止后重新运行或设备重启应用**；普通热重载和普通 Widget rebuild 不会重新执行 `main()`。仅此一行不能证明 crash，也不能单凭它断言是热重启。结合当时操作、`Restarted application`、调试会话及系统崩溃日志判断。

## 7. 经验与未验证项

先固定最终工具来源，再修改版本/路径；先让实际应用运行、出首帧并交互，再沉淀文档。每次失败读取当前日志，不把历史 SDK 格式错误、npm PATH 问题和插件白屏混为一个结论。临时 shell 成功不等于 IDE 修复，HAP 成功也不等于 UI 验收。

本次文档整理依据配置、实现、既有验收记录及用户最新确认，不重新运行、安装、启动 DAP、修改本机签名配置或打断用户当前 IDE 会话。hotRestart 已由用户实测确认通过；后续独立 direct install 的 `9568337` 安装解析错误尚未定位，不能据此否定已确认的 IDE 启动与热重启。未做完整功能回归、网络图片专项验证或无操作长期稳定性测试，不能宣称“一切问题已解决”。
