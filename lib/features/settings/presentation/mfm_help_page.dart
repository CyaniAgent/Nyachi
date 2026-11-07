// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

import '../../../core/mfm/mfm_body.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/l10n_ext.dart';

/// The MFM cheat sheet.
///
/// Every example is rendered by the real body widget, so the page cannot drift
/// from what a note actually produces.
class MfmHelpPage extends StatelessWidget {
  const MfmHelpPage({super.key});

  static const _entries = <(String, String)>[
    (r'**bold**', 'bold'),
    (r'*italic*', 'italic'),
    (r'~~strike~~', 'strike'),
    (r'<small>small</small>', 'small'),
    (r'<center>centered</center>', 'centered'),
    (r'> quote', 'quote'),
    (r'`inline code`', 'inline code'),
    ('```\ncode block\n```', 'code block'),
    (r'$x^2 + y^2$', r'$x^2 + y^2$'),
    (r'@user', '@user'),
    (r'#tag', '#tag'),
    (r':emoji:', ':emoji:'),
    (r'[label](https://example.com)', '[label](https://example.com)'),
    (r'$[x2 big]', 'x2'),
    (r'$[spin spinning]', 'spin'),
    (r'$[rainbow rainbow]', 'rainbow'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mfmHelpTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              for (final entry in _entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Text(
                    entry.$1.replaceAll('\n', r'\n'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
                  child: MfmBody(text: entry.$1, detail: true),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
