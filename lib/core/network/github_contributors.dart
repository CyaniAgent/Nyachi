// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'github_contributors.g.dart';

/// A GitHub contributor of the Nyachi repository.
class Contributor {
  const Contributor({
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
    required this.contributions,
  });

  factory Contributor.fromJson(Map<String, dynamic> json) => Contributor(
    login: json['login'] as String,
    avatarUrl: json['avatar_url'] as String,
    htmlUrl: json['html_url'] as String,
    contributions: json['contributions'] as int,
  );

  final String login;
  final String avatarUrl;
  final String htmlUrl;
  final int contributions;
}

const _repo = 'CyaniAgent/Nyachi';

/// Fetches the repository's contributor list from the GitHub REST API.
///
/// The roster is low-value volatile data: no local persistence, failures
/// surface to the UI for a retry.
@Riverpod(keepAlive: true)
Future<List<Contributor>> githubContributors(Ref ref) async {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.github.com/',
      headers: {'Accept': 'application/vnd.github+json'},
    ),
  );
  ref.onDispose(dio.close);
  final response = await dio.get<List<dynamic>>(
    'repos/$_repo/contributors',
    queryParameters: {'per_page': 100},
  );
  return [
    for (final entry in response.data ?? <dynamic>[])
      Contributor.fromJson(entry as Map<String, dynamic>),
  ];
}
