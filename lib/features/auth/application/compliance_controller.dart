// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/storage_providers.dart';

part 'compliance_controller.freezed.dart';
part 'compliance_controller.g.dart';

const appTermsAcceptedKey = 'compliance.appAccepted';
const instanceAcceptedHostsKey = 'compliance.instanceAcceptedHosts';

@freezed
abstract class ComplianceState with _$ComplianceState {
  const factory ComplianceState({
    @Default(false) bool appAccepted,
    @Default({}) Set<String> instanceAcceptedHosts,
  }) = _ComplianceState;
}

/// Tracks the two consent granularities: one application-level acceptance
/// (app terms + privacy policy) and one acceptance per instance host.
@Riverpod(keepAlive: true)
class ComplianceController extends _$ComplianceController {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  ComplianceState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return ComplianceState(
      appAccepted: prefs.getBool(appTermsAcceptedKey) ?? false,
      instanceAcceptedHosts:
          (prefs.getStringList(instanceAcceptedHostsKey) ?? const []).toSet(),
    );
  }

  Future<void> acceptAppTerms() async {
    state = state.copyWith(appAccepted: true);
    await _prefs.setBool(appTermsAcceptedKey, true);
  }

  Future<void> acceptInstanceForHost(String normalizedHost) async {
    final hosts = {...state.instanceAcceptedHosts, normalizedHost};
    state = state.copyWith(instanceAcceptedHosts: hosts);
    await _prefs.setStringList(
      instanceAcceptedHostsKey,
      hosts.toList(growable: false)..sort(),
    );
  }

  /// Pure set lookup; callers pass an already normalized host.
  bool isInstanceAccepted(String host) =>
      state.instanceAcceptedHosts.contains(host);
}
