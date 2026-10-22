import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '/src/core/utils/logger.dart';
import '/src/features/auth/application/auth_service.dart';
import '/src/core/api/misskey_api.dart';
import '/src/features/profile/application/network_settings_provider.dart';
import '/src/features/misskey/domain/note.dart';
import '/src/features/misskey/domain/clip.dart';
import '/src/features/misskey/domain/channel.dart';
import '/src/features/misskey/domain/drive_file.dart';
import '/src/features/misskey/domain/drive_folder.dart';
import '/src/features/misskey/domain/misskey_user.dart';
import '/src/features/misskey/domain/messaging_message.dart';
import '/src/features/misskey/domain/misskey_notification.dart';
import '/src/features/misskey/domain/chat_room.dart';
import '/src/features/misskey/domain/announcement.dart';
import '/src/features/misskey/domain/emoji.dart';
import 'misskey_repository_interface.dart';

part 'misskey_repository.g.dart';

class MisskeyRepository implements IMisskeyRepository {
  final MisskeyApi api;

  MisskeyRepository(this.api);

  @override
  String get host => api.host;

  /// 获取 MisskeyApi 实例
  ///
  /// 用于需要直接访问 API 的场景，如 MFM 渲染器
  @override
  MisskeyApi get apiInstance => api;

  @override
  Future<MisskeyUser> getMe() async {
    logger.info('MisskeyRepository: Getting current user information');
    try {
      final (data, error) = await api.i();
      if (error != null) {
        logger.error('MisskeyRepository: Error getting current user info', error);
        throw error;
      }
      if (data == null) {
        logger.error('MisskeyRepository: No data returned from /api/i');
        throw Exception('No user data returned');
      }
      logger.debug('MisskeyRepository: Raw /api/i response: $data');
      final user = MisskeyUser.fromJson(data);
      logger.info(
        'MisskeyRepository: Successfully retrieved user info for ${user.username}',
      );
      return user;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting current user info', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getDriveInfo() async {
    logger.info('MisskeyRepository: Getting drive information');
    try {
      return await api.getDriveInfo();
    } catch (e) {
      logger.error('MisskeyRepository: Error getting drive info', e);
      rethrow;
    }
  }

  @override
  Future<List<Note>> getTimeline(
    String type, {
    int limit = 20,
    String? sinceId,
    String? untilId,
  }) async {
    logger.info(
      'MisskeyRepository: Getting $type timeline, limit=$limit, sinceId=$sinceId, untilId=$untilId',
    );
    try {
      final data = await api.getTimeline(type, limit: limit, sinceId: sinceId, untilId: untilId);
      final notes = await compute((List<dynamic> list) {
        return list.map((e) => Note.fromJson(e)).toList();
      }, data);
      
      // 过滤逻辑：本地和全局时间线过滤掉"主页"可见性的帖子，仅社交时间线不过滤
      if (type == 'Local' || type == 'Global') {
        final filteredNotes = notes.where((note) => note.visibility != 'home').toList();
        logger.info(
          'MisskeyRepository: Successfully retrieved ${filteredNotes.length} notes for $type timeline (filtered from ${notes.length})',
        );
        return filteredNotes;
      }
      
      logger.info(
        'MisskeyRepository: Successfully retrieved ${notes.length} notes for $type timeline',
      );
      return notes;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting $type timeline', e);
      rethrow;
    }
  }

  @override
  Future<List<Channel>> getFeaturedChannels() async {
    logger.info('MisskeyRepository: Getting featured channels');
    try {
      final data = await api.getFeaturedChannels();
      final channels = await compute((List<dynamic> list) {
        return list.map((e) => Channel.fromJson(e)).toList();
      }, data);
      logger.info(
        'MisskeyRepository: Successfully retrieved ${channels.length} featured channels',
      );
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting featured channels', e);
      rethrow;
    }
  }

  @override
  Future<List<Channel>> getFollowingChannels({
    int limit = 20,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Getting following channels');
    try {
      final data = await api.getFollowingChannels(
        limit: limit,
        untilId: untilId,
      );
      final channels = await compute((List<dynamic> list) {
        return list.map((e) => Channel.fromJson(e)).toList();
      }, data);
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting following channels', e);
      rethrow;
    }
  }

  @override
  Future<List<Channel>> getOwnedChannels({
    int limit = 20,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Getting owned channels');
    try {
      final data = await api.getOwnedChannels(limit: limit, untilId: untilId);
      final channels = await compute((List<dynamic> list) {
        return list.map((e) => Channel.fromJson(e)).toList();
      }, data);
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting owned channels', e);
      rethrow;
    }
  }

  @override
  Future<List<Channel>> getFavoriteChannels({
    int limit = 20,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Getting favorite channels');
    try {
      final data = await api.getFavoriteChannels(
        limit: limit,
        untilId: untilId,
      );
      final channels = await compute((List<dynamic> list) {
        return list.map((e) => Channel.fromJson(e)).toList();
      }, data);
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting favorite channels', e);
      rethrow;
    }
  }

  @override
  Future<List<Channel>> searchChannels(
    String query, {
    int limit = 20,
    String? untilId,
  }) async {
    logger.info(
      'MisskeyRepository: Searching channels with query "$query", limit=$limit',
    );
    try {
      final data = await api.searchChannels(
        query,
        limit: limit,
        untilId: untilId,
      );
      final channels = await compute((List<dynamic> list) {
        return list.map((e) => Channel.fromJson(e)).toList();
      }, data);
      logger.info(
        'MisskeyRepository: Successfully retrieved ${channels.length} channels for search query',
      );
      return channels;
    } catch (e) {
      logger.error('MisskeyRepository: Error searching channels', e);
      rethrow;
    }
  }

  @override
  Future<Channel> showChannel(String channelId) async {
    logger.info('MisskeyRepository: Showing channel $channelId');
    try {
      final data = await api.showChannel(channelId);
      return Channel.fromJson(data);
    } catch (e) {
      logger.error('MisskeyRepository: Error showing channel $channelId', e);
      rethrow;
    }
  }

  @override
  Future<MisskeyUser> showUser(String userId) async {
    logger.info('MisskeyRepository: Showing user $userId');
    try {
      final data = await api.showUser(userId);
      return MisskeyUser.fromJson(data);
    } catch (e) {
      logger.error('MisskeyRepository: Error showing user $userId', e);
      rethrow;
    }
  }

  @override
  Future<MisskeyUser> findUserByUsername(
    String username, {
    String? host,
  }) async {
    logger.info('MisskeyRepository: Finding user $username@$host');
    try {
      final data = await api.showUserByUsername(username, host: host);
      return MisskeyUser.fromJson(data);
    } catch (e) {
      logger.error(
        'MisskeyRepository: Error finding user $username@$host', e,
      );
      rethrow;
    }
  }

  @override
  Future<void> createFollow(String userId) async {
    logger.info('MisskeyRepository: Following user $userId');
    try {
      await api.createFollow(userId);
    } catch (e) {
      logger.error('MisskeyRepository: Error following user $userId', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteFollow(String userId) async {
    logger.info('MisskeyRepository: Unfollowing user $userId');
    try {
      await api.deleteFollow(userId);
    } catch (e) {
      logger.error('MisskeyRepository: Error unfollowing user $userId', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getFollowRelation(String userId) async {
    logger.info('MisskeyRepository: Getting follow relation for $userId');
    try {
      return await api.getFollowRelation(userId);
    } catch (e) {
      logger.error(
        'MisskeyRepository: Error getting follow relation for $userId',
        e,
      );
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFollowers(
    String userId, {
    int limit = 30,
  }) async {
    logger.info(
      'MisskeyRepository: Getting followers for $userId, limit=$limit',
    );
    try {
      final data = await api.getFollowers(userId, limit: limit);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      logger.error(
        'MisskeyRepository: Error getting followers for $userId',
        e,
      );
      rethrow;
    }
  }

  @override
  Future<List<Note>> getChannelTimeline(
    String channelId, {
    int limit = 20,
    String? untilId,
  }) async {
    logger.info(
      'MisskeyRepository: Getting channel $channelId timeline, limit=$limit, untilId=$untilId',
    );
    try {
      final data = await api.getChannelTimeline(
        channelId,
        limit: limit,
        untilId: untilId,
      );
      final notes = await compute((List<dynamic> list) {
        return list.map((e) => Note.fromJson(e)).toList();
      }, data);
      logger.info(
        'MisskeyRepository: Successfully retrieved ${notes.length} notes for channel $channelId timeline',
      );
      return notes;
    } catch (e) {
      logger.error(
        'MisskeyRepository: Error getting channel $channelId timeline',
        e,
      );
      rethrow;
    }
  }

  @override
  Future<List<Clip>> getClips({int limit = 20, String? untilId}) async {
    logger.info('MisskeyRepository: Getting clips, limit=$limit');
    try {
      final data = await api.getClips(limit: limit, untilId: untilId);
      final clips = await compute((List<dynamic> list) {
        return list.map((e) => Clip.fromJson(e)).toList();
      }, data);
      logger.info(
        'MisskeyRepository: Successfully retrieved ${clips.length} clips',
      );
      return clips;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting clips', e);
      rethrow;
    }
  }

  @override
  Future<List<Note>> getClipNotes({
    required String clipId,
    int limit = 20,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Getting notes for clip $clipId');
    try {
      final data = await api.getClipNotes(
        clipId: clipId,
        limit: limit,
        untilId: untilId,
      );
      final notes = await compute((List<dynamic> list) {
        return list.map((e) => Note.fromJson(e)).toList();
      }, data);
      logger.info(
        'MisskeyRepository: Successfully retrieved ${notes.length} notes for clip $clipId',
      );
      return notes;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting clip notes', e);
      rethrow;
    }
  }

  @override
  Future<void> createNote({
    String? text,
    String? replyId,
    String? renoteId,
    String? channelId,
    List<String>? fileIds,
    String? visibility,
    bool? localOnly,
    String? cw,
    Map<String, dynamic>? poll,
  }) async {
    logger.info('MisskeyRepository: Creating note');
    try {
      final (_, error) = await api.createNote(
        text: text,
        replyId: replyId,
        renoteId: renoteId,
        channelId: channelId,
        fileIds: fileIds,
        visibility: visibility,
        localOnly: localOnly,
        cw: cw,
        poll: poll,
      );
      if (error != null) {
        logger.error('MisskeyRepository: Error creating note', error);
        throw error;
      }
      logger.info('MisskeyRepository: Successfully created note');
    } catch (e) {
      logger.error('MisskeyRepository: Error creating note', e);
      rethrow;
    }
  }

  @override
  Future<void> renote(String noteId) async {
    logger.info('MisskeyRepository: Renoting note $noteId');
    try {
      final (_, error) = await api.createNote(renoteId: noteId);
      if (error != null) {
        logger.error('MisskeyRepository: Error renoting note $noteId', error);
        throw error;
      }
      logger.info('MisskeyRepository: Successfully renoted note $noteId');
    } catch (e) {
      logger.error('MisskeyRepository: Error renoting note $noteId', e);
      rethrow;
    }
  }

  @override
  Future<void> reply(String noteId, String text) async {
    logger.info('MisskeyRepository: Replying to note $noteId');
    try {
      final (_, error) = await api.createNote(replyId: noteId, text: text);
      if (error != null) {
        logger.error('MisskeyRepository: Error replying to note $noteId', error);
        throw error;
      }
      logger.info('MisskeyRepository: Successfully replied to note $noteId');
    } catch (e) {
      logger.error('MisskeyRepository: Error replying to note $noteId', e);
      rethrow;
    }
  }

  @override
  Future<void> addReaction(String noteId, String reaction) async {
    logger.info(
      'MisskeyRepository: Adding reaction "$reaction" to note $noteId',
    );
    try {
      final (_, error) = await api.createReaction(noteId, reaction);
      if (error != null) {
        logger.error(
          'MisskeyRepository: Error adding reaction to note $noteId',
          error,
        );
        throw error;
      }
      logger.info(
        'MisskeyRepository: Successfully added reaction "$reaction" to note $noteId',
      );
    } catch (e) {
      logger.error(
        'MisskeyRepository: Error adding reaction to note $noteId',
        e,
      );
      rethrow;
    }
  }

  @override
  Future<void> removeReaction(String noteId) async {
    logger.info('MisskeyRepository: Removing reaction from note $noteId');
    try {
      final (_, error) = await api.deleteReaction(noteId);
      if (error != null) {
        logger.error(
          'MisskeyRepository: Error removing reaction from note $noteId',
          error,
        );
        throw error;
      }
      logger.info(
        'MisskeyRepository: Successfully removed reaction from note $noteId',
      );
    } catch (e) {
      logger.error(
        'MisskeyRepository: Error removing reaction from note $noteId',
        e,
      );
      rethrow;
    }
  }

  @override
  Future<List<DriveFile>> getDriveFiles({
    String? folderId,
    int limit = 20,
    String? untilId,
  }) async {
    logger.info(
      'MisskeyRepository: Getting drive files, folderId=$folderId, limit=$limit',
    );
    try {
      final data = await api.getDriveFiles(
        folderId: folderId,
        limit: limit,
        untilId: untilId,
      );
      return await compute((List<dynamic> list) {
        return list.map((e) => DriveFile.fromJson(e)).toList();
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error getting drive files', e);
      rethrow;
    }
  }

  @override
  Future<List<DriveFolder>> getDriveFolders({
    String? folderId,
    int limit = 20,
    String? untilId,
  }) async {
    logger.info(
      'MisskeyRepository: Getting drive folders, folderId=$folderId, limit=$limit',
    );
    try {
      final data = await api.getDriveFolders(
        folderId: folderId,
        limit: limit,
        untilId: untilId,
      );
      return await compute((List<dynamic> list) {
        return list.map((e) => DriveFolder.fromJson(e)).toList();
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error getting drive folders', e);
      rethrow;
    }
  }

  @override
  Future<DriveFolder> createDriveFolder(String name, {String? parentId}) async {
    logger.info(
      'MisskeyRepository: Creating drive folder "$name", parentId=$parentId',
    );
    try {
      final (data, error) = await api.createDriveFolder(name, parentId: parentId);
      if (error != null) {
        throw error;
      }
      if (data == null) {
        throw Exception('Failed to create drive folder: No data returned');
      }
      return DriveFolder.fromJson(data);
    } catch (e) {
      logger.error('MisskeyRepository: Error creating drive folder', e);
      rethrow;
    }
  }

  @override
  Future<String?> getOrCreateAppFolder() async {
    const folderName = 'Nyachi App Transfered';
    try {
      logger.info('MisskeyRepository: Looking for folder "$folderName"');
      final folders = await getDriveFolders();
      final appFolder = folders.where((f) => f.name == folderName).firstOrNull;

      if (appFolder != null) {
        logger.info(
          'MisskeyRepository: Found existing folder: ${appFolder.id}',
        );
        return appFolder.id;
      }

      logger.info('MisskeyRepository: Folder not found, creating it');
      final newFolder = await createDriveFolder(folderName);
      return newFolder.id;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting/creating app folder', e);
      return null; // Fallback to root on error
    }
  }

  @override
  Future<DriveFile> updateDriveFile(
    String fileId, {
    String? name,
    String? folderId,
    bool? isSensitive,
    String? comment,
  }) async {
    logger.info(
      'MisskeyRepository: Updating drive file $fileId, name=$name, folderId=$folderId',
    );
    try {
      final (data, error) = await api.updateDriveFile(
        fileId,
        name: name,
        folderId: folderId,
        isSensitive: isSensitive,
        comment: comment,
      );
      if (error != null) {
        logger.error('MisskeyRepository: Error updating drive file', error);
        throw error;
      }
      if (data == null) {
        throw Exception('Failed to update drive file: No data returned');
      }
      return DriveFile.fromJson(data);
    } catch (e) {
      logger.error('MisskeyRepository: Error updating drive file', e);
      rethrow;
    }
  }

  @override
  Future<DriveFolder> updateDriveFolder(
    String folderId, {
    String? name,
    String? parentId,
  }) async {
    logger.info(
      'MisskeyRepository: Updating drive folder $folderId, name=$name, parentId=$parentId',
    );
    try {
      final (data, error) = await api.updateDriveFolder(
        folderId,
        name: name,
        parentId: parentId,
      );
      if (error != null) {
        logger.error('MisskeyRepository: Error updating drive folder', error);
        throw error;
      }
      if (data == null) {
        throw Exception('Failed to update drive folder: No data returned');
      }
      return DriveFolder.fromJson(data);
    } catch (e) {
      logger.error('MisskeyRepository: Error updating drive folder', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteDriveFile(String fileId) async {
    logger.info('MisskeyRepository: Deleting drive file $fileId');
    try {
      final (_, error) = await api.deleteDriveFile(fileId);
      if (error != null) {
        logger.error('MisskeyRepository: Error deleting drive file', error);
        throw error;
      }
    } catch (e) {
      logger.error('MisskeyRepository: Error deleting drive file', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteDriveFolder(String folderId) async {
    logger.info('MisskeyRepository: Deleting drive folder $folderId');
    try {
      final (_, error) = await api.deleteDriveFolder(folderId);
      if (error != null) {
        logger.error('MisskeyRepository: Error deleting drive folder', error);
        throw error;
      }
    } catch (e) {
      logger.error('MisskeyRepository: Error deleting drive folder', e);
      rethrow;
    }
  }

  @override
  Future<DriveFile> uploadDriveFile(
    List<int> bytes,
    String filename, {
    String? folderId,
  }) async {
    logger.info(
      'MisskeyRepository: Uploading drive file "$filename", folderId=$folderId',
    );
    try {
      // If no folderId is specified, we try to use the Nyachi App Transfered folder
      final targetFolderId = folderId ?? await getOrCreateAppFolder();

      final (data, error) = await api.uploadDriveFile(
        bytes,
        filename,
        folderId: targetFolderId,
      );
      if (error != null) {
        logger.error('MisskeyRepository: Error uploading drive file', error);
        throw error;
      }
      if (data == null) {
        logger.error('MisskeyRepository: No data returned from uploadDriveFile');
        throw Exception('No file data returned');
      }
      return DriveFile.fromJson(data);
    } catch (e) {
      logger.error('MisskeyRepository: Error uploading drive file', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getMeta() async {
    logger.debug('MisskeyRepository: Getting instance meta');
    try {
      final (data, error) = await api.getMeta();
      if (error != null) {
        logger.error('MisskeyRepository: Error getting instance meta', error);
        throw error;
      }
      if (data == null) {
        logger.error('MisskeyRepository: No data returned from getMeta');
        throw Exception('No meta data returned');
      }
      return data;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting instance meta', e);
      rethrow;
    }
  }

  /// Check if a note still exists on the server
  @override
  Future<bool> checkNoteExists(String noteId) async {
    logger.debug('MisskeyRepository: Checking if note exists: $noteId');
    try {
      return await api.checkNoteExists(noteId);
    } catch (e) {
      logger.error('MisskeyRepository: Error checking note existence', e);
      return true; // Assume exists to avoid false deletions
    }
  }

  /// Get a single note by ID
  @override
  Future<Note> getNote(String noteId) async {
    logger.debug('MisskeyRepository: Getting note: $noteId');
    try {
      final data = await api.getNote(noteId);
      final note = await compute((Map<String, dynamic> json) {
        return Note.fromJson(json);
      }, data);
      logger.debug('MisskeyRepository: Successfully retrieved note: $noteId');
      return note;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting note: $noteId', e);
      // 抛出更友好的异常信息，而不是直接 rethrow
      throw Exception('Failed to get note: ${e.toString()}');
    }
  }

  /// Get the number of online users
  @override
  Future<int> getOnlineUsersCount() async {
    logger.debug('MisskeyRepository: Getting online users count');
    try {
      return await api.getOnlineUsersCount();
    } catch (e) {
      logger.error('MisskeyRepository: Error getting online users count', e);
      rethrow;
    }
  }

  // --- Messaging ---

  @override
  Future<List<MessagingMessage>> getMessagingHistory({int limit = 20}) async {
    logger.info('MisskeyRepository: Getting messaging history, limit=$limit');
    try {
      final (data, error) = await api.getMessagingHistory(limit: limit);
      if (error != null) {
        logger.error('MisskeyRepository: Error getting messaging history', error);
        throw error;
      }
      if (data == null) {
        logger.error('MisskeyRepository: No data returned from getMessagingHistory');
        throw Exception('No messaging history data returned');
      }

      final result = await compute(_parseMessagingHistory, data);
      final messages = result.messages;
      final missingUserIds = result.missingUserIds;

      // Fetch missing users
      if (missingUserIds.isNotEmpty) {
        logger.info(
          'MisskeyRepository: Fetching ${missingUserIds.length} missing users',
        );
        final users = <String, MisskeyUser>{};
        // 限制并发数，防止大量 showUser 请求同时发送导致 524
        await _fetchWithConcurrency(
          missingUserIds,
          (id) async {
            try {
              final user = await showUser(id);
              users[id] = user;
            } catch (e) {
              logger.error(
                'MisskeyRepository: Error fetching missing user $id',
                e,
              );
            }
          },
          concurrency: 5,
        );

        // Update messages with fetched users
        for (var i = 0; i < messages.length; i++) {
          final m = messages[i];
          MisskeyUser? updatedUser = m.user ?? users[m.userId];
          MisskeyUser? updatedRecipient = m.recipient ?? users[m.recipientId];

          if (updatedUser != m.user || updatedRecipient != m.recipient) {
            messages[i] = m.copyWith(
              user: updatedUser,
              recipient: updatedRecipient,
            );
          }
        }
      }

      logger.info(
        'MisskeyRepository: Successfully retrieved ${messages.length} messages',
      );
      return messages;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting messaging history', e);
      rethrow;
    }
  }

  @override
  Future<List<MessagingMessage>> getChatRoomMessages({
    required String roomId,
    int limit = 20,
    String? untilId,
  }) async {
    logger.info(
      'MisskeyRepository: Getting chat room messages for room $roomId',
    );
    try {
      final data = await api.getChatRoomMessages(roomId, limit: limit);
      return await compute((List<dynamic> list) {
        final messages = <MessagingMessage>[];
        for (final item in data) {
          try {
            var map = Map<String, dynamic>.from(item as Map);
            if (map['user'] == null && map['from'] != null) {
              map['user'] = map['from'];
            }
            if (map['userId'] == null && map['fromId'] != null) {
              map['userId'] = map['fromId'];
            }

            messages.add(MessagingMessage.fromJson(map));
          } catch (e) {
            logger.warning('MisskeyRepository: Failed to parse chat message', e);
          }
        }
        return messages;
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error getting chat room messages', e);
      rethrow;
    }
  }

  @override
  Future<List<ChatRoom>> getJoinedChatRooms() async {
    logger.info('MisskeyRepository: Getting joined chat rooms');
    try {
      final data = await api.getChatRooms();
      return await compute((List<dynamic> list) {
        return list
            .map((e) => ChatRoom.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error getting chat rooms', e);
      rethrow;
    }
  }

  @override
  Future<void> sendChatRoomMessage({
    required String roomId,
    String? text,
    String? fileId,
  }) async {
    logger.info('MisskeyRepository: Sending chat room message to $roomId');
    try {
      await api.sendChatRoomMessage(roomId, text: text, fileId: fileId);
    } catch (e) {
      logger.error('MisskeyRepository: Error sending chat room message', e);
      rethrow;
    }
  }

  @override
  Future<List<MessagingMessage>> getMessagingMessages({
    required String userId,
    int limit = 10,
    String? sinceId,
    String? untilId,
    bool markAsRead = true,
  }) async {
    logger.info(
      'MisskeyRepository: Getting messaging messages for user $userId, limit=$limit',
    );
    try {
      final (data, error) = await api.getMessagingMessages(
        userId: userId,
        limit: limit,
        sinceId: sinceId,
        untilId: untilId,
        markAsRead: markAsRead,
      );
      if (error != null) {
        logger.error('MisskeyRepository: Error getting messaging messages', error);
        throw error;
      }
      if (data == null) {
        logger.error('MisskeyRepository: No data returned from getMessagingMessages');
        throw Exception('No messaging messages data returned');
      }

      final result = await compute(_parseMessagingHistory, data);
      final messages = result.messages;
      final missingUserIds = result.missingUserIds;

      // Fetch missing users
      if (missingUserIds.isNotEmpty) {
        logger.info(
          'MisskeyRepository: Fetching ${missingUserIds.length} missing users for direct messages',
        );
        final users = <String, MisskeyUser>{};
        await _fetchWithConcurrency(
          missingUserIds,
          (id) async {
            try {
              final user = await showUser(id);
              users[id] = user;
            } catch (e) {
              logger.error(
                'MisskeyRepository: Error fetching missing user $id for direct messages',
                e,
              );
            }
          },
          concurrency: 5,
        );

        // Update messages with fetched users
        for (var i = 0; i < messages.length; i++) {
          final m = messages[i];
          MisskeyUser? updatedUser = m.user ?? users[m.userId];
          MisskeyUser? updatedRecipient = m.recipient ?? users[m.recipientId];

          if (updatedUser != m.user || updatedRecipient != m.recipient) {
            messages[i] = m.copyWith(
              user: updatedUser,
              recipient: updatedRecipient,
            );
          }
        }
      }

      return messages;
    } catch (e) {
      logger.error('MisskeyRepository: Error getting messaging messages', e);
      rethrow;
    }
  }

  @override
  Future<MessagingMessage> sendMessagingMessage({
    required String userId,
    String? text,
    String? fileId,
  }) async {
    logger.info('MisskeyRepository: Sending messaging message to user $userId');
    try {
      final (data, error) = await api.createMessagingMessage(
        userId: userId,
        text: text,
        fileId: fileId,
      );
      if (error != null) {
        logger.error('MisskeyRepository: Error sending messaging message', error);
        throw error;
      }
      if (data == null) {
        logger.error('MisskeyRepository: No data returned from createMessagingMessage');
        throw Exception('No messaging message data returned');
      }
      return MessagingMessage.fromJson(data);
    } catch (e) {
      logger.error('MisskeyRepository: Error sending messaging message', e);
      rethrow;
    }
  }

  @override
  Future<void> markMessagingMessageAsRead(String messageId) async {
    logger.info(
      'MisskeyRepository: Marking messaging message $messageId as read',
    );
    final (_, error) = await api.readMessagingMessage(messageId);
    if (error != null) {
      logger.error('MisskeyRepository: Error marking message as read', error);
      throw error;
    }
  }

  @override
  Future<void> deleteMessagingMessage(String messageId) async {
    logger.info('MisskeyRepository: Deleting messaging message $messageId');
    try {
      final (_, error) = await api.deleteMessagingMessage(messageId);
      if (error != null) {
        logger.error('MisskeyRepository: Error deleting message', error);
        throw error;
      }
    } catch (e) {
      logger.error('MisskeyRepository: Error deleting message', e);
      rethrow;
    }
  }

  // --- Actions ---

  @override
  Future<void> bookmark(String noteId) async {
    logger.info('MisskeyRepository: Bookmarking note $noteId');
    try {
      // 1. Check if "Bookmarks" clip exists
      final clips = await getClips();
      String? clipId;

      for (final clip in clips) {
        if (clip.name == 'Bookmarks') {
          clipId = clip.id;
          break;
        }
      }

      // 2. If not, create it
      if (clipId == null) {
        logger.info(
          'MisskeyRepository: "Bookmarks" clip not found, creating it',
        );
        final newClip = await api.createClip(
          'Bookmarks',
          description: 'Created by Nyachi',
        );
        clipId = newClip['id'];
      }

      // 3. Add note to clip
      if (clipId != null) {
        await api.addNoteToClip(clipId, noteId);
        logger.info(
          'MisskeyRepository: Successfully added note to clip $clipId',
        );
      } else {
        throw Exception('Failed to get or create Bookmarks clip');
      }
    } catch (e) {
      logger.error('MisskeyRepository: Error bookmarking note', e);
      rethrow;
    }
  }

  @override
  Future<void> report(String noteId, String userId, String reason) async {
    logger.info('MisskeyRepository: Reporting note $noteId by user $userId');
    try {
      final comment = 'Report for note $noteId: $reason';
      await api.reportUser(userId, comment);
      logger.info('MisskeyRepository: Successfully reported user/note');
    } catch (e) {
      logger.error('MisskeyRepository: Error reporting note', e);
      rethrow;
    }
  }

  @override
  Future<List<Note>> searchNotes(
    String query, {
    int limit = 20,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Searching notes for query: $query');
    try {
      final data = await api.searchNotes(query, limit: limit, untilId: untilId);
      return await compute((List<dynamic> list) {
        return list.map((e) => Note.fromJson(e)).toList();
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error searching notes', e);
      rethrow;
    }
  }

  @override
  Future<List<MisskeyUser>> searchUsers(
    String query, {
    int limit = 20,
    String? offset,
  }) async {
    logger.info('MisskeyRepository: Searching users for query: $query');
    try {
      final data = await api.searchUsers(query, limit: limit, offset: offset);
      return await compute((List<dynamic> list) {
        return list.map((e) => MisskeyUser.fromJson(e)).toList();
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error searching users', e);
      rethrow;
    }
  }

  @override
  Future<List<Note>> getUserNotes(
    String userId, {
    int limit = 20,
    String? untilId,
    bool? withReplies,
    bool? withFiles,
  }) async {
    logger.info('MisskeyRepository: Getting notes for user: $userId');
    try {
      final data = await api.getUserNotes(
        userId,
        limit: limit,
        untilId: untilId,
        withReplies: withReplies,
        withFiles: withFiles,
      );
      return await compute((List<dynamic> list) {
        return list
            .map((e) => Note.fromJson(e as Map<String, dynamic>))
            .toList();
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error getting user notes', e);
      rethrow;
    }
  }

  @override
  Future<List<DriveFile>> getUserDriveFiles(
    String userId, {
    int limit = 30,
    String? untilId,
    String? folderId,
  }) async {
    logger.info('MisskeyRepository: Getting drive files for user: $userId');
    try {
      final data = await api.getUserDriveFiles(
        userId,
        limit: limit,
        untilId: untilId,
        folderId: folderId,
      );
      return await compute((List<dynamic> list) {
        return list
            .map((e) => DriveFile.fromJson(e as Map<String, dynamic>))
            .toList();
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error getting user drive files', e);
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserGalleryPosts(
    String userId, {
    int limit = 10,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Getting gallery posts for user: $userId');
    try {
      final data = await api.getUserGalleryPosts(
        userId,
        limit: limit,
        untilId: untilId,
      );
      return await compute((List<dynamic> list) {
        return list.cast<Map<String, dynamic>>();
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error getting user gallery posts', e);
      rethrow;
    }
  }

  // --- Announcements ---

  @override
  Future<List<Announcement>> getAnnouncements({
    int limit = 10,
    bool withUnreads = true,
    bool isActive = true,
  }) async {
    logger.info('MisskeyRepository: Getting announcements');
    try {
      final data = await api.getAnnouncements(
        limit: limit,
        withUnreads: withUnreads,
        isActive: isActive,
      );
      return await compute((List<dynamic> list) {
        return list.map((e) => Announcement.fromJson(e as Map<String, dynamic>)).toList();
      }, data);
    } catch (e) {
      logger.error('MisskeyRepository: Error getting announcements', e);
      rethrow;
    }
  }

  @override
  Future<void> readAnnouncement(String announcementId) async {
    logger.info('MisskeyRepository: Reading announcement: $announcementId');
    try {
      final (_, error) = await api.readAnnouncement(announcementId);
      if (error != null) {
        logger.error('MisskeyRepository: Error reading announcement', error);
        throw error;
      }
      logger.info('MisskeyRepository: Successfully read announcement: $announcementId');
    } catch (e) {
      logger.error('MisskeyRepository: Error reading announcement', e);
      rethrow;
    }
  }

  // --- Emojis ---

  @override
  Future<List<Emoji>> getEmojis() async {
    logger.info('MisskeyRepository: Getting emojis');
    try {
      final (data, error) = await api.getEmojis();
      if (error != null) {
        logger.error('MisskeyRepository: Error getting emojis', error);
        throw error;
      }
      if (data == null) {
        logger.error('MisskeyRepository: No data returned from getEmojis');
        throw Exception('No emojis data returned');
      }
      final emojis = data['emojis'] as List<dynamic>;
      return await compute((List<dynamic> list) {
        return list.map((e) => Emoji.fromJson(e as Map<String, dynamic>)).toList();
      }, emojis);
    } catch (e) {
      logger.error('MisskeyRepository: Error getting emojis', e);
      rethrow;
    }
  }

  @override
  Future<EmojiDetail> getEmoji(String name) async {
    logger.info('MisskeyRepository: Getting emoji: $name');
    try {
      final (data, error) = await api.getEmoji(name);
      if (error != null) {
        logger.error('MisskeyRepository: Error getting emoji', error);
        throw error;
      }
      if (data == null) {
        logger.error('MisskeyRepository: No data returned from getEmoji');
        throw Exception('No emoji data returned');
      }
      return EmojiDetail.fromJson(data);
    } catch (e) {
      logger.error('MisskeyRepository: Error getting emoji', e);
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> getNoteReactions(
    String noteId, {
    String? type,
    int limit = 10,
    String? sinceId,
    String? untilId,
    int? sinceDate,
    int? untilDate,
  }) async {
    logger.info('MisskeyRepository: Getting reactions for note $noteId');
    try {
      final (data, error) = await api.getNoteReactions(
        noteId,
        type: type,
        limit: limit,
        sinceId: sinceId,
        untilId: untilId,
        sinceDate: sinceDate,
        untilDate: untilDate,
      );
      if (error != null) {
        logger.error('MisskeyRepository: Error getting note reactions', error);
        return [];
      }
      if (data != null) {
        logger.info(
          'MisskeyRepository: Successfully retrieved ${data.length} reactions for note $noteId',
        );
      }
      return data ?? [];
    } catch (e) {
      logger.error('MisskeyRepository: Error getting note reactions', e);
      return [];
    }
  }

  // --- Notifications ---

  @override
  Future<List<MisskeyNotification>> getNotifications({
    int limit = 20,
    String? untilId,
  }) async {
    logger.info('MisskeyRepository: Getting notifications, limit=$limit');
    try {
      final data = await api.getNotifications(limit: limit, untilId: untilId);
      return await compute((List<dynamic> list) {
        return list
            .map(
              (e) => MisskeyNotification.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      }, data);
    } catch (e, stack) {
      logger.error('MisskeyRepository: Error getting notifications', e, stack);
      rethrow;
    }
  }

  @override
  Future<void> votePoll(String noteId, int choice) async {
    logger.info('MisskeyRepository: Voting for choice $choice in note $noteId');
    try {
      final (_, error) = await api.votePoll(noteId, choice);
      if (error != null) {
        logger.error('MisskeyRepository: Error voting for note $noteId', error);
        throw error;
      }
      logger.info('MisskeyRepository: Successfully voted for note $noteId');
    } catch (e) {
      logger.error('MisskeyRepository: Error voting for note $noteId', e);
      rethrow;
    }
  }

  static _MessagingParsingResult _parseMessagingHistory(List<dynamic> data) {
    final messages = <MessagingMessage>[];
    final missingUserIds = <String>{};

    for (final item in data) {
      try {
        var map = Map<String, dynamic>.from(item as Map);

        if (map.containsKey('message') && map['message'] is Map) {
          final outer = map;
          map = Map<String, dynamic>.from(map['message'] as Map);

          if (map['user'] == null && outer['user'] != null) {
            map['user'] = outer['user'];
          }
          if (map['recipient'] == null && outer['recipient'] != null) {
            map['recipient'] = outer['recipient'];
          }
          if (map['userId'] == null && outer['userId'] != null) {
            map['userId'] = outer['userId'];
          }
          if (map['recipientId'] == null && outer['recipientId'] != null) {
            map['recipientId'] = outer['recipientId'];
          }
        }

        if (map['user'] == null && map['from'] != null) {
          map['user'] = map['from'];
        }
        if (map['userId'] == null && map['fromId'] != null) {
          map['userId'] = map['fromId'];
        }

        if (map['group'] != null && map['room'] == null) {
          final group = map['group'];
          if (group is Map && group['room'] != null) {
            map['room'] = group['room'];
          }
        }

        final message = MessagingMessage.fromJson(map);
        messages.add(message);

        if (message.userId != null && message.user == null) {
          missingUserIds.add(message.userId!);
        }
        if (message.recipientId != null && message.recipient == null) {
          missingUserIds.add(message.recipientId!);
        }
        if (map['userId'] != null && message.user == null) {
          missingUserIds.add(map['userId'] as String);
        }
        if (map['recipientId'] != null && message.recipient == null) {
          missingUserIds.add(map['recipientId'] as String);
        }
      } catch (e) {
        logger.warning('MisskeyRepository: Failed to parse messaging message', e);
      }
    }

    return _MessagingParsingResult(messages, missingUserIds.toList());
  }

  /// 限制并发数执行异步任务，防止无界并行请求导致服务器过载 (524)
  static Future<void> _fetchWithConcurrency<T>(
    Iterable<T> items,
    Future<void> Function(T) task, {
    int concurrency = 5,
  }) async {
    final list = items.toList();
    for (var i = 0; i < list.length; i += concurrency) {
      final batch = list.skip(i).take(concurrency);
      await Future.wait(batch.map(task));
    }
  }
}

class _MessagingParsingResult {
  final List<MessagingMessage> messages;
  final List<String> missingUserIds;

  _MessagingParsingResult(this.messages, this.missingUserIds);
}

@riverpod
Future<IMisskeyRepository> misskeyRepository(Ref ref) async {
  logger.info('MisskeyRepository: Initializing repository');
  final account = await ref.watch(selectedMisskeyAccountProvider.future);

  if (account == null) {
    logger.error('MisskeyRepository: No Misskey account selected');
    throw Exception('No Misskey account selected');
  }
  logger.info(
    'MisskeyRepository: Initializing for account: ${account.id} on ${account.host}',
  );
  final networkSettings = ref.read(networkSettingsProvider).value;
  final api = MisskeyApi(
    host: account.host,
    token: account.token,
    userAgent: networkSettings?.effectiveUserAgent,
  );
  return MisskeyRepository(api);
}
