// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/ui/compact_tab_bar.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/failure_action.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/time_format.dart';
import '../../notes/presentation/note_media.dart';
import '../application/chat_controllers.dart';
import '../domain/chat_models.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(chatListControllerProvider);
    final controller = ref.read(chatListControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.chat)),
      body: _ChatLists(state: state, controller: controller, onOpen: _open),
    );
  }

  void _open(ChatTarget target) {
    switch (target) {
      case ChatUserTarget(:final userId):
        openDetail(context, ChatUserDetailLocation(userId));
      case ChatRoomTarget(:final roomId):
        openDetail(context, ChatRoomDetailLocation(roomId));
    }
  }
}

class _ChatLists extends StatelessWidget {
  const _ChatLists({
    required this.state,
    required this.controller,
    required this.onOpen,
  });

  final ChatListState state;
  final ChatListController controller;
  final ValueChanged<ChatTarget> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
            child: CompactTabBar(labels: [l10n.direct, l10n.rooms]),
          ),
          Expanded(
            child: state.loading && state.direct.isEmpty && state.rooms.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _ConversationList(
                        state: state,
                        controller: controller,
                        onOpen: onOpen,
                      ),
                      _RoomList(
                        state: state,
                        controller: controller,
                        onOpen: onOpen,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.state,
    required this.controller,
    required this.onOpen,
  });

  final ChatListState state;
  final ChatListController controller;
  final ValueChanged<ChatTarget> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ReadableWidth(
        child: state.direct.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text(l10n.noConversations)),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                itemCount: state.direct.length,
                itemBuilder: (context, index) {
                  final conversation = state.direct[index];
                  final target = ChatTarget.user(conversation.peer.id);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: ListTile(
                      minVerticalPadding: 16,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          conversation.peer.avatarUrl,
                        ),
                      ),
                      title: Text(
                        conversation.peer.name ?? conversation.peer.username,
                      ),
                      subtitle: Text(
                        conversation.latest.text ??
                            (conversation.latest.file?.name ?? ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        relativeTime(context, conversation.latest.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () => onOpen(target),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _RoomList extends StatelessWidget {
  const _RoomList({
    required this.state,
    required this.controller,
    required this.onOpen,
  });

  final ChatListState state;
  final ChatListController controller;
  final ValueChanged<ChatTarget> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ReadableWidth(
        child: state.rooms.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text(l10n.noRooms)),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                itemCount: state.rooms.length,
                itemBuilder: (context, index) {
                  final room = state.rooms[index];
                  final target = ChatTarget.room(room.id);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: ListTile(
                      minVerticalPadding: 16,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: const CircleAvatar(
                        child: Icon(Icons.groups_outlined),
                      ),
                      title: Text(room.name),
                      subtitle: Text(
                        '${room.description}\n${l10n.roomOwner}: ${room.owner.name ?? room.owner.username}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => onOpen(target),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class ChatThreadPage extends ConsumerStatefulWidget {
  const ChatThreadPage({required this.target, super.key});

  final ChatTarget target;

  @override
  ConsumerState<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends ConsumerState<ChatThreadPage> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  Uint8List? _attachment;
  String? _attachmentName;
  var _lastCount = 0;
  var _wasLoadingOlder = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final active = ref.watch(sessionControllerProvider).active;
    final state = ref.watch(chatThreadControllerProvider(widget.target));
    final controller = ref.read(
      chatThreadControllerProvider(widget.target).notifier,
    );
    final title = state.room?.name ?? state.user?.name ?? l10n.chat;
    final wasLoadingOlder = _wasLoadingOlder;
    _wasLoadingOlder = state.loadingOlder;
    if (state.items.length != _lastCount) {
      _lastCount = state.items.length;
      if (!wasLoadingOlder) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }
        });
      }
    }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ReadableWidth(
        maxWidth: appMaxContentWidth,
        child: Column(
          children: [
            if (state.error != null)
              MaterialBanner(
                content: Text(state.error!.message(l10n)),
                actions: [
                  FailureAction(
                    failure: state.error!,
                    onRetry: controller.refresh,
                  ),
                ],
              ),
            Expanded(
              child: state.loading && state.items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(12),
                      itemCount: state.items.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          if (state.loadingOlder) {
                            return const Padding(
                              padding: EdgeInsets.all(8),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (state.hasMore) {
                            return Center(
                              child: TextButton(
                                onPressed: controller.loadOlder,
                                child: Text(l10n.loadOlder),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }
                        final item = state.items[index - 1];
                        return _MessageBubble(
                          item: item,
                          isMine: item.fromUserId == active?.userId,
                          onVideo: () => _showVideo(item),
                        );
                      },
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    if (_attachment != null)
                      Chip(
                        avatar: const Icon(Icons.attach_file),
                        label: Text(_attachmentName ?? l10n.attachment),
                        onDeleted: () => setState(() {
                          _attachment = null;
                          _attachmentName = null;
                        }),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: l10n.attach,
                            onPressed: state.sending ? null : _pick,
                            icon: const Icon(Icons.attach_file),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _text,
                              focusNode: _focus,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 14,
                                ),
                                hint: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 150),
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeIn,
                                  layoutBuilder:
                                      (
                                        Widget? currentChild,
                                        List<Widget> previousChildren,
                                      ) {
                                        return Stack(
                                          alignment: Alignment.centerLeft,
                                          children: [
                                            ...previousChildren,
                                            ?currentChild,
                                          ],
                                        );
                                      },
                                  transitionBuilder: (child, animation) {
                                    final incoming =
                                        child.key == const ValueKey('hint');
                                    final position = incoming
                                        ? Tween<Offset>(
                                            begin: const Offset(0, 1),
                                            end: Offset.zero,
                                          ).animate(animation)
                                        : Tween<Offset>(
                                            begin: const Offset(0, -1),
                                            end: Offset.zero,
                                          ).animate(animation);
                                    return ClipRect(
                                      child: SlideTransition(
                                        position: position,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _focus.hasFocus
                                      ? const SizedBox.shrink(
                                          key: ValueKey('focused'),
                                        )
                                      : Text(
                                          l10n.messageHint,
                                          key: const ValueKey('hint'),
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                ),
                              ),
                              minLines: 1,
                              maxLines: 4,
                            ),
                          ),
                          IconButton.filled(
                            tooltip: l10n.send,
                            onPressed: state.sending
                                ? null
                                : () => _send(controller, l10n),
                            icon: state.sending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick() async {
    final file = await FilePicker.pickFile();
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _attachment = bytes;
      _attachmentName = file.name;
    });
  }

  Future<void> _send(
    ChatThreadController controller,
    AppLocalizations l10n,
  ) async {
    final ok = await controller.send(
      text: _text.text,
      attachment: _attachment,
      attachmentName: _attachmentName,
    );
    if (!mounted) return;
    if (ok) {
      _text.clear();
      setState(() {
        _attachment = null;
        _attachmentName = null;
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.sendFailed)));
    }
  }

  void _showVideo(ChatMessageItem item) {
    final file = item.file;
    if (file == null) return;
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: VideoEmbed(url: file.url),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.item,
    required this.isMine,
    required this.onVideo,
  });

  final ChatMessageItem item;
  final bool isMine;
  final VoidCallback onVideo;

  @override
  Widget build(BuildContext context) {
    final file = item.file;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMine
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Text(
                item.fromUser?.name ??
                    item.fromUser?.username ??
                    item.fromUserId,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            if (item.text?.isNotEmpty == true) Text(item.text!),
            if (file != null) ...[
              const SizedBox(height: 4),
              _ChatFile(file: file, onVideo: onVideo),
            ],
            const SizedBox(height: 4),
            Text(
              relativeTime(context, item.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatFile extends StatelessWidget {
  const _ChatFile({required this.file, required this.onVideo});

  final DriveFile file;
  final VoidCallback onVideo;

  @override
  Widget build(BuildContext context) {
    if (file.type.startsWith('image/')) {
      return GestureDetector(
        onTap: () => showImageViewer(context, [file]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: file.thumbnailUrl ?? file.url,
            width: 220,
            height: 160,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    if (file.type.startsWith('video/')) {
      return GestureDetector(
        onTap: onVideo,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: file.thumbnailUrl ?? file.url,
              width: 220,
              height: 160,
              fit: BoxFit.cover,
            ),
            const CircleAvatar(
              backgroundColor: Colors.black54,
              child: Icon(Icons.play_arrow, color: Colors.white),
            ),
          ],
        ),
      );
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.insert_drive_file_outlined),
      title: Text(file.name),
      subtitle: Text(file.type),
    );
  }
}
