// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

void main() => runApp(const NyachiApp());

class NyachiApp extends StatelessWidget {
  const NyachiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nyachi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Nyachi')),
      ),
    );
  }
}
