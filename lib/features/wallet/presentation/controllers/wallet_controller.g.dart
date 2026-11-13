// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WalletController)
final walletControllerProvider = WalletControllerProvider._();

final class WalletControllerProvider
    extends $NotifierProvider<WalletController, WalletState> {
  WalletControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletControllerHash();

  @$internal
  @override
  WalletController create() => WalletController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WalletState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WalletState>(value),
    );
  }
}

String _$walletControllerHash() => r'367f570c107e8bcb06765501f5fdcd444f32a799';

abstract class _$WalletController extends $Notifier<WalletState> {
  WalletState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WalletState, WalletState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WalletState, WalletState>,
              WalletState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(AddCardController)
final addCardControllerProvider = AddCardControllerProvider._();

final class AddCardControllerProvider
    extends $NotifierProvider<AddCardController, AddCardState> {
  AddCardControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addCardControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addCardControllerHash();

  @$internal
  @override
  AddCardController create() => AddCardController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddCardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddCardState>(value),
    );
  }
}

String _$addCardControllerHash() => r'a3254020334f4b2f6cad651647b78694997bf7cd';

abstract class _$AddCardController extends $Notifier<AddCardState> {
  AddCardState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AddCardState, AddCardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddCardState, AddCardState>,
              AddCardState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
