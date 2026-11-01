// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The version this build reports about itself.
///
/// `package_info_plus` is the only source that survives every platform: the
/// web build has no pubspec at runtime and the desktop bundles carry their own
/// metadata, so a constant here would drift from `pubspec.yaml` exactly as the
/// old hard-coded string did.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// The version this build reports about itself.
///
/// `package_info_plus` is the only source that survives every platform: the
/// web build has no pubspec at runtime and the desktop bundles carry their own
/// metadata, so a constant here would drift from `pubspec.yaml` exactly as the
/// old hard-coded string did.

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The version this build reports about itself.
  ///
  /// `package_info_plus` is the only source that survives every platform: the
  /// web build has no pubspec at runtime and the desktop bundles carry their own
  /// metadata, so a constant here would drift from `pubspec.yaml` exactly as the
  /// old hard-coded string did.
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'586551061f8351a67bc29265c698203855ca593a';

/// Looks up the newest published release on GitHub.
///
/// A pre-release build also considers pre-releases, because a beta cannot be
/// superseded by a stable release that does not exist yet; a stable build only
/// looks at stable releases, so testers are never nagged about a beta.
///
/// Returns null when the running build is current or newer. Network failures
/// propagate: the caller shows nothing rather than inventing an update.

@ProviderFor(availableRelease)
final availableReleaseProvider = AvailableReleaseProvider._();

/// Looks up the newest published release on GitHub.
///
/// A pre-release build also considers pre-releases, because a beta cannot be
/// superseded by a stable release that does not exist yet; a stable build only
/// looks at stable releases, so testers are never nagged about a beta.
///
/// Returns null when the running build is current or newer. Network failures
/// propagate: the caller shows nothing rather than inventing an update.

final class AvailableReleaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<AvailableRelease?>,
          AvailableRelease?,
          FutureOr<AvailableRelease?>
        >
    with
        $FutureModifier<AvailableRelease?>,
        $FutureProvider<AvailableRelease?> {
  /// Looks up the newest published release on GitHub.
  ///
  /// A pre-release build also considers pre-releases, because a beta cannot be
  /// superseded by a stable release that does not exist yet; a stable build only
  /// looks at stable releases, so testers are never nagged about a beta.
  ///
  /// Returns null when the running build is current or newer. Network failures
  /// propagate: the caller shows nothing rather than inventing an update.
  AvailableReleaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableReleaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableReleaseHash();

  @$internal
  @override
  $FutureProviderElement<AvailableRelease?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AvailableRelease?> create(Ref ref) {
    return availableRelease(ref);
  }
}

String _$availableReleaseHash() => r'cceae41b21f001c57a48e521edd7c3a2619018d1';
