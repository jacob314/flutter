// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'material.dart';
import 'material_localizations.dart';

/// Asserts that the given context has a [Material] ancestor.
///
/// Used by many material design widgets to make sure that they are
/// only used in contexts where they can print ink onto some material.
///
/// To call this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckHasMaterial(context));
/// ```
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckHasMaterial(BuildContext context) {
  assert(() {
    if (context.widget is! Material && context.ancestorWidgetOfExactType(Material) == null) {
      throw context.describeError(
        '${context.widget.runtimeType} widgets require a Material '
        'widget ancestor, but we couldn\'t find any.',
        contextName: null, // TODO(jacobr): what should the contextName be?
        description:
          'In material design, most widgets are conceptually "printed" on '
          'a sheet of material. In Flutter\'s material library, that '
          'material is represented by the Material widget. It is the '
          'Material widget that renders ink splashes, for instance. '
          'Because of this, many material library widgets require that '
          'there be a Material widget in the tree above them.',
        hint:
          'To introduce a Material widget, you can either directly '
          'include one, or use a widget that contains Material itself, '
          'such as a Card, Dialog, Drawer, or Scaffold.',
        expectedAncestorType: Material,
      );
    }
    return true;
  }());
  return true;
}


/// Asserts that the given context has a [Localizations] ancestor that contains
/// a [MaterialLocalizations] delegate.
///
/// Used by many material design widgets to make sure that they are
/// only used in contexts where they have access to localizations.
///
/// To call this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckHasMaterialLocalizations(context));
/// ```
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckHasMaterialLocalizations(BuildContext context) {
  assert(Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) == null,
    context.describeError(
      'No MaterialLocalizations found.',
      contextName: 'For widget', // TODO(jacobr): describe
      description:
        '${context.widget.runtimeType} widgets require MaterialLocalizations '
        'to be provided by a Localizations widget ancestor.\n'
        'Localizations are used to generate many different messages, labels,'
        'and abbreviations which are used by the material library.\n',
      fix:
        'To introduce a MaterialLocalizations, either use a '
        ' MaterialApp at the root of your application to include them '
        'automatically, or add a Localization widget with a '
        'MaterialLocalizations delegate.',
      expectedAncestorType: MaterialLocalizations,
    )
  );
  return true;
}
