// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The realtime connection for the signed-in account, or null when nobody is
/// signed in - the shell outlives a logout, so this must not throw.
///
/// One socket carries the `main` channel (notifications) plus a chat channel
/// per open thread, so opening a conversation never opens a second socket.
/// Kept alive: a notification arriving while the user is elsewhere still has
/// somewhere to land.

@ProviderFor(realtimeService)
final realtimeServiceProvider = RealtimeServiceProvider._();

/// The realtime connection for the signed-in account, or null when nobody is
/// signed in - the shell outlives a logout, so this must not throw.
///
/// One socket carries the `main` channel (notifications) plus a chat channel
/// per open thread, so opening a conversation never opens a second socket.
/// Kept alive: a notification arriving while the user is elsewhere still has
/// somewhere to land.

final class RealtimeServiceProvider
    extends
        $FunctionalProvider<
          RealtimeService?,
          RealtimeService?,
          RealtimeService?
        >
    with $Provider<RealtimeService?> {
  /// The realtime connection for the signed-in account, or null when nobody is
  /// signed in - the shell outlives a logout, so this must not throw.
  ///
  /// One socket carries the `main` channel (notifications) plus a chat channel
  /// per open thread, so opening a conversation never opens a second socket.
  /// Kept alive: a notification arriving while the user is elsewhere still has
  /// somewhere to land.
  RealtimeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'realtimeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$realtimeServiceHash();

  @$internal
  @override
  $ProviderElement<RealtimeService?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RealtimeService? create(Ref ref) {
    return realtimeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RealtimeService? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RealtimeService?>(value),
    );
  }
}

String _$realtimeServiceHash() => r'a1d03dc9a465f89e831a832b40daa7624f0383c3';

/// Live messages for one chat thread.
///
/// A stream rather than a controller read: the thread controller owns its
/// list, and this only reports what arrived after the page opened.

@ProviderFor(chatThreadStream)
final chatThreadStreamProvider = ChatThreadStreamFamily._();

/// Live messages for one chat thread.
///
/// A stream rather than a controller read: the thread controller owns its
/// list, and this only reports what arrived after the page opened.

final class ChatThreadStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChatMessageItem>,
          ChatMessageItem,
          Stream<ChatMessageItem>
        >
    with $FutureModifier<ChatMessageItem>, $StreamProvider<ChatMessageItem> {
  /// Live messages for one chat thread.
  ///
  /// A stream rather than a controller read: the thread controller owns its
  /// list, and this only reports what arrived after the page opened.
  ChatThreadStreamProvider._({
    required ChatThreadStreamFamily super.from,
    required ChatTarget super.argument,
  }) : super(
         retry: null,
         name: r'chatThreadStreamProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatThreadStreamHash();

  @override
  String toString() {
    return r'chatThreadStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ChatMessageItem> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ChatMessageItem> create(Ref ref) {
    final argument = this.argument as ChatTarget;
    return chatThreadStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatThreadStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatThreadStreamHash() => r'9de29e8956ade2244a1be5c576becb5cc4a1803b';

/// Live messages for one chat thread.
///
/// A stream rather than a controller read: the thread controller owns its
/// list, and this only reports what arrived after the page opened.

final class ChatThreadStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ChatMessageItem>, ChatTarget> {
  ChatThreadStreamFamily._()
    : super(
        retry: null,
        name: r'chatThreadStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Live messages for one chat thread.
  ///
  /// A stream rather than a controller read: the thread controller owns its
  /// list, and this only reports what arrived after the page opened.

  ChatThreadStreamProvider call(ChatTarget target) =>
      ChatThreadStreamProvider._(argument: target, from: this);

  @override
  String toString() => r'chatThreadStreamProvider';
}
