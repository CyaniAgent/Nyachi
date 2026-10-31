// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_contributors.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches the repository's contributor list from the GitHub REST API.
///
/// The roster is low-value volatile data: no local persistence, failures
/// surface to the UI for a retry.

@ProviderFor(githubContributors)
final githubContributorsProvider = GithubContributorsProvider._();

/// Fetches the repository's contributor list from the GitHub REST API.
///
/// The roster is low-value volatile data: no local persistence, failures
/// surface to the UI for a retry.

final class GithubContributorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Contributor>>,
          List<Contributor>,
          FutureOr<List<Contributor>>
        >
    with
        $FutureModifier<List<Contributor>>,
        $FutureProvider<List<Contributor>> {
  /// Fetches the repository's contributor list from the GitHub REST API.
  ///
  /// The roster is low-value volatile data: no local persistence, failures
  /// surface to the UI for a retry.
  GithubContributorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'githubContributorsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$githubContributorsHash();

  @$internal
  @override
  $FutureProviderElement<List<Contributor>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Contributor>> create(Ref ref) {
    return githubContributors(ref);
  }
}

String _$githubContributorsHash() =>
    r'9642b47e1d7b70b86e3b905139ee07c129504e72';
