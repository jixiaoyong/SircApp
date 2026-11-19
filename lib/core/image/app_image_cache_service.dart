import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 商业级移动端多级图片缓存管理服务
///
/// 架构分层：
/// - **L1 内存缓存 (Memory LRU)**：基于 Flutter 引擎 `PaintingBinding.instance.imageCache`
///   管理解压后的 Raw RGBA 位图，负责即时零延迟重绘；
/// - **L2 磁盘持久化缓存 (Persistent Disk)**：基于沙盒临时目录由 `extended_image` 统一管理，
///   下载后持久化落盘，断网与冷启动直接复用；Web 端由浏览器 HTTP 强缓存自动代理；
/// - **下采样保护 (Downsampling)**：按物理像素规格动态解码 (`cacheWidth` / `cacheHeight`)，
///   防止高分辨率大图瞬间撑爆移动端 GPU 显存。
class AppImageCacheService extends ChangeNotifier {
  AppImageCacheService._();
  static final AppImageCacheService instance = AppImageCacheService._();

  /// 默认配置：最大内存缓存数量与内存字节数（默认 1000 张 / 100MB）
  static const int defaultMaxMemoryCount = 1000;
  static const int defaultMaxMemoryBytes = 100 * 1024 * 1024;

  /// L1 内存缓存中当前持有的位图张数
  int get memoryCount => PaintingBinding.instance.imageCache.currentSize;

  /// L1 内存缓存当前占用的物理字节数
  int get memoryBytes => PaintingBinding.instance.imageCache.currentSizeBytes;

  /// L1 内存缓存允许的最大张数配额
  int get memoryMaxCount => PaintingBinding.instance.imageCache.maximumSize;

  /// L1 内存缓存允许的最大内存配额 (字节)
  int get memoryMaxBytes => PaintingBinding.instance.imageCache.maximumSizeBytes;

  /// 动态调整 L1 内存缓存配额
  void configureMemoryLimits({int? maxCount, int? maxBytes}) {
    if (maxCount != null && maxCount > 0) {
      PaintingBinding.instance.imageCache.maximumSize = maxCount;
    }
    if (maxBytes != null && maxBytes > 0) {
      PaintingBinding.instance.imageCache.maximumSizeBytes = maxBytes;
    }
    notifyListeners();
  }

  /// 一键清空 L1 内存图片缓存
  void clearMemory() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    clearMemoryImageCache();
    notifyListeners();
  }

  /// 异步获取 L2 磁盘持久化缓存大小（字节）
  ///
  /// Web 端因沙盒同源策略无本地文件系统直接访问权限，返回 0 (由浏览器 HTTP Cache 代理)
  Future<int> getDiskCachedBytes() async {
    if (kIsWeb) return 0;
    try {
      return await getCachedSizeBytes();
    } catch (_) {
      return 0;
    }
  }

  /// 一键清理 L2 磁盘持久化缓存
  ///
  /// [duration] 可选过期时间阈值，如清理 15 天前的文件；为空则全量清理。
  Future<bool> clearDiskCache({Duration? duration}) async {
    if (kIsWeb) return true;
    try {
      final success = await clearDiskCachedImages(duration: duration);
      notifyListeners();
      return success;
    } catch (_) {
      return false;
    }
  }

  /// 同时清理 L1 内存缓存与 L2 磁盘缓存
  Future<void> clearAll() async {
    clearMemory();
    await clearDiskCache();
    notifyListeners();
  }

  /// 智能下采样尺寸计算器
  ///
  /// 根据逻辑像素尺寸 [logicalSize] 与屏幕物理像素比 [devicePixelRatio]，
  /// 计算出解码时应当使用的目标物理像素值，避免直接解码 4K 原图导致 OOM。
  static int? computeCacheDimension({
    double? logicalSize,
    double devicePixelRatio = 2.0,
    int minDimension = 32,
    int maxDimension = 2048,
  }) {
    if (logicalSize == null || logicalSize <= 0 || logicalSize.isInfinite) {
      return null;
    }
    final target = (logicalSize * devicePixelRatio).round();
    return target.clamp(minDimension, maxDimension);
  }

  /// 友好的字节大小格式化输出工具 (如 256 B, 1.2 MB)
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;

    if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(2)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(2)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(1)} KB';
    } else {
      return '$bytes B';
    }
  }
}
