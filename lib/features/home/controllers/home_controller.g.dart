// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 首页控制器（纯业务逻辑，不与多语言直接耦合）

@ProviderFor(HomeController)
final homeControllerProvider = HomeControllerProvider._();

/// 首页控制器（纯业务逻辑，不与多语言直接耦合）
final class HomeControllerProvider
    extends $NotifierProvider<HomeController, HomeState> {
  /// 首页控制器（纯业务逻辑，不与多语言直接耦合）
  HomeControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'homeControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$homeControllerHash();

  @$internal
  @override
  HomeController create() => HomeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeState>(value),
    );
  }
}

String _$homeControllerHash() => r'036c9a9286c5a7e7a39c2f9a646ef6392edbd5a4';

/// 首页控制器（纯业务逻辑，不与多语言直接耦合）

abstract class _$HomeController extends $Notifier<HomeState> {
  HomeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HomeState, HomeState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<HomeState, HomeState>, HomeState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
