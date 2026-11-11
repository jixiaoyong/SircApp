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

String _$walletControllerHash() => r'55421f589d1fd263b2eafd819d66ba391b2a7430';

abstract class _$WalletController extends $Notifier<WalletState> {
  WalletState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WalletState, WalletState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WalletState, WalletState>,
              WalletState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
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

String _$addCardControllerHash() => r'3787d6781c93870f82503485890deca0ef6ab6fd';

abstract class _$AddCardController extends $Notifier<AddCardState> {
  AddCardState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AddCardState, AddCardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddCardState, AddCardState>,
              AddCardState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
