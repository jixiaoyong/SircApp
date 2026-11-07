# Android 原生配置与构建指南

本项目为 SircApp 的 Android 宿主工程模块。为了与最新的 Flutter SDK 及现代 AndroidX 依赖库保持最佳兼容性，该目录下的 Gradle、AGP、Kotlin 以及 SDK 版本已全面升级对齐。

---

## 📌 环境与兼容性版本矩阵 (Compatibility Matrix)

| 构件 / 依赖项 | 推荐版本 | 说明 | 配置文件位置 |
| :--- | :--- | :--- | :--- |
| **Flutter SDK** | `3.47.9` | 项目根目录 `.fvmrc` 锁定 | `/.fvmrc` |
| **Dart SDK** | `3.13.7` | 伴随 Flutter 3.47.9 绑定 | - |
| **Gradle** | `8.14.0` | 建议使用全量分发 `gradle-8.14-all.zip` | `gradle/wrapper/gradle-wrapper.properties` |
| **Android Gradle Plugin (AGP)** | `8.11.1` | 满足 Flutter 3.47+ 与新版 AndroidX 约束 | `settings.gradle` |
| **Kotlin (KGP)** | `2.2.20` | 与 AGP 8.11+ 兼容的现代 Kotlin 编译器插件 | `settings.gradle` |
| **Compile SDK** | `36` | Android 16 (支持 `url_launcher` 等最新插件) | `app/build.gradle` |
| **Target SDK** | `36` | 与 Compile SDK 保持同步 | `app/build.gradle` |
| **Min SDK** | `21` | Android 5.0+ 兼容基础 | `app/build.gradle` |
| **Android NDK** | `28.2.13676358` | 兼容 JNI 及底层原生构建 | `app/build.gradle` (`ndkVersion`) |
| **JDK 版本** | `Java 17` | AGP 8.x 官方标准编译环境 (推荐 Android Studio JBR 17) | `app/build.gradle` (`JavaVersion.VERSION_17`) |

---

## 🛠️ 关键配置文件说明

1. **`gradle/wrapper/gradle-wrapper.properties`**
   - 锁定项目使用的 Gradle 版本。
   - 配置项：`distributionUrl=https\://services.gradle.org/distributions/gradle-8.14-all.zip`。
2. **`settings.gradle`**
   - 集中式插件声明管理（Plugins Block）：
     ```groovy
     plugins {
         id "dev.flutter.flutter-plugin-loader" version "1.0.0"
         id "com.android.application" version "8.11.1" apply false
         id "org.jetbrains.kotlin.android" version "2.2.20" apply false
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
     - `flutter.sdk` 指向当前通过 FVM 管理的 Flutter 缓存路径（如 `~/.fvm/versions/3.47.9`）。

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

