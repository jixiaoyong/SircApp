// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_pwd_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SetPwdController)
final setPwdControllerProvider = SetPwdControllerProvider._();

final class SetPwdControllerProvider
    extends $NotifierProvider<SetPwdController, SetPwdState> {
  SetPwdControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setPwdControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setPwdControllerHash();

  @$internal
  @override
  SetPwdController create() => SetPwdController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetPwdState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetPwdState>(value),
    );
  }
}

String _$setPwdControllerHash() => r'538b519c9845c5410195209fd95a75637e8de990';

abstract class _$SetPwdController extends $Notifier<SetPwdState> {
  SetPwdState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SetPwdState, SetPwdState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SetPwdState, SetPwdState>,
              SetPwdState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
