// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatListController)
final chatListControllerProvider = ChatListControllerProvider._();

final class ChatListControllerProvider
    extends $NotifierProvider<ChatListController, ChatListState> {
  ChatListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatListControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatListControllerHash();

  @$internal
  @override
  ChatListController create() => ChatListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatListState>(value),
    );
  }
}

String _$chatListControllerHash() =>
    r'360ca05fcedd8db3fa07ba6b17758a19d5c3f2a7';

abstract class _$ChatListController extends $Notifier<ChatListState> {
  ChatListState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChatListState, ChatListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatListState, ChatListState>,
              ChatListState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ChatThreadController)
final chatThreadControllerProvider = ChatThreadControllerFamily._();

final class ChatThreadControllerProvider
    extends $NotifierProvider<ChatThreadController, ChatThreadState> {
  ChatThreadControllerProvider._({
    required ChatThreadControllerFamily super.from,
    required ChatTarget super.argument,
  }) : super(
         retry: null,
         name: r'chatThreadControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatThreadControllerHash();

  @override
  String toString() {
    return r'chatThreadControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatThreadController create() => ChatThreadController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatThreadState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatThreadState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatThreadControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatThreadControllerHash() =>
    r'3d8883c20164b4bf99bf749f552aafff9264df58';

final class ChatThreadControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatThreadController,
          ChatThreadState,
          ChatThreadState,
          ChatThreadState,
          ChatTarget
        > {
  ChatThreadControllerFamily._()
    : super(
        retry: null,
        name: r'chatThreadControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatThreadControllerProvider call(ChatTarget target) =>
      ChatThreadControllerProvider._(argument: target, from: this);

  @override
  String toString() => r'chatThreadControllerProvider';
}

abstract class _$ChatThreadController extends $Notifier<ChatThreadState> {
  late final _$args = ref.$arg as ChatTarget;
  ChatTarget get target => _$args;

  ChatThreadState build(ChatTarget target);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChatThreadState, ChatThreadState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatThreadState, ChatThreadState>,
              ChatThreadState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
