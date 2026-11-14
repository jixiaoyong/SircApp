import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:material_ui/material_ui.dart';

/*
* @description: try to solve the image load error when network image is used in web
* which detail is in the following link: https://docs.flutter.dev/development/platform-integration/web-images#cross-origin-resource-sharing-cors
*
* for now, please use the following code to solve the problem:
* run for debugging
* flutter run -d chrome --web-renderer html
* 
* production release
* flutter build web --web-renderer html --release
*
* Enhanced with robust visual fallback and smooth transitions for Web CORS, timeouts, and offline conditions.
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/22
*/
class NetworkWebImage extends StatelessWidget {
  final Size? size;
  final double? width;
  final double? height;
  final String? url;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? fallbackWidget;
  final String? fallbackAsset;
  final IconData? fallbackIcon;
  final bool isAvatar;
  final Duration animationDuration;

  const NetworkWebImage(
    this.url, {
    super.key,
    this.size,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
    this.placeholder,
    this.fallbackWidget,
    this.fallbackAsset,
    this.fallbackIcon,
    this.isAvatar = true,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  double? get _effectiveWidth => width ?? size?.width;
  double? get _effectiveHeight => height ?? size?.height;
  BoxFit get _effectiveFit => fit ?? BoxFit.cover;

  bool get _hasValidUrl {
    final raw = url?.trim();
    if (raw == null || raw.isEmpty) return false;
    final uri = Uri.tryParse(raw);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (!_hasValidUrl) {
      content = KeyedSubtree(
        key: const ValueKey('img_empty_or_invalid'),
        child: fallbackWidget ?? _buildFallback(context),
      );
    } else {
      content = ExtendedImage.network(
        url!.trim(),
        width: _effectiveWidth,
        height: _effectiveHeight,
        fit: _effectiveFit,
        cache: true,
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return KeyedSubtree(
                key: const ValueKey('img_loading'),
                child: placeholder ?? _buildLoading(context),
              );
            case LoadState.completed:
              return ExtendedRawImage(
                key: const ValueKey('img_completed'),
                image: state.extendedImageInfo?.image,
                width: _effectiveWidth,
                height: _effectiveHeight,
                fit: _effectiveFit,
              );
            case LoadState.failed:
              return KeyedSubtree(
                key: const ValueKey('img_failed'),
                child: fallbackWidget ?? _buildFallback(context),
              );
          }
        },
      );
    }

    if (borderRadius != null) {
      content = ClipRRect(borderRadius: borderRadius!, child: content);
    }

    return AnimatedSwitcher(
      duration: animationDuration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: content,
    );
  }

  Widget _buildLoading(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = _resolveDimension(
          _effectiveWidth,
          constraints.maxWidth,
          48.0,
        );
        final h = _resolveDimension(
          _effectiveHeight,
          constraints.maxHeight,
          48.0,
        );
        final minDim = min(w, h);
        final indicatorSize = (minDim * 0.38).clamp(12.0, 26.0);
        final strokeWidth = indicatorSize < 18.0 ? 1.8 : 2.2;

        return Container(
          width: _effectiveWidth,
          height: _effectiveHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer
                .withValues(alpha: 0.8),
          ),
          alignment: Alignment.center,
          child: SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallback(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = _resolveDimension(
          _effectiveWidth,
          constraints.maxWidth,
          48.0,
        );
        final h = _resolveDimension(
          _effectiveHeight,
          constraints.maxHeight,
          48.0,
        );
        final minDim = min(w, h);

        Widget innerChild;
        if (fallbackAsset != null && fallbackAsset!.isNotEmpty) {
          final assetSize = (minDim * 0.6).clamp(16.0, 120.0);
          innerChild = Image.asset(
            fallbackAsset!,
            width: assetSize,
            height: assetSize,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => _buildDefaultIcon(context, minDim),
          );
        } else {
          innerChild = _buildDefaultIcon(context, minDim);
        }

        return Container(
          width: _effectiveWidth,
          height: _effectiveHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          alignment: Alignment.center,
          child: innerChild,
        );
      },
    );
  }

  Widget _buildDefaultIcon(BuildContext context, double minDim) {
    final iconSize = (minDim * 0.52).clamp(14.0, 80.0);
    final iconData =
        fallbackIcon ??
        (isAvatar ? Icons.person_rounded : Icons.image_not_supported_outlined);
    final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Icon(iconData, size: iconSize, color: iconColor);
  }

  double _resolveDimension(
    double? directValue,
    double constraintMax,
    double fallback,
  ) {
    if (directValue != null && directValue > 0) return directValue;
    if (constraintMax.isFinite && constraintMax > 0) return constraintMax;
    return fallback;
  }
}
