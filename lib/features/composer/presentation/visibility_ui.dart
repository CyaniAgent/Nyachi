// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

/// The icon representing a note visibility, shared by the composer's
/// visibility menu and the draft panel's rows.
IconData visibilityIcon(NotesCreateRequestVisibility visibility) =>
    switch (visibility) {
      NotesCreateRequestVisibility.public => Icons.public_outlined,
      NotesCreateRequestVisibility.home => Icons.home_outlined,
      NotesCreateRequestVisibility.followers => Icons.lock_outline,
      NotesCreateRequestVisibility.specified => Icons.mail_outline,
    };

/// Parses a stored visibility name; unknown values fall back to public,
/// matching what the server would accept on create.
NotesCreateRequestVisibility parseVisibility(String? name) {
  for (final option in NotesCreateRequestVisibility.values) {
    if (option.name == name) return option;
  }
  return NotesCreateRequestVisibility.public;
}
