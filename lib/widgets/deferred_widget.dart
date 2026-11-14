import 'package:material_ui/material_ui.dart';

typedef LibraryLoader = Future<void> Function();
typedef DeferredWidgetBuilder = Widget Function();

/// 延迟加载分包组件包装器（用于 Web 端的 Code Splitting / Deferred Loading）
///
/// 当首屏路由或特定页面被触发时，才按需下载对应的 JS/Wasm 分包，极大降低首屏加载体积。
class DeferredWidget extends StatefulWidget {
  const DeferredWidget({
    super.key,
    required this.load,
    required this.builder,
    this.placeholder,
  });

  /// 对应的 deferred import 库的 `loadLibrary` 函数
  final LibraryLoader load;

  /// 分包加载完成后的视图构建回调
  final DeferredWidgetBuilder builder;

  /// 加载分包期间的占位视图（默认居中进度环）
  final Widget? placeholder;

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  Future<void>? _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = widget.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return widget.builder();
        }
        return widget.placeholder ??
            const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
      },
    );
  }
}
