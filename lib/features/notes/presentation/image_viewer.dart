// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/platform/image_saver.dart';
import '../../../core/ui/l10n_ext.dart';

/// Hero tag shared by a media thumbnail and its full-screen viewer page.
String mediaHeroTag(DriveFile file) => 'media-${file.id}';

/// Opens the immersive image viewer as a transparent full-screen route so the
/// thumbnail can fly into place, then hands off to a black canvas.
void showImageViewer(
  BuildContext context,
  List<DriveFile> images, {
  int initial = 0,
}) {
  Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => _ImageViewerPage(images: images, initial: initial),
    ),
  );
}

class _ImageViewerPage extends StatefulWidget {
  const _ImageViewerPage({required this.images, required this.initial});

  final List<DriveFile> images;
  final int initial;

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  static const _dismissDistance = 120.0;
  static const _dismissVelocity = 700.0;

  late final PageController _page = PageController(initialPage: widget.initial);
  late int _index = widget.initial;
  var _zoomed = false;
  var _dragOffset = Offset.zero;
  var _busy = false;

  Future<void> _download() async {
    if (_busy) return;
    final file = widget.images[_index];
    setState(() => _busy = true);
    final result = await saveImageFromUrl(
      file.url,
      fileName: imageFileName(file.url, file.id),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.failed
              ? l10n.downloadFailed
              : '${l10n.downloadSaved}: ${result.location}',
        ),
      ),
    );
  }

  String _downloadLabel(BuildContext context) => context.l10n.download;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_zoomed) return;
    setState(() => _dragOffset += details.delta);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_zoomed) return;
    final velocity = details.primaryVelocity ?? 0;
    if (_dragOffset.dy.abs() > _dismissDistance ||
        velocity.abs() > _dismissVelocity) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _dragOffset = Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final dragFade = 1 - (_dragOffset.dy.abs() / 600).clamp(0.0, 0.5);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _zoomed ? null : () => Navigator.of(context).pop(),
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.94 * dragFade),
        child: Transform.translate(
          offset: _dragOffset,
          child: Stack(
            children: [
              PageView.builder(
                controller: _page,
                physics: _zoomed
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                itemCount: widget.images.length,
                onPageChanged: (index) => setState(() {
                  _index = index;
                  _zoomed = false;
                }),
                itemBuilder: (context, index) {
                  final file = widget.images[index];
                  return _ZoomableImage(
                    key: ValueKey(file.id),
                    file: file,
                    onZoomChanged: (zoomed) {
                      if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
                    },
                  );
                },
              ),
              if (widget.images.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: IgnorePointer(
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          child: Text(
                            '${_index + 1} / ${widget.images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ViewerAction(
                      icon: Icons.download_outlined,
                      tooltip: _downloadLabel(context),
                      onPressed: _busy ? null : _download,
                    ),
                    const SizedBox(width: 8),
                    _ViewerAction(
                      icon: Icons.close,
                      tooltip: MaterialLocalizations.of(context)
                          .closeButtonTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One page: the Hero-linked image with double-tap zoom. Reports whether the
/// page is zoomed so the pager can stop swallowing horizontal swipes.
class _ZoomableImage extends StatefulWidget {
  const _ZoomableImage({
    required this.file,
    required this.onZoomChanged,
    super.key,
  });

  final DriveFile file;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage>
    with SingleTickerProviderStateMixin {
  static const _doubleTapScale = 2.5;

  final _transform = TransformationController();
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  Animation<Matrix4>? _zoomTween;
  Offset _doubleTapPosition = Offset.zero;

  /// False until the full-resolution image is on screen (or has failed).
  var _loaded = false;

  void _onImageLoaded() {
    if (_loaded) return;
    setState(() => _loaded = true);
  }

  @override
  void initState() {
    super.initState();
    _transform.addListener(_reportZoom);
  }

  @override
  void dispose() {
    _transform
      ..removeListener(_reportZoom)
      ..dispose();
    _animation.dispose();
    super.dispose();
  }

  void _reportZoom() {
    widget.onZoomChanged(_transform.value.getMaxScaleOnAxis() > 1.01);
  }

  void _handleDoubleTap() {
    final current = _transform.value.getMaxScaleOnAxis();
    final target = current > 1.01
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..translateByDouble(
              -_doubleTapPosition.dx * (_doubleTapScale - 1),
              -_doubleTapPosition.dy * (_doubleTapScale - 1),
              0,
              1,
            )
            ..scaleByDouble(_doubleTapScale, _doubleTapScale, 1, 1));
    _zoomTween =
        Matrix4Tween(begin: _transform.value, end: target).animate(
          CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic),
        )..addListener(() {
          _transform.value = _zoomTween!.value;
        });
    _animation
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    // While the full image loads the thumbnail stays on screen: it is already
    // cached from the feed, so the Hero flight has something to land on, and
    // zoom stays disabled until the real image arrives.
    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapPosition = details.localPosition,
      onDoubleTap: _loaded ? _handleDoubleTap : null,
      child: InteractiveViewer(
        transformationController: _transform,
        maxScale: 4,
        panEnabled: _loaded,
        scaleEnabled: _loaded,
        child: SizedBox.expand(
          child: Hero(
            tag: mediaHeroTag(widget.file),
            child: CachedNetworkImage(
              imageUrl: widget.file.url,
              fit: BoxFit.contain,
              fadeInDuration: const Duration(milliseconds: 160),
              width: double.infinity,
              height: double.infinity,
              imageBuilder: (context, imageProvider) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _onImageLoaded();
                });
                return Image(
                  image: imageProvider,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                );
              },
              placeholder: (context, url) => Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.file.thumbnailUrl != null)
                    CachedNetworkImage(
                      imageUrl: widget.file.thumbnailUrl!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  const Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
              errorWidget: (context, url, error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _onImageLoaded();
                });
                return const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white38,
                    size: 40,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular translucent action button used by the viewer's top bar.
class _ViewerAction extends StatelessWidget {
  const _ViewerAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.35),
      ),
    );
  }
}
