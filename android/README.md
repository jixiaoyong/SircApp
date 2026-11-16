# Android 原生配置与构建指南

本项目为 SircApp 的 Android 宿主工程模块。为了与最新的 Flutter SDK 及现代 AndroidX 依赖库保持最佳兼容性，该目录下的 Gradle、AGP、Kotlin 以及 SDK 版本已全面升级对齐。

---

## 📌 环境与兼容性版本矩阵 (Compatibility Matrix)

| 构件 / 依赖项                   | 推荐版本        | 说明                                                        | 配置文件位置                                  |
| :------------------------------ | :-------------- | :---------------------------------------------------------- | :-------------------------------------------- |
| **Flutter SDK**                 | `3.50.0`        | 项目根目录 `.fvmrc` 锁定                                    | `/.fvmrc`                                     |
| **Dart SDK**                    | `3.14.0`        | 伴随 Flutter 3.50.0 绑定                                    | -                                             |
| **Gradle**                      | `9.5.0`         | 建议使用全量分发 `gradle-9.5.0-all.zip`                     | `gradle/wrapper/gradle-wrapper.properties`    |
| **Android Gradle Plugin (AGP)** | `9.3.1`         | 本分支已完成 Debug APK 构建验证                             | `settings.gradle`                             |
| **Kotlin (KGP)**                | `2.4.20`        | 本分支已完成 Debug APK 构建验证                             | `settings.gradle`                             |
| **Compile SDK**                 | `36`            | Android 16 (支持 `url_launcher` 等最新插件)                 | `app/build.gradle`                            |
| **Target SDK**                  | `36`            | 与 Compile SDK 保持同步                                     | `app/build.gradle`                            |
| **Min SDK**                     | `21`            | Android 5.0+ 兼容基础                                       | `app/build.gradle`                            |
| **Android NDK**                 | `28.2.13676358` | 兼容 JNI 及底层原生构建                                     | `app/build.gradle` (`ndkVersion`)             |
| **JDK 版本**                    | `Java 17`       | 本次构建使用 Java 17；通过 `flutter doctor -v` 核对实际 JDK | `app/build.gradle` (`JavaVersion.VERSION_17`) |

---

## 🛠️ 关键配置文件说明

1. **`gradle/wrapper/gradle-wrapper.properties`**
   - 锁定项目使用的 Gradle 版本。
   - 配置项：`distributionUrl=https\://services.gradle.org/distributions/gradle-9.5.0-all.zip`。
2. **`settings.gradle`**
   - 集中式插件声明管理（Plugins Block）：
     ```groovy
     plugins {
         id "dev.flutter.flutter-plugin-loader" version "1.0.0"
         id "com.android.application" version "9.3.1" apply false
         id "org.jetbrains.kotlin.android" version "2.4.20" apply false
     }
     ```
3. **`app/build.gradle`**
   - 应用包名、签名及 SDK 级别：
     - `compileSdkVersion 36`
     - `targetSdkVersion 36`
     - `ndkVersion = "28.2.13676358"`
     - Java 与 Kotlin JVM Target 统一指定为 `17`。
4. **`local.properties`**
   - 本地开发机器专用路径（Git 忽略）：
     - `sdk.dir` 指向本机 Android SDK 路径。
     - `flutter.sdk` 指向当前通过 FVM 管理的 Flutter 缓存路径（如 `~/.fvm/versions/3.50.0`）。

---

## 构建失败排查记录（2026-11-16）

本次在 `chore/platform-build-migration` 分支验证了 Android Debug APK 和 iOS 模拟器构建。最终均成功，未降级 Flutter、AGP、Gradle 或 Kotlin，也未修改平台工程来绕过错误。以下网络方案仅用于临时诊断，不是项目默认仓库配置。

### 1. 先区分 SDK 问题与平台问题

项目 `.fvmrc` 固定 Flutter `3.50.0`（Dart `3.14.0`）。本机默认 Flutter `3.41.9`，以及已有的 Flutter `3.47.9`（Dart `3.13.7`），均不足以解析当前依赖；其中 `month_picker_dialog >=7.0.0` 要求 Dart `>=3.14.0`。

这种失败发生在 `pub get`，还没有执行 Gradle 或 Xcode，不能据此判断 AGP 或 iOS SPM 有故障。不要通过降低依赖约束、关闭版本检查解决 SDK 不匹配。

从项目根目录执行：

```bash
fvm install 3.50.0
fvm flutter --version
PUB_HOSTED_URL=https://pub.flutter-io.cn fvm flutter pub get
fvm flutter build apk --debug
```

`PUB_HOSTED_URL` 只控制 Dart Pub 包源，不会改变 Gradle 的 Google Maven / Maven Central 仓库。本次沿用锁文件中的 Pub 镜像，避免产生无关锁文件变化。检查 ignored `android/local.properties` 的 `flutter.sdk`，确保指向当前 FVM SDK，不直接复制旧 worktree 的路径。

### 2. Android：插件找不到，不一定是版本不存在

本次 `settings.gradle` 的 AGP `9.3.1` 报错为 `Plugin ... was not found`，实际排查发现：

- Google Maven 的 `dl.google.com` TLS 连接报 `SSL_ERROR_SYSCALL`；访问 `maven.google.com` 仍会重定向到该地址。
- 阿里云 Google Maven 镜像中 AGP 本体及插件标记均返回 HTTP 200，证明不能因官方地址连接失败就断言版本不存在。
- 最初只替换 Google 仓库时，镜像对 Maven Central 的 `okio-jvm` 查询返回 HTTP 502，Gradle 因错误禁用了该仓库，并连带导致多个依赖无法解析。需限制 Google 镜像的依赖分组，避免通用依赖误走该源。
- 之后 Maven Central 的 HTTPS 读取也长时间等待，因此本次调用将 Central 临时替换为对应 HTTPS 镜像，并设置连接/读取超时，最终构建成功。

可以分别检查官方地址及镜像，保留真实 HTTP/TLS 结果：

```bash
curl -I -L --max-time 30 https://dl.google.com/dl/android/maven2/com/android/tools/build/gradle/9.3.1/gradle-9.3.1.pom
curl -I -L --max-time 30 https://maven.aliyun.com/repository/google/com/android/tools/build/gradle/9.3.1/gradle-9.3.1.pom
```

### 3. 临时镜像复现方式（仅确有网络阻碍时）

先完成上面的 FVM 安装和 `pub get`。在系统临时目录手工保存下面内容为 `android-mirror.init.gradle`，不要放到 `~/.gradle/init.d/`，也不要提交到仓库。该脚本使用 Gradle `--init-script`，仅对本次调用及其项目配置生效；不编辑 `settings.gradle`、`build.gradle` 或全局 Gradle 配置。

```groovy
// Temporary invocation-scoped mirrors. Do not commit.
def replaceRepositories = { repositories ->
    repositories.withType(org.gradle.api.artifacts.repositories.MavenArtifactRepository).configureEach { repository ->
        def url = repository.url.toString()
        if (url.startsWith('https://dl.google.com/dl/android/maven2') ||
            url.startsWith('https://maven.google.com')) {
            repository.setUrl('https://maven.aliyun.com/repository/google')
            repository.content {
                includeGroupByRegex('com\\.android(\\..*)?')
                includeGroupByRegex('androidx(\\..*)?')
                includeGroupByRegex('com\\.google\\.android(\\..*)?')
                includeGroupByRegex('com\\.google\\.testing(\\..*)?')
            }
        } else if (url.startsWith('https://repo.maven.apache.org/maven2') ||
                   url.startsWith('https://repo1.maven.org/maven2')) {
            repository.setUrl('https://maven.aliyun.com/repository/central')
        }
    }
}
beforeSettings { settings ->
    replaceRepositories(settings.pluginManagement.repositories)
    replaceRepositories(settings.dependencyResolutionManagement.repositories)
}
allprojects { project ->
    replaceRepositories(project.repositories)
    replaceRepositories(project.buildscript.repositories)
}
```

在项目根目录执行，设置脚本的实际绝对路径。子 shell 的退出 trap 会在成功或失败时删除该临时脚本；下载的依赖仍会留在正常 Gradle 缓存中。项目 Gradle wrapper 配合 Flutter Gradle 插件会编译 Dart、原生插件并打包 APK。

```bash
(
  set -e
  MIRROR_INIT="${TMPDIR:-/tmp/}android-mirror.init.gradle"
  test -f "$MIRROR_INIT"
  trap 'rm -f "$MIRROR_INIT"' EXIT
  cd android
  PUB_HOSTED_URL=https://pub.flutter-io.cn ./gradlew \
    --init-script "$MIRROR_INIT" \
    assembleDebug \
    -Ptarget-platform=android-arm,android-arm64,android-x64 \
    -Ptarget=lib/main.dart \
    -Dorg.gradle.internal.http.connectionTimeout=20000 \
    -Dorg.gradle.internal.http.socketTimeout=30000 \
    --console=plain
)
```

注意：

- 这是本项目当次依赖集合验证过的 Google 分组范围，不是适用于所有工程的完整列表；若出现其他 Google 构件缺失，应核实来源后调整临时脚本。
- 不关闭 TLS 校验，不用 HTTP，不把所有依赖粗暴指向 Google 镜像；镜像同样可能出现 502 或同步延迟。
- 超时参数只限制网络等待，不会修复代码、保证网络恢复或自动补齐缺失构件。
- 网络恢复后优先恢复普通 `fvm flutter build apk --debug`；本方案不会永久改变后续构建的仓库配置。
- 构建完成检查 `git status --short`、`git diff --check` 及锁文件差异，不提交本地路径、镜像脚本、`.kotlin/` 缓存或构建产物。

本次结果：`assembleDebug` 成功，产物为项目根目录下 `build/app/outputs/flutter-apk/app-debug.apk`，`apksigner verify --print-certs` 验证通过，证书为 Android Debug。仅验证 Debug 构建和签名，不代表 Release 签名、商店发布或设备运行已经验收。

### 4. iOS 对照结论

之前 iOS 命令也因旧 Dart 无法解析依赖而停止，并未进入 SPM/Xcode 编译。换用项目固定 SDK 后执行 `PUB_HOSTED_URL=https://pub.flutter-io.cn fvm flutter build ios --simulator` 成功，产物为 `build/ios/iphonesimulator/Runner.app`。本次没有复现 SPM 工程故障，没有通过重新接入 CocoaPods 或修改签名解决；模拟器构建不验证真机签名和归档。

---

## 🚀 常用构建与调试命令

### 1. 使用 Flutter CLI 打包构建

- **构建 Debug APK**：

  ```bash
  flutter build apk --debug
  ```

  产物路径：`build/app/outputs/flutter-apk/app-debug.apk`

- **构建 Release APK**：

  ```bash
  flutter build apk --release
  ```

  产物路径：`build/app/outputs/flutter-apk/app-release.apk`

- **跳过依赖版本警告强制构建**（紧急调试备用）：
  ```bash
  flutter build apk --debug --android-skip-build-dependency-validation
  ```

### 2. 使用 ADB 直接安装到手机

```bash
# 安装/覆盖安装到已连接的 Android 设备
adb install -r -d build/app/outputs/flutter-apk/app-debug.apk

# 快速拉起应用主 Activity
adb shell am start -n io.github.jixiaoyong.sirc/.MainActivity
```

### 3. 使用 Android CLI 工具链调试

项目支持使用官方 `android` CLI 辅助排查与管理：

```bash
# 查看环境、SDK 路径与已连接设备
android info

# 查看已安装与可用的 Android SDK / NDK / Build-Tools 列表
android sdk list

# 查询 Maven 构件或工具链的最新兼容版本
android studio version-lookup agp gradle kotlin ndk sdk
```
