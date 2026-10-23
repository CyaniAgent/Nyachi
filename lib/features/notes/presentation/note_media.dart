// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/ui/l10n_ext.dart';

class NoteMedia extends StatefulWidget {
  const NoteMedia({
    required this.files,
    required this.noteId,
    this.interactive = false,
    super.key,
  });

  final List<DriveFile> files;
  final String noteId;
  final bool interactive;

  @override
  State<NoteMedia> createState() => _NoteMediaState();
}

class _NoteMediaState extends State<NoteMedia> {
  final _revealed = <String>{};

  @override
  Widget build(BuildContext context) {
    if (widget.files.isEmpty) return const SizedBox.shrink();
    if (widget.interactive) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final file in widget.files)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _interactiveFile(context, file),
            ),
        ],
      );
    }
    final files = widget.files.take(4).toList(growable: false);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: files.length == 1 ? 1 : 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: files.length == 1 ? 1.7 : 1.2,
      ),
      itemBuilder: (context, index) => _cardFile(context, files[index]),
    );
  }

  Widget _cardFile(BuildContext context, DriveFile file) {
    if (file.isSensitive && !_revealed.contains(file.id)) {
      return _SensitiveCover(
        onTap: () => setState(() => _revealed.add(file.id)),
      );
    }
    if (_isVideo(file)) {
      return GestureDetector(
        onTap: () => context.push('/notes/${widget.noteId}'),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _thumb(file),
            const Center(
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.play_arrow, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
    if (_isImage(file)) {
      return GestureDetector(
        onTap: () => showImageViewer(
          context,
          widget.files.where(_isImage).toList(growable: false),
          initial: widget.files.where(_isImage).toList().indexOf(file),
        ),
        child: _thumb(file),
      );
    }
    return _fileChip(context, file);
  }

  Widget _interactiveFile(BuildContext context, DriveFile file) {
    if (file.isSensitive && !_revealed.contains(file.id)) {
      return _SensitiveCover(
        height: 160,
        onTap: () => setState(() => _revealed.add(file.id)),
      );
    }
    if (_isVideo(file)) return VideoEmbed(url: file.url);
    if (_isImage(file)) {
      return GestureDetector(
        onTap: () => showImageViewer(
          context,
          widget.files.where(_isImage).toList(growable: false),
          initial: widget.files.where(_isImage).toList().indexOf(file),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 420),
          child: _thumb(file),
        ),
      );
    }
    return _fileChip(context, file);
  }

  Widget _thumb(DriveFile file) {
    final url = file.thumbnailUrl ?? file.url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, _) => const ColoredBox(
          color: Colors.black12,
          child: Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, _, _) => const ColoredBox(
          color: Colors.black12,
          child: Center(child: Icon(Icons.broken_image_outlined)),
        ),
      ),
    );
  }

  Widget _fileChip(BuildContext context, DriveFile file) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.attach_file),
        title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(file.type),
      ),
    );
  }

  bool _isImage(DriveFile file) => file.type.startsWith('image/');

  bool _isVideo(DriveFile file) => file.type.startsWith('video/');
}

class _SensitiveCover extends StatelessWidget {
  const _SensitiveCover({this.onTap, this.height = 120});

  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.visibility_off_outlined),
              const SizedBox(height: 4),
              Text(context.l10n.sensitiveContent),
              Text(
                context.l10n.showContent,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoEmbed extends StatefulWidget {
  const VideoEmbed({required this.url, super.key});

  final String url;

  @override
  State<VideoEmbed> createState() => _VideoEmbedState();
}

class _VideoEmbedState extends State<VideoEmbed> {
  late final Player _player;
  late final VideoController _controller;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _player.open(Media(widget.url));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Video(controller: _controller),
      ),
    );
  }
}

void showImageViewer(
  BuildContext context,
  List<DriveFile> images, {
  int initial = 0,
}) {
  if (images.isEmpty) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _ImageViewer(images: images, initial: initial),
    ),
  );
}

class _ImageViewer extends StatelessWidget {
  const _ImageViewer({required this.images, required this.initial});

  final List<DriveFile> images;
  final int initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initial),
        itemCount: images.length,
        itemBuilder: (context, index) => InteractiveViewer(
          child: Center(
            child: CachedNetworkImage(
              imageUrl: images[index].url,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) =>
                  const Icon(Icons.broken_image_outlined, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
