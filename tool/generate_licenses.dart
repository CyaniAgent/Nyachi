// SPDX-License-Identifier: AGPL-3.0-or-later

// Generates assets/licenses.json: one entry per direct/transitive package with
// its license text, used by the About page for attribution.
//
// Run: dart run tool/generate_licenses.dart

import 'dart:convert';
import 'dart:io';

void main() {
  final configFile = File('.dart_tool/package_config.json');
  if (!configFile.existsSync()) {
    stderr.writeln('Run flutter pub get first.');
    exitCode = 1;
    return;
  }
  final config =
      jsonDecode(configFile.readAsStringSync()) as Map<String, Object?>;
  final packages = (config['packages'] as List<Object?>)
      .cast<Map<String, Object?>>();
  final entries = <Map<String, Object?>>[];
  for (final package in packages) {
    final name = package['name'] as String;
    if (name == 'nyachi') continue;
    final rootUri = package['rootUri'] as String;
    final resolved = configFile.parent.uri.resolve(rootUri);
    final dir = Directory.fromUri(resolved);
    final license = _readLicense(dir);
    if (license == null) continue;
    final pubspec = _readPubspecName(dir);
    if (pubspec == null) continue;
    entries.add({
      'name': name,
      'version': _readVersion(dir),
      'license': license,
    });
  }
  entries.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
  final out = File('assets/licenses.json');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(entries));
  stdout.writeln('Wrote ${entries.length} licenses to ${out.path}');
}

String? _readLicense(Directory dir) {
  const candidates = [
    'LICENSE',
    'LICENSE.md',
    'LICENSE.txt',
    'license',
    'COPYING',
    'COPYING.md',
  ];
  for (final name in candidates) {
    final file = File('${dir.path}${Platform.pathSeparator}$name');
    if (file.existsSync()) {
      final text = file.readAsStringSync().trim();
      if (text.isNotEmpty) return text;
    }
  }
  return null;
}

String? _readPubspecName(Directory dir) {
  final file = File('${dir.path}${Platform.pathSeparator}pubspec.yaml');
  if (!file.existsSync()) return null;
  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('name:')) return line.substring(5).trim();
  }
  return null;
}

String _readVersion(Directory dir) {
  final file = File('${dir.path}${Platform.pathSeparator}pubspec.yaml');
  if (!file.existsSync()) return '-';
  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('version:')) return line.substring(8).trim();
  }
  return '-';
}
