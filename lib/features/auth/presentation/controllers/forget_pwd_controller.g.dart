// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forget_pwd_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ForgetPwdController)
final forgetPwdControllerProvider = ForgetPwdControllerProvider._();

final class ForgetPwdControllerProvider
    extends $NotifierProvider<ForgetPwdController, ForgetPwdState> {
  ForgetPwdControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forgetPwdControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forgetPwdControllerHash();

  @$internal
  @override
  ForgetPwdController create() => ForgetPwdController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForgetPwdState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForgetPwdState>(value),
    );
  }
}

String _$forgetPwdControllerHash() =>
    r'0ba8f43a8ae7d4ae6aa8cfe4ddd02592c489bafe';

abstract class _$ForgetPwdController extends $Notifier<ForgetPwdState> {
  ForgetPwdState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ForgetPwdState, ForgetPwdState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ForgetPwdState, ForgetPwdState>,
              ForgetPwdState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
