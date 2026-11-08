// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/ui/network_image.dart';

void main() {
  testWidgets('remote images use the Flutter pipeline, not a DOM element', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: NyachiImage(url: 'https://cdn.test/a.png')),
      ),
    );

    // The DOM `<img>` is the web fallback for a host that refuses CORS; an
    // image that was never attempted must not be routed there, or it would
    // lose decoding, sizing and caching on every target.
    expect(find.byType(CachedNetworkImage), findsOneWidget);
    expect(find.byType(HtmlElementView), findsNothing);
    expect(find.byType(PlatformViewLink), findsNothing);
  });
}
