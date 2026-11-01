// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mention_candidates.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Accounts the user follows, cached for offline and instant completion.
///
/// Fetched once per session (the provider is keepAlive) because the followings
/// list changes slowly and a mention panel must open without a request.

@ProviderFor(mentionCandidates)
final mentionCandidatesProvider = MentionCandidatesProvider._();

/// Accounts the user follows, cached for offline and instant completion.
///
/// Fetched once per session (the provider is keepAlive) because the followings
/// list changes slowly and a mention panel must open without a request.

final class MentionCandidatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MentionCandidate>>,
          List<MentionCandidate>,
          FutureOr<List<MentionCandidate>>
        >
    with
        $FutureModifier<List<MentionCandidate>>,
        $FutureProvider<List<MentionCandidate>> {
  /// Accounts the user follows, cached for offline and instant completion.
  ///
  /// Fetched once per session (the provider is keepAlive) because the followings
  /// list changes slowly and a mention panel must open without a request.
  MentionCandidatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mentionCandidatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mentionCandidatesHash();

  @$internal
  @override
  $FutureProviderElement<List<MentionCandidate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MentionCandidate>> create(Ref ref) {
    return mentionCandidates(ref);
  }
}

String _$mentionCandidatesHash() => r'34dd6d4064f38ac036ece7609a4af4e9f23d122d';

/// Remote user results for a mention query, merged in after two characters.
///
/// Kept separate from [mentionCandidates] so the local list never waits on a
/// request and so a failed search degrades to local matches only.

@ProviderFor(remoteMentionCandidates)
final remoteMentionCandidatesProvider = RemoteMentionCandidatesFamily._();

/// Remote user results for a mention query, merged in after two characters.
///
/// Kept separate from [mentionCandidates] so the local list never waits on a
/// request and so a failed search degrades to local matches only.

final class RemoteMentionCandidatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MentionCandidate>>,
          List<MentionCandidate>,
          FutureOr<List<MentionCandidate>>
        >
    with
        $FutureModifier<List<MentionCandidate>>,
        $FutureProvider<List<MentionCandidate>> {
  /// Remote user results for a mention query, merged in after two characters.
  ///
  /// Kept separate from [mentionCandidates] so the local list never waits on a
  /// request and so a failed search degrades to local matches only.
  RemoteMentionCandidatesProvider._({
    required RemoteMentionCandidatesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'remoteMentionCandidatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$remoteMentionCandidatesHash();

  @override
  String toString() {
    return r'remoteMentionCandidatesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<MentionCandidate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MentionCandidate>> create(Ref ref) {
    final argument = this.argument as String;
    return remoteMentionCandidates(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RemoteMentionCandidatesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$remoteMentionCandidatesHash() =>
    r'14e2a49f077f02dfe7e44bca766af0a7b52d9dd5';

/// Remote user results for a mention query, merged in after two characters.
///
/// Kept separate from [mentionCandidates] so the local list never waits on a
/// request and so a failed search degrades to local matches only.

final class RemoteMentionCandidatesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<MentionCandidate>>, String> {
  RemoteMentionCandidatesFamily._()
    : super(
        retry: null,
        name: r'remoteMentionCandidatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Remote user results for a mention query, merged in after two characters.
  ///
  /// Kept separate from [mentionCandidates] so the local list never waits on a
  /// request and so a failed search degrades to local matches only.

  RemoteMentionCandidatesProvider call(String query) =>
      RemoteMentionCandidatesProvider._(argument: query, from: this);

  @override
  String toString() => r'remoteMentionCandidatesProvider';
}
