import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/image/app_image_cache_service.dart';
import 'package:sirc/utils/toast.dart';

enum AppLogLevel { debug, info, warning, error }

class AppLogEntry {
  final DateTime timestamp;
  final AppLogLevel level;
  final String tag;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const AppLogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
  });

  String format() {
    final timeStr =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}.${timestamp.millisecond.toString().padLeft(3, '0')}';
    final levelStr = level.name.toUpperCase().padRight(5);
    final errorStr = error != null ? '\n  Error: $error' : '';
    final stackStr = stackTrace != null ? '\n  Stack: $stackTrace' : '';
    return '[$timeStr] [$levelStr] [$tag] $message$errorStr$stackStr';
  }
}

class AppLogService extends ChangeNotifier {
  AppLogService._();
  static final AppLogService instance = AppLogService._();

  static const int _maxLogs = 500;
  final List<AppLogEntry> _logs = [];

  List<AppLogEntry> get logs => List.unmodifiable(_logs);

  void log({
    required AppLogLevel level,
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final entry = AppLogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    if (_logs.length >= _maxLogs) {
      _logs.removeAt(0);
    }
    _logs.add(entry);

    if (kDebugMode) {
      debugPrint(entry.format());
    }
    notifyListeners();
  }

  void d(String tag, String message) =>
      log(level: AppLogLevel.debug, tag: tag, message: message);

  void i(String tag, String message) =>
      log(level: AppLogLevel.info, tag: tag, message: message);

  void w(String tag, String message, [Object? error, StackTrace? stack]) =>
      log(
        level: AppLogLevel.warning,
        tag: tag,
        message: message,
        error: error,
        stackTrace: stack,
      );

  void e(String tag, String message, [Object? error, StackTrace? stack]) =>
      log(
        level: AppLogLevel.error,
        tag: tag,
        message: message,
        error: error,
        stackTrace: stack,
      );

  void debug(String tag, String message) => d(tag, message);
  void info(String tag, String message) => i(tag, message);
  void warning(String tag, String message, [Object? error, StackTrace? stack]) =>
      w(tag, message, error, stack);
  void error(String tag, String message, [Object? error, StackTrace? stack]) =>
      e(tag, message, error, stack);

  void clear() {
    _logs.clear();
    notifyListeners();
  }

  String exportFormatted() {
    final buffer = StringBuffer();
    buffer.writeln('=== SircApp Diagnostics & Log Export ===');
    buffer.writeln('Generated at: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Platform: ${kIsWeb ? 'Web (WASM/JS)' : defaultTargetPlatform.name}');
    buffer.writeln('Total Log Count: ${_logs.length}');
    buffer.writeln('========================================\n');
    for (final entry in _logs) {
      buffer.writeln(entry.format());
    }
    return buffer.toString();
  }
}

/// Riverpod Observer to intercept state transitions and exceptions in Riverpod 3.x
base class AppLogProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    super.didUpdateProvider(context, previousValue, newValue);
    final name = context.provider.name ?? context.provider.runtimeType.toString();
    if (name.contains('localeProvider')) {
      return;
    }
    AppLogService.instance.d(
      'Riverpod',
      '$name -> ${newValue?.runtimeType}',
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    super.providerDidFail(context, error, stackTrace);
    final name = context.provider.name ?? context.provider.runtimeType.toString();
    AppLogService.instance.e(
      'RiverpodError',
      'Provider $name failed: $error',
      error,
      stackTrace,
    );
  }
}

/// Developer Log Console Modal BottomSheet
void showAppLogConsole(BuildContext context) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const AppLogConsoleModal(),
  );
}

class AppLogConsoleModal extends ConsumerStatefulWidget {
  const AppLogConsoleModal({super.key});

  @override
  ConsumerState<AppLogConsoleModal> createState() => _AppLogConsoleModalState();
}

class _AppLogConsoleModalState extends ConsumerState<AppLogConsoleModal> {
  AppLogLevel? _filterLevel;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  int _diskCacheBytes = 0;
  bool _isLoadingDiskCache = false;

  @override
  void initState() {
    super.initState();
    _refreshDiskCache();
  }

  Future<void> _refreshDiskCache() async {
    setState(() => _isLoadingDiskCache = true);
    final bytes = await AppImageCacheService.instance.getDiskCachedBytes();
    if (mounted) {
      setState(() {
        _diskCacheBytes = bytes;
        _isLoadingDiskCache = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLogService.instance,
      builder: (context, _) {
        final logService = AppLogService.instance;
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final locale = ref.watch(localeProvider);

        final allLogs = logService.logs;
        final filteredLogs = allLogs.reversed.where((entry) {
          if (_filterLevel != null && entry.level != _filterLevel) return false;
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            final matchTag = entry.tag.toLowerCase().contains(query);
            final matchMsg = entry.message.toLowerCase().contains(query);
            return matchTag || matchMsg;
          }
          return true;
        }).toList();

        final cacheBytes = PaintingBinding.instance.imageCache.currentSizeBytes;
        final cacheCount = PaintingBinding.instance.imageCache.currentSize;

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Drag Handle
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.terminal_rounded, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Languages.settings.developerConsole,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Platform: ${kIsWeb ? "Web (WASM)" : defaultTargetPlatform.name} • Locale: ${locale.languageCode}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: Languages.settings.copyLogs,
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(
                            ClipboardData(text: logService.exportFormatted()),
                          );
                          Toast.show(Languages.settings.logsCopied);
                        },
                      ),
                      IconButton(
                        tooltip: Languages.settings.clearLogs,
                        icon: const Icon(Icons.delete_outline_rounded, size: 20),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          logService.clear();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Diagnostics & Image Cache Management Strip
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _diagItem(
                              label: Languages.settings.imageCacheMemory,
                              value: '$cacheCount (${AppImageCacheService.formatBytes(cacheBytes)})',
                            ),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              minimumSize: const Size(0, 28),
                            ),
                            onPressed: () {
                              AppImageCacheService.instance.clearMemory();
                              AppLogService.instance.info('ImageCache', 'L1 Memory cache cleared');
                              HapticFeedback.lightImpact();
                              Toast.show(Languages.settings.cacheClearedToast);
                            },
                            child: Text(
                              Languages.settings.clearMemoryCache,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _diagItem(
                              label: Languages.settings.imageCacheDisk,
                              value: kIsWeb
                                  ? 'Web (Browser Cache)'
                                  : _isLoadingDiskCache
                                      ? '...'
                                      : AppImageCacheService.formatBytes(_diskCacheBytes),
                            ),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              minimumSize: const Size(0, 28),
                            ),
                            onPressed: () async {
                              if (kIsWeb) {
                                Toast.show(Languages.settings.diskCacheWebNotice);
                                return;
                              }
                              await AppImageCacheService.instance.clearDiskCache();
                              await _refreshDiskCache();
                              AppLogService.instance.info('ImageCache', 'L2 Disk cache cleared');
                              HapticFeedback.lightImpact();
                              Toast.show(Languages.settings.cacheClearedToast);
                            },
                            child: Text(
                              Languages.settings.clearDiskCache,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 6),
                          FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              minimumSize: const Size(0, 28),
                            ),
                            onPressed: () async {
                              await AppImageCacheService.instance.clearAll();
                              await _refreshDiskCache();
                              AppLogService.instance.info('ImageCache', 'L1+L2 All image caches cleared');
                              HapticFeedback.heavyImpact();
                              Toast.show(Languages.settings.cacheClearedToast);
                            },
                            child: Text(
                              Languages.settings.clearAllCache,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Filter Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: Languages.search,
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                              prefixIcon: const Icon(Icons.search, size: 16),
                              contentPadding: EdgeInsets.zero,
                              filled: true,
                              fillColor: colors.surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _filterChip(null, Languages.settings.logLevelAll),
                      const SizedBox(width: 4),
                      _filterChip(AppLogLevel.info, Languages.settings.logLevelInfo),
                      const SizedBox(width: 4),
                      _filterChip(AppLogLevel.warning, Languages.settings.logLevelWarn),
                      const SizedBox(width: 4),
                      _filterChip(AppLogLevel.error, Languages.settings.logLevelError),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Log Entries List
                Expanded(
                  child: filteredLogs.isEmpty
                      ? Center(
                          child: Text(
                            'No logs recorded yet',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: filteredLogs.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemBuilder: (context, index) {
                        final entry = filteredLogs[index];
                        return _buildLogItem(entry, colors);
                      },
                    ),
            ),
          ],
        );
      },
    );
  },
);
  }

  Widget _diagItem({required String label, required String value}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _filterChip(AppLogLevel? level, String label) {
    final active = _filterLevel == level;
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _filterLevel = level);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: active ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? colors.onPrimary : colors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildLogItem(AppLogEntry entry, ColorScheme colors) {
    Color badgeColor;
    Color textColor;
    switch (entry.level) {
      case AppLogLevel.error:
        badgeColor = colors.errorContainer;
        textColor = colors.error;
        break;
      case AppLogLevel.warning:
        badgeColor = Colors.amber.withValues(alpha: 0.2);
        textColor = Colors.amber.shade800;
        break;
      case AppLogLevel.info:
        badgeColor = colors.primaryContainer;
        textColor = colors.primary;
        break;
      case AppLogLevel.debug:
        badgeColor = colors.surfaceContainerHighest;
        textColor = colors.onSurfaceVariant;
        break;
    }

    final time =
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}.${entry.timestamp.millisecond.toString().padLeft(3, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  entry.level.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '[$time]',
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  entry.tag,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SelectableText(
            entry.message,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
          if (entry.error != null) ...[
            const SizedBox(height: 4),
            SelectableText(
              'Error: ${entry.error}',
              style: TextStyle(
                fontSize: 11,
                color: colors.error,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
