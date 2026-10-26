// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:misskey_dart_api/misskey_dart_api.dart';

class NotificationPage {
  const NotificationPage({required this.items, required this.hasMore});

  final List<Notification> items;
  final bool hasMore;
}

abstract interface class NotificationRepository {
  Future<NotificationPage> fetchPage({String? untilId});

  Future<List<Notification>> readCache();

  Future<void> writeCache(List<Notification> notifications);

  Future<void> markAllAsRead();
}
