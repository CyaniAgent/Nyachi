// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart' hide Clip;

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../app/theme/app_theme.dart';
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
    if (files.length == 1) {
      return Align(
        alignment: Alignment.centerLeft,
        child: _cardFile(context, files.first),
      );
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final file in files) _cardFile(context, file, compact: true),
      ],
    );
  }

  Widget _cardFile(
    BuildContext context,
    DriveFile file, {
    bool compact = false,
  }) {
    final maxWidth = compact ? 196.0 : 400.0;
    final maxHeight = compact ? 147.0 : 300.0;
    if (file.isSensitive && !_revealed.contains(file.id)) {
      return _sizedFile(
        file,
        _SensitiveCover(onTap: () => setState(() => _revealed.add(file.id))),
        maxWidth,
        maxHeight,
      );
    }
    if (_isVideo(file)) {
      return GestureDetector(
        onTap: () => openDetail(context, NoteDetailLocation(widget.noteId)),
        child: _sizedFile(
          file,
          Stack(
            fit: StackFit.expand,
            children: [
              _thumb(file, fit: BoxFit.contain),
              const Center(
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.play_arrow, color: Colors.white),
                ),
              ),
            ],
          ),
          maxWidth,
          maxHeight,
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
        child: _sizedFile(
          file,
          _thumb(file, fit: BoxFit.contain),
          maxWidth,
          maxHeight,
        ),
      );
    }
    return _fileChip(context, file);
  }

  Widget _sizedFile(
    DriveFile file,
    Widget child,
    double maxWidth,
    double maxHeight,
  ) {
    final width = file.properties.width?.toDouble();
    final height = file.properties.height?.toDouble();
    if (width != null && height != null && width > 0 && height > 0) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: AspectRatio(aspectRatio: width / height, child: child),
      );
    }
    return SizedBox(width: maxWidth, height: maxHeight, child: child);
  }

  Widget _interactiveFile(BuildContext context, DriveFile file) {
    if (file.isSensitive && !_revealed.contains(file.id)) {
      return _sizedFile(
        file,
        _SensitiveCover(onTap: () => setState(() => _revealed.add(file.id))),
        400,
        300,
      );
    }
    if (_isVideo(file)) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: VideoEmbed(url: file.url),
      );
    }
    if (_isImage(file)) {
      return _cardFile(context, file);
    }
    return _fileChip(context, file);
  }

  Widget _thumb(DriveFile file, {required BoxFit fit}) {
    final url = file.thumbnailUrl ?? file.url;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(appBorderRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
        color: scheme.surfaceContainer,
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        placeholder: (_, _) => const Center(child: CircularProgressIndicator()),
        errorWidget: (_, _, _) => ColoredBox(
          color: scheme.surfaceContainer,
          child: const Center(child: Icon(Icons.broken_image_outlined)),
        ),
      ),
    );
  }

  Widget _fileChip(BuildContext context, DriveFile file) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
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
  const _SensitiveCover({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(appBorderRadius),
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
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Video(controller: _controller),
      ),
    );
  }
}

/// Opens the image viewer inside a floating window over a dimmed backdrop
/// instead of pushing a full page.
void showImageViewer(
  BuildContext context,
  List<DriveFile> images, {
  int initial = 0,
}) {
  if (images.isEmpty) return;
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _ImageViewer(images: images, initial: initial),
  );
}

class _ImageViewer extends StatefulWidget {
  const _ImageViewer({required this.images, required this.initial});

  final List<DriveFile> images;
  final int initial;

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  late final PageController _page = PageController(initialPage: widget.initial);
  // Tap-to-close must bypass the gesture arena: InteractiveViewer's pan
  // recognizers can claim a jittery click, so close on raw pointer events
  // with only small movement, unless the press landed on the image itself.
  final _pressStart = <int, Offset>{};
  final _onImage = <int>{};

  void _rootPointerDown(PointerEvent event) {
    _pressStart[event.pointer] = event.localPosition;
  }

  void _rootPointerMove(PointerEvent event) {
    final start = _pressStart[event.pointer];
    if (start != null &&
        (event.localPosition - start).distance > kTouchSlop) {
      _pressStart.remove(event.pointer);
    }
  }

  void _rootPointerUp(PointerEvent event) {
    final start = _pressStart.remove(event.pointer);
    if (start == null) return;
    if (_onImage.remove(event.pointer)) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 56, vertical: 40),
      child: Listener(
        onPointerDown: _rootPointerDown,
        onPointerMove: _rootPointerMove,
        onPointerUp: _rootPointerUp,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 560),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _page,
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) => InteractiveViewer(
                    maxScale: 4,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Listener(
                          onPointerDown: (event) =>
                              _onImage.add(event.pointer),
                          child: CachedNetworkImage(
                            imageUrl: widget.images[index].url,
                            fit: BoxFit.contain,
                            errorWidget: (_, _, _) =>
                                const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Listener(
                    // The button closes via its own onTap; mark the press as
                    // consumed so the root tap-to-close listener does not pop
                    // a second route beneath the dialog.
                    onPointerDown: (event) => _onImage.add(event.pointer),
                    child: Material(
                      color: Colors.black38,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
