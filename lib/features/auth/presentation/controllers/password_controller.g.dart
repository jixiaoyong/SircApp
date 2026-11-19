// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PasswordController)
final passwordControllerProvider = PasswordControllerProvider._();

final class PasswordControllerProvider
    extends $NotifierProvider<PasswordController, PasswordState> {
  PasswordControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passwordControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passwordControllerHash();

  @$internal
  @override
  PasswordController create() => PasswordController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PasswordState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PasswordState>(value),
    );
  }
}

String _$passwordControllerHash() =>
    r'28d122f52c76585db16534258f9212bb1a7864bb';

abstract class _$PasswordController extends $Notifier<PasswordState> {
  PasswordState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PasswordState, PasswordState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PasswordState, PasswordState>,
              PasswordState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
