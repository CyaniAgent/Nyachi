// SPDX-License-Identifier: AGPL-3.0-or-later

// Moves the golden-rendered icon PNGs into assets/brand/ after
// `flutter test --update-goldens tool/gen_app_icon_test.dart`.
import 'dart:io';

void main() {
  const outputs = [
    ('tool/goldens/app_icon_full.png', 'assets/brand/app_icon_full.png'),
    ('tool/goldens/app_icon_fg.png', 'assets/brand/app_icon_fg.png'),
  ];
  for (final (source, target) in outputs) {
    File(target)
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(File(source).readAsBytesSync());
    final size = File(target).lengthSync();
    stdout.writeln('$target ($size bytes)');
  }
}
