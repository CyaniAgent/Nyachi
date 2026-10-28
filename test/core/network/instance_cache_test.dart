// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/network/instance_repository.dart';
import 'package:nyachi/core/storage/app_database.dart';

/// Complete meta payload as `MetaLite.fromJson` expects it. Kept as raw JSON so
/// every required field of every nested model is present exactly once.
Map<String, Object?> _metaMap({bool urlPreview = true}) {
  return <String, Object?>{
    'maintainerName': null,
    'maintainerEmail': null,
    'version': '2026.9.0',
    'providesTarball': false,
    'name': 'Example',
    'shortName': null,
    'uri': 'https://example.test',
    'description': null,
    'langs': ['en'],
    'tosUrl': null,
    'repositoryUrl': null,
    'feedbackUrl': null,
    'defaultDarkTheme': null,
    'defaultLightTheme': null,
    'clientOptions': {
      'entrancePageStyle': 'classic',
      'showTimelineForVisitor': true,
      'showActivitiesForVisitor': true,
    },
    'disableRegistration': false,
    'emailRequiredForSignup': false,
    'enableHcaptcha': false,
    'hcaptchaSiteKey': null,
    'enableMcaptcha': false,
    'mcaptchaSiteKey': null,
    'mcaptchaInstanceUrl': null,
    'enableRecaptcha': false,
    'recaptchaSiteKey': null,
    'enableTurnstile': false,
    'turnstileSiteKey': null,
    'enableTestcaptcha': false,
    'googleAnalyticsMeasurementId': null,
    'swPublickey': null,
    'mascotImageUrl': '',
    'bannerUrl': null,
    'serverErrorImageUrl': null,
    'infoImageUrl': null,
    'notFoundImageUrl': null,
    'iconUrl': null,
    'maxNoteTextLength': 3000,
    'ads': <Object?>[],
    'notesPerOneAd': 0,
    'enableEmail': false,
    'enableServiceWorker': false,
    'translatorAvailable': false,
    'sentryForFrontend': null,
    'mediaProxy': 'https://example.test/proxy',
    'enableUrlPreview': urlPreview,
    'backgroundImageUrl': null,
    'impressumUrl': null,
    'logoImageUrl': null,
    'privacyPolicyUrl': null,
    'inquiryUrl': null,
    'serverRules': <String>[],
    'themeColor': '#123456',
    'policies': {
      'gtlAvailable': true,
      'ltlAvailable': true,
      'canPublicNote': true,
      'mentionLimit': 20,
      'canInvite': false,
      'inviteLimit': 0,
      'inviteLimitCycle': 0,
      'inviteExpirationTime': 0,
      'canManageCustomEmojis': false,
      'canManageAvatarDecorations': false,
      'canSearchNotes': true,
      'canSearchUsers': true,
      'canUseTranslator': false,
      'canHideAds': false,
      'canCreateChannel': false,
      'driveCapacityMb': 100,
      'maxFileSizeMb': 10,
      'uploadableFileTypes': <String>[],
      'alwaysMarkNsfw': false,
      'canUpdateBioMedia': false,
      'pinLimit': 5,
      'antennaLimit': 5,
      'wordMuteLimit': 100,
      'webhookLimit': 3,
      'clipLimit': 10,
      'noteEachClipsLimit': 200,
      'userListLimit': 10,
      'userEachUserListsLimit': 50,
      'rateLimitFactor': 1,
      'avatarDecorationLimit': 1,
      'canImportAntennas': true,
      'canImportBlocking': true,
      'canImportFollowing': true,
      'canImportMuting': true,
      'canImportUserLists': true,
      'noteDraftLimit': 5,
      'scheduledNoteLimit': 5,
      'watermarkAvailable': true,
      'chatAvailability': 'available',
    },
    'noteSearchableScope': 'global',
    'maxFileSize': 10485760,
    'federation': 'all',
  };
}

InstanceRepository _repository(AppDatabase database) {
  return InstanceRepository(
    // The cache paths under test never reach the network.
    client: MisskeyClient.fromHost('https://example.invalid'),
    cache: database.cacheDao,
    accountId: 'account',
  );
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('cached metadata is served without a network round trip', () async {
    await database.cacheDao.write('account', 'meta', jsonEncode(_metaMap()));

    final info = await _repository(database).readCache();

    expect(info, isNotNull);
    expect(info!.name, 'Example');
    expect(info.themeColor, '#123456');
    expect(info.maxNoteTextLength, 3000);
    expect(info.version, '2026.9.0');
    // The capability flag comes from `enableUrlPreview`; the previous key
    // (`urlPreviewEnabled`) does not exist in the meta payload.
    expect(info.urlPreviewEnabled, isTrue);
  });

  test(
    'a server without URL preview reports the capability as false',
    () async {
      await database.cacheDao.write(
        'account',
        'meta',
        jsonEncode(_metaMap(urlPreview: false)),
      );

      expect(
        (await _repository(database).readCache())?.urlPreviewEnabled,
        isFalse,
      );
    },
  );

  test(
    'the scheduled-notes probe result is persisted with the cache',
    () async {
      await database.cacheDao.write('account', 'meta', jsonEncode(_metaMap()));
      await database.cacheDao.write('account', 'meta.scheduledNotes', '1');

      expect(
        (await _repository(database).readCache())?.scheduledNotesSupported,
        isTrue,
      );
    },
  );

  test(
    'a missing probe record means scheduled notes are unsupported',
    () async {
      await database.cacheDao.write('account', 'meta', jsonEncode(_metaMap()));

      expect(
        (await _repository(database).readCache())?.scheduledNotesSupported,
        isFalse,
      );
    },
  );

  test('a corrupt cache entry degrades to null instead of throwing', () async {
    await database.cacheDao.write('account', 'meta', '{not json');

    expect(await _repository(database).readCache(), isNull);
  });
}
