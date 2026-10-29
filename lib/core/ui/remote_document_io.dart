// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'l10n_ext.dart';

/// Opens a remote document inside an embedded WebView page.
Future<void> openRemoteDocument(
  BuildContext context, {
  required String title,
  required String url,
}) {
  final uri = Uri.tryParse(url);
  // Only absolute http(s) links are openable; relative references have no
  // base to resolve against inside the app.
  if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
    return Future.value();
  }
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => _RemoteDocumentPage(title: title, url: url),
    ),
  );
}

class _RemoteDocumentPage extends StatefulWidget {
  const _RemoteDocumentPage({required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<_RemoteDocumentPage> createState() => _RemoteDocumentPageState();
}

class _RemoteDocumentPageState extends State<_RemoteDocumentPage> {
  var _progress = 1.0;
  var _failed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        bottom: _progress < 1 && !_failed
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress, minHeight: 2),
              )
            : null,
      ),
      body: _failed
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.errorGeneric),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _failed = false),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            )
          : InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                transparentBackground: true,
                supportZoom: true,
              ),
              onProgressChanged: (controller, progress) {
                setState(() => _progress = progress / 100);
              },
              onReceivedError: (controller, request, error) {
                if (request.isForMainFrame ?? false) {
                  setState(() => _failed = true);
                }
              },
            ),
    );
  }
}
