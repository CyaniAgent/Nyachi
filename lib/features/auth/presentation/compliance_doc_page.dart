// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/remote_document.dart';

/// Full-text viewer for the bundled application-level compliance documents.
/// Terms and privacy policy render as tabs of one page: selectable Markdown,
/// document links open in the embedded remote-document page.
class ComplianceDocPage extends StatelessWidget {
  const ComplianceDocPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.complianceDocsTitle),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: l10n.complianceTermsTitle),
              Tab(text: l10n.compliancePrivacyTitle),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DocView(assetPath: 'TERMS.md'),
            _DocView(assetPath: 'PRIVACY.md'),
          ],
        ),
      ),
    );
  }
}

class _DocView extends StatefulWidget {
  const _DocView({required this.assetPath});

  final String assetPath;

  @override
  State<_DocView> createState() => _DocViewState();
}

class _DocViewState extends State<_DocView> {
  late final Future<String> _text;

  @override
  void initState() {
    super.initState();
    _text = DefaultAssetBundle.of(context).loadString(widget.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<String>(
      future: _text,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.errorGeneric));
          }
          return const Center(child: CircularProgressIndicator());
        }
        return Markdown(
          data: data,
          selectable: true,
          onTapLink: (text, href, title) {
            final url = href;
            if (url != null) {
              openRemoteDocument(context, title: text, url: url);
            }
          },
        );
      },
    );
  }
}
