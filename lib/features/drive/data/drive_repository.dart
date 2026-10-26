// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';

import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/client_provider.dart';
import '../../../core/network/silent_fallback.dart';

part 'drive_repository.g.dart';

/// One page of drive contents for a folder (null = root).
class DriveListing {
  const DriveListing({
    required this.files,
    required this.folders,
    required this.capacity,
    required this.usage,
  });

  final List<DriveFile> files;
  final List<DriveFolder> folders;
  final int capacity;
  final int usage;

  double get usedRatio => capacity <= 0 ? 0 : (usage / capacity).clamp(0, 1);
}

class DriveRepository {
  DriveRepository(this.client);

  final MisskeyClient client;

  static const _pageSize = 30;

  Future<DriveListing> list({String? folderId}) async {
    final files = await client.drive.files(
      limit: _pageSize,
      folderId: folderId,
    );
    final folders = await client.drive.folders(
      limit: _pageSize,
      folderId: folderId,
    );
    final usage = await _usage();
    return DriveListing(
      files: files,
      folders: folders,
      capacity: usage.$1,
      usage: usage.$2,
    );
  }

  Future<(int, int)> _usage() async {
    try {
      final response = await client.drive.get();
      return (response.capacity.toInt(), response.usage.toInt());
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('drive_repository.usage', e);
      return (0, 0);
    }
  }

  Future<DriveFile> upload({
    required Uint8List bytes,
    required String fileName,
    String? folderId,
  }) {
    return client.drive.filesCreate(
      file: bytes,
      fileName: fileName,
      folderId: folderId,
    );
  }

  Future<void> delete(String fileId) {
    return client.drive.filesDelete(fileId: fileId);
  }

  Future<void> deleteFolder(String folderId) {
    return client.drive.foldersDelete(folderId: folderId);
  }

  Future<DriveFolder> createFolder({required String name, String? parentId}) {
    return client.drive.foldersCreate(name: name, parentId: parentId);
  }
}

@Riverpod(keepAlive: true)
DriveRepository driveRepository(Ref ref) =>
    DriveRepository(ref.watch(misskeyClientProvider));

@riverpod
Future<DriveListing> driveListing(Ref ref, String? folderId) {
  return ref.watch(driveRepositoryProvider).list(folderId: folderId);
}
