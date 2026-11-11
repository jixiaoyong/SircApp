# 独立截图工具

工具使用 Python 3.12、Flutter 3.47.9 与固定版本 Playwright/Pillow，不连接个人 Chrome 或 MCP，不修改工作区应用源码。

## 本地运行

以下命令均从**仓库根目录**运行，`flutter` 命令须指向 Flutter 3.47.9：

```sh
python3.12 -m venv .screenshots/venv
.screenshots/venv/bin/pip install -r tool/screenshots/requirements.txt
.screenshots/venv/bin/python -m playwright install chromium
.screenshots/venv/bin/python tool/screenshots/run.py --output .screenshots/run-001
.screenshots/venv/bin/python -m unittest discover -s tool/screenshots -p 'test_*.py'
```

输出目录必须不存在。成功后 `final/` 一次性出现固定五张 WebP；`raw/` 保存 DPR 2 PNG，另有元信息、构建/浏览器/服务日志、Playwright trace 与失败诊断。默认**不覆盖** [`doc/imgs`](../../doc/imgs) 的人工截图。临时静态服务使用独立随机端口，退出即停止，不影响正在开发的服务。

## 临时注入与依赖

为保证真实 Dart 数据和图表日期可复现，[脚本](run.py)将已跟踪应用文件（含这些文件的本地修改，不包含未跟踪应用文件）复制到系统临时目录，对**副本**检查并应用 [`fixture.patch`](fixture.patch)，注入内存偏好、专用演示账号、固定日期/交易、离线图片回退、中文字体与语义 ready 信号；通过实际 UI 登录及切换语言、主题、路由。原工作区 `lib/`、`web/`、`assets/`、`pubspec.*` 和生产构建不变；副本退出自动删除。ready 信号依赖副本内的 Dart Provider 状态，不是完全脱离源码的外部探测。

Python 依赖锁定在 [`requirements.txt`](requirements.txt)，Flutter 依赖通过已有 `pubspec.lock` 和 `--enforce-lockfile` 校验。固定字体来自 Noto CJK Sans 2.004，下载内容校验 SHA256 并记录到元信息；首次运行需要网络准备 SDK/浏览器/字体。不同操作系统的字体栅格化与 WebP 编码环境仍可能存在像素差异，不承诺跨平台逐字节相同。

## 页面变更后的维护

脚本通过 Playwright 的角色、文本和 Flutter 语义节点操作**真实 UI，不使用固定点击坐标**，但仍依赖当前交互契约：

- 通常只改颜色、间距、圆角等，不改变可访问角色、定位文本和导航行为时，无需修改操作脚本；仍需重新检查截图，布局也可能改变可见性、遮挡或溢出。若修改正好涉及补丁上下文，仍可能需要更新补丁。
- 登录按钮 `Login`、导航 `Home`/`Wallet`/`Menu` 及中文译文、外观/语言/主题选项、返回按钮名称等是文本定位依据。修改这些名称、引入重复匹配、改变语义合并方式，可能需要同步更新定位器。
- 登录输入框使用 `textbox` 的第一个/第二个定位，调整字段数量或顺序需要检查脚本。路由路径、菜单详情返回流程和宽窄屏断点（脚本使用 840）改变，也可能需要维护导航步骤。
- 补丁依赖 `main.dart`、主题、钱包控制器和网络图片组件的路径与局部源码上下文；代码移位不一定影响应用补丁，但上下文或结构变化可能使 `git apply --check` 失败。Provider/API、钱包 `isLoading`/`referenceDate` 等接口改变，还可能导致副本编译失败或 ready 校验不通过。维护时同步检查 [`screenshot_mode.dart.txt`](screenshot_mode.dart.txt) 与 [`screenshot_wallet_repository.dart.txt`](screenshot_wallet_repository.dart.txt)，不能只更新页面文字。

因此不是“任意 UI 修改都要更新脚本”，也不是“任意 UI 修改都无需维护”。补丁不适用时工具会失败，而非猜测修改；更新后应重新执行完整流水线及合成测试。

## GitHub Actions 与权限边界

[独立手动截图工作流](../../.github/workflows/screenshots.yml)默认 `preview`，只读权限上传五图、原图与诊断，不部署。`pr` 模式要求从仓库默认分支的受信任工作流启动，只接受来源与目标启动 SHA 相同的构建，目标前进即停止，不强推、不直接写主分支，仅在独立有写权限的任务中白名单写回五图；无变化不提交。构建任务只有只读权限，不持久化 Git 凭据；有写权限的任务不执行来源代码或产物脚本。`preview` 仍会编译并运行所选来源代码，只应选择可信的仓库提交。

`workflow_dispatch` 只有在此工作流进入默认分支（当前为 `master`）后才会在 Actions 中出现并允许手动触发；仅推送到 `dev` 不代表已启用。`pr` 模式还必须选择默认分支作为工作流运行分支，并要求仓库 Settings → Actions → General 允许 GitHub Actions 创建 Pull Request，否则只能使用预览。产物上传显式允许隐藏目录，但仅白名单包含 `final/`、`raw/` 与诊断文件，不上传 `web/`、虚拟环境或其他缓存。本地通过不代表 GitHub 托管环境已经运行成功。

工作流未改变[既有 Web CI](../../.github/workflows/main.yml)：图片 PR 若以 `master` 为目标并合并，仍会按现有规则执行应用检查与部署。GitHub 默认 `GITHUB_TOKEN` 创建的 PR 不会递归触发其他工作流；若分支保护要求现有 PR 检查，需要维护者人工关闭/重新打开 PR 以触发检查，不能绕过必需检查合并。请先审阅预览，再决定是否更新正式图片。
