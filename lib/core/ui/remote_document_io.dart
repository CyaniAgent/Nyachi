// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Opens a remote document inside an embedded WebView page.
Future<void> openRemoteDocument(
  BuildContext context, {
  required String title,
  required String url,
}) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        bottom: _progress < 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress, minHeight: 2),
              )
            : null,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        initialSettings: InAppWebViewSettings(
          transparentBackground: true,
          supportZoom: true,
        ),
        onProgressChanged: (controller, progress) {
          setState(() => _progress = progress / 100);
        },
      ),
    );
  }
}
