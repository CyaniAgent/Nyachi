// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/platform/device_identity.dart';
import '../../../core/storage/storage_providers.dart';
import 'compliance_controller.dart';

part 'login_controller.freezed.dart';
part 'login_controller.g.dart';

/// Permissions requested when authorising through MiAuth.
///
/// Covers every endpoint the app reaches, not just reading: a missing entry
/// does not fail at sign-in, it fails the first time that feature is used, as a
/// bare 403 with no explanation. `notes/polls/vote` needs `write:votes`, for
/// instance, which `write:notes` does not imply.
///
/// Keep this in step with the calls under `features/*/data`.
const miAuthPermissions = [
  'read:account',
  'write:account', // thread muting, user memo, drafts, profile edits
  'read:notes',
  'write:notes',
  'write:reactions',
  'write:votes',
  'write:favorites',
  'write:report-abuse',
  'read:notifications',
  'write:notifications',
  'read:following',
  'read:blocking',
  'read:mutes',
  'read:chat',
  'write:chat',
  'read:drive',
  'write:drive',
];

bool isMiAuthPending(MisskeyApiException error) {
  if (error.statusCode == 404) return true;
  if (error.statusCode == 200 && error.raw is Map) {
    return (error.raw as Map)['ok'] == false;
  }
  return false;
}

/// The minimum needed to read and post: timeline, notes, reactions, chat.
///
/// Offered to users who would rather not grant the rest; every feature that
/// needs a wider scope then fails with a plain 403, which is the trade the
/// choice names.
const miAuthBasicPermissions = [
  'read:account',
  'read:notes',
  'write:notes',
  'write:reactions',
  'read:notifications',
  'read:chat',
  'write:chat',
];

class MiAuthService {
  MiAuthService(
    String host, {
    required this.clientName,
    this.permissions = miAuthPermissions,
  }) : _client = MisskeyClient.fromHost(
         host,
         dio: createApiDio(),
         authMode: MisskeyAuthMode.none,
       );

  final MisskeyClient _client;

  /// Shown by the server in the permission screen and in the account's app
  /// list, so it names this installation rather than the app alone.
  final String clientName;

  /// What the authorization screen asks the user to approve.
  final List<String> permissions;

  String createSessionId() => _client.miAuth.createSessionId();

  Uri authorizationUri(String sessionId) {
    return _client.miAuth.buildAuthorizationUri(
      sessionId: sessionId,
      name: clientName,
      permissions: permissions,
    );
  }

  Future<MiAuthResult> check(String sessionId) {
    return _client.miAuth.check(sessionId);
  }

  Future<MeDetailed> meForToken(String token) async {
    final authenticated = MisskeyClient.fromHost(
      _client.baseUri.toString(),
      dio: createApiDio(),
      accessToken: token,
    );
    try {
      return await authenticated.account.me();
    } finally {
      authenticated.close();
    }
  }

  Future<void> open(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void close() => _client.close();
}

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default(false) bool busy,
    @Default(false) bool waiting,
    Uri? authorizationUri,
    AppFailure? error,
  }) = _LoginState;
}

@riverpod
class LoginController extends _$LoginController {
  MiAuthService? _service;
  var _cancelled = false;

  @override
  LoginState build() {
    ref.onDispose(() {
      _cancelled = true;
      _service?.close();
    });
    return const LoginState();
  }

  /// Compliance gate: both consent granularities must exist before any
  /// sign-in request leaves the app. The UI disables the buttons; this
  /// guards against bypassing the surface.
  bool _complianceSatisfied(String host) {
    try {
      final normalized = normalizeHost(host);
      final compliance = ref.read(complianceControllerProvider.notifier);
      return compliance.isInstanceAccepted(normalized) &&
          ref.read(complianceControllerProvider).appAccepted;
    } on FormatException {
      return false;
    }
  }

  /// [permissions] is what the server will show on its approval screen; the
  /// caller chooses, so a narrower grant stays available.
  Future<bool> startMiAuth(
    String host, {
    List<String> permissions = miAuthPermissions,
  }) async {
    if (!_complianceSatisfied(host)) {
      state = const LoginState(error: AppFailure(AppFailureKind.auth));
      return false;
    }
    _cancelled = false;
    state = const LoginState(busy: true);
    MiAuthService? service;
    try {
      final clientName = await DeviceIdentity.clientNameFor(
        ref.read(sharedPreferencesProvider),
      );
      service = MiAuthService(
        normalizeHost(host),
        clientName: clientName,
        permissions: permissions,
      );
      _service?.close();
      _service = service;
      final sessionId = service.createSessionId();
      final uri = service.authorizationUri(sessionId);
      state = LoginState(busy: true, waiting: true, authorizationUri: uri);
      try {
        await service.open(uri);
      } catch (_) {
        // The page still exposes a copy/open action.
      }
      final stopwatch = Stopwatch()..start();
      var networkFailures = 0;
      while (!_cancelled && stopwatch.elapsed < const Duration(minutes: 5)) {
        await Future<void>.delayed(const Duration(seconds: 2));
        if (_cancelled) return false;
        try {
          final result = await service.check(sessionId);
          final me = await service.meForToken(result.token);
          await ref
              .read(sessionControllerProvider.notifier)
              .addAccount(host, result.token, me);
          if (!_cancelled) state = const LoginState();
          return true;
        } on MisskeyApiException catch (error) {
          if (isMiAuthPending(error)) continue;
          if (error.statusCode == null) {
            networkFailures++;
            if (networkFailures < 3) continue;
          }
          rethrow;
        }
      }
      if (!_cancelled) {
        state = const LoginState(error: AppFailure(AppFailureKind.unknown));
      }
      return false;
    } catch (error) {
      debugPrint('Nyachi MiAuth failed: ${error.runtimeType}');
      if (!_cancelled) {
        state = LoginState(error: mapFailure(error));
      }
      return false;
    } finally {
      service?.close();
      if (identical(_service, service)) _service = null;
    }
  }

  Future<bool> loginWithToken(String host, String token) async {
    if (!_complianceSatisfied(host)) {
      state = const LoginState(error: AppFailure(AppFailureKind.auth));
      return false;
    }
    _cancelled = false;
    final trimmed = token.trim();
    if (trimmed.isEmpty) {
      state = const LoginState(error: AppFailure(AppFailureKind.auth));
      return false;
    }
    state = const LoginState(busy: true);
    MisskeyClient? client;
    try {
      final normalized = normalizeHost(host);
      client = MisskeyClient.fromHost(
        normalized,
        dio: createApiDio(),
        accessToken: trimmed,
      );
      final me = await client.account.me();
      await ref
          .read(sessionControllerProvider.notifier)
          .addAccount(normalized, trimmed, me);
      state = const LoginState();
      return true;
    } catch (error) {
      debugPrint('Nyachi token login failed: ${error.runtimeType}');
      state = LoginState(error: mapFailure(error));
      return false;
    } finally {
      client?.close();
    }
  }

  void cancel() {
    _cancelled = true;
    state = const LoginState();
  }

  Uri? pendingAuthorizationUri() => state.authorizationUri;
}
