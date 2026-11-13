// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 底部导航与抽屉控制器

@ProviderFor(NavigationController)
final navigationControllerProvider = NavigationControllerProvider._();

/// 底部导航与抽屉控制器
final class NavigationControllerProvider
    extends $NotifierProvider<NavigationController, NavigationState> {
  /// 底部导航与抽屉控制器
  NavigationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationControllerHash();

  @$internal
  @override
  NavigationController create() => NavigationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigationState>(value),
    );
  }
}

String _$navigationControllerHash() =>
    r'ed9c813110f2dad8adc39df0bc6538b8d9056c36';

/// 底部导航与抽屉控制器

abstract class _$NavigationController extends $Notifier<NavigationState> {
  NavigationState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NavigationState, NavigationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NavigationState, NavigationState>,
              NavigationState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
