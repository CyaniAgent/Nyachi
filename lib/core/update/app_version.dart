// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_version.g.dart';

/// The version this build reports about itself.
///
/// `package_info_plus` is the only source that survives every platform: the
/// web build has no pubspec at runtime and the desktop bundles carry their own
/// metadata, so a constant here would drift from `pubspec.yaml` exactly as the
/// old hard-coded string did.
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version.isEmpty ? info.buildNumber : info.version;
}

/// A published release that is newer than the running build.
class AvailableRelease {
  const AvailableRelease({
    required this.tag,
    required this.name,
    required this.url,
    required this.isPrerelease,
  });

  final String tag;
  final String name;
  final String url;
  final bool isPrerelease;
}

/// Looks up the newest published release on GitHub.
///
/// A pre-release build also considers pre-releases, because a beta cannot be
/// superseded by a stable release that does not exist yet; a stable build only
/// looks at stable releases, so testers are never nagged about a beta.
///
/// Returns null when the running build is current or newer. Network failures
/// propagate: the caller shows nothing rather than inventing an update.
@riverpod
Future<AvailableRelease?> availableRelease(Ref ref) async {
  final running = await ref.watch(appVersionProvider.future);
  final isBeta = running.contains('-');
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.github.com/',
      headers: {'Accept': 'application/vnd.github+json'},
    ),
  );
  ref.onDispose(dio.close);

  final response = await dio.get<List<dynamic>>(
    'repos/CyaniAgent/Nyachi/releases',
    queryParameters: {'per_page': 20},
  );
  for (final entry in response.data ?? <dynamic>[]) {
    final json = entry as Map<String, dynamic>;
    // Drafts are unpublished and must never be offered.
    if (json['draft'] == true) continue;
    final prerelease = json['prerelease'] == true;
    if (prerelease && !isBeta) continue;
    final tag = (json['tag_name'] as String?)?.replaceFirst('v', '');
    if (tag == null) continue;
    if (compareVersions(tag, running) <= 0) return null;
    return AvailableRelease(
      tag: tag,
      name: (json['name'] as String?) ?? tag,
      url: (json['html_url'] as String?) ?? '',
      isPrerelease: prerelease,
    );
  }
  return null;
}

/// Orders `2.0.0-beta.9` style versions, where a pre-release sorts before the
/// release it leads to and a missing pre-release suffix sorts last.
///
/// Exported because a wrong order is invisible in use: it silently either hides
/// an update or offers one that is already installed.
int compareVersions(String a, String b) {
  final left = _parse(a);
  final right = _parse(b);
  final core = _compareNumbers(left.core, right.core);
  if (core != 0) return core;
  final leftPre = left.pre;
  final rightPre = right.pre;
  if (leftPre == null && rightPre == null) return 0;
  if (leftPre == null) return 1;
  if (rightPre == null) return -1;
  return _comparePre(leftPre, rightPre);
}

({List<int> core, String? pre}) _parse(String version) {
  final withoutBuild = version.split('+').first;
  final dash = withoutBuild.indexOf('-');
  final coreText = dash < 0 ? withoutBuild : withoutBuild.substring(0, dash);
  final pre = dash < 0 ? null : withoutBuild.substring(dash + 1);
  return (
    core: [for (final part in coreText.split('.')) int.tryParse(part) ?? 0],
    pre: pre,
  );
}

int _compareNumbers(List<int> a, List<int> b) {
  for (var i = 0; i < a.length || i < b.length; i++) {
    final left = i < a.length ? a[i] : 0;
    final right = i < b.length ? b[i] : 0;
    if (left != right) return left.compareTo(right);
  }
  return 0;
}

/// Compares `beta.9` style identifiers: dot-separated, numeric when both sides
/// are numeric, otherwise lexicographic.
int _comparePre(String a, String b) {
  final left = a.split('.');
  final right = b.split('.');
  for (var i = 0; i < left.length || i < right.length; i++) {
    if (i >= left.length) return -1;
    if (i >= right.length) return 1;
    final l = int.tryParse(left[i]);
    final r = int.tryParse(right[i]);
    if (l != null && r != null) {
      if (l != r) return l.compareTo(r);
      continue;
    }
    final cmp = left[i].compareTo(right[i]);
    if (cmp != 0) return cmp;
  }
  return 0;
}
