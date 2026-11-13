// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationsController)
final notificationsControllerProvider = NotificationsControllerProvider._();

final class NotificationsControllerProvider
    extends $NotifierProvider<NotificationsController, NotificationsState> {
  NotificationsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsControllerHash();

  @$internal
  @override
  NotificationsController create() => NotificationsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsState>(value),
    );
  }
}

String _$notificationsControllerHash() =>
    r'6d8a78e4df9f392cf6964fe37ebacbf0cad407a0';

abstract class _$NotificationsController extends $Notifier<NotificationsState> {
  NotificationsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NotificationsState, NotificationsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationsState, NotificationsState>,
              NotificationsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(InitialController)
final initialControllerProvider = InitialControllerProvider._();

final class InitialControllerProvider
    extends $NotifierProvider<InitialController, InitialState> {
  InitialControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialControllerHash();

  @$internal
  @override
  InitialController create() => InitialController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InitialState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InitialState>(value),
    );
  }
}

String _$initialControllerHash() => r'd07043ef5dd3332455398e0f7860951b47b4c7a0';

abstract class _$InitialController extends $Notifier<InitialState> {
  InitialState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<InitialState, InitialState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InitialState, InitialState>,
              InitialState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
