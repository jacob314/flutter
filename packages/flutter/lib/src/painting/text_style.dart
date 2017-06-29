// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui show ParagraphStyle, TextStyle, lerpDouble;

import 'package:flutter/foundation.dart';

import 'basic_types.dart';

/// An immutable style in which paint text.
///
/// ## Sample code
///
/// ### Bold
///
/// Here, a single line of text in a [Text] widget is given a specific style
/// override. The style is mixed with the ambient [DefaultTextStyle] by the
/// [Text] widget.
///
/// ```dart
/// new Text(
///   'No, we need bold strokes. We need this plan.',
///   style: new TextStyle(fontWeight: FontWeight.bold),
/// )
/// ```
///
/// ### Italics
///
/// As in the previous example, the [Text] widget is given a specific style
/// override which is implicitly mixed with the ambient [DefaultTextStyle].
///
/// ```dart
/// new Text(
///   'Welcome to the present, we\'re running a real nation.',
///   style: new TextStyle(fontStyle: FontStyle.italic),
/// )
/// ```
///
/// ### Opacity
///
/// Each line here is progressively more opaque. The base color is
/// [Colors.black], and [Color.withOpacity] is used to create a derivative color
/// with the desired opacity. The root [TextSpan] for this [RichText] widget is
/// explicitly given the ambient [DefaultTextStyle], since [RichText] does not
/// do that automatically. The inner [TextStyle] objects are implicitly mixed
/// with the parent [TextSpan]'s [TextSpan.style].
///
/// ```dart
/// new RichText(
///   text: new TextSpan(
///     style: DefaultTextStyle.of(context).style,
///     children: <TextSpan>[
///       new TextSpan(
///         text: 'You don\'t have the votes.\n',
///         style: new TextStyle(color: Colors.black.withOpacity(0.6)),
///       ),
///       new TextSpan(
///         text: 'You don\'t have the votes!\n',
///         style: new TextStyle(color: Colors.black.withOpacity(0.8)),
///       ),
///       new TextSpan(
///         text: 'You\'re gonna need congressional approval and you don\'t have the votes!\n',
///         style: new TextStyle(color: Colors.black.withOpacity(1.0)),
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ### Size
///
/// In this example, the ambient [DefaultTextStyle] is explicitly manipulated to
/// obtain a [TextStyle] that doubles the default font size.
///
/// ```dart
/// new Text(
///   'These are wise words, enterprising men quote \'em.',
///   style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
/// )
/// ```
///
/// ### Line height
///
/// The [height] property can be used to change the line height. Here, the line
/// height is set to 100 logical pixels, so that the text is very spaced out.
///
/// ```dart
/// new Text(
///   'Don\'t act surprised, you guys, cuz I wrote \'em!',
///   style: new TextStyle(height: 100.0),
/// )
/// ```
///
/// ### Wavy red underline with black text
///
/// Styles can be combined. In this example, the misspelt word is drawn in black
/// text and underlined with a wavy red line to indicate a spelling error. (The
/// remainder is styled according to the Flutter default text styles, not the
/// ambient [DefaultTextStyle], since no explicit style is given and [RichText]
/// does not automatically use the ambient [DefaultTextStyle].)
///
/// ```dart
/// new RichText(
///   text: new TextSpan(
///     text: 'Don\'t tax the South ',
///     children: <TextSpan>[
///       new TextSpan(
///         text: 'cuz',
///         style: new TextStyle(
///           color: Colors.black,
///           decoration: TextDecoration.underline,
///           decorationColor: Colors.red,
///           decorationStyle: TextDecorationStyle.wavy,
///         ),
///       ),
///       new TextSpan(
///         text: ' we got it made in the shade',
///       ),
///     ],
///   ),
/// )
/// ```
///
/// See also:
///
///  * [Text], the widget for showing text in a single style.
///  * [DefaultTextStyle], the widget that specifies the default text styles for
///    [Text] widgets, configured using a [TextStyle].
///  * [RichText], the widget for showing a paragraph of mix-style text.
///  * [TextSpan], the class that wraps a [TextStyle] for the purposes of
///    passing it to a [RichText].
@immutable
class TextStyle {
  /// Creates a text style.
  const TextStyle({
    this.inherit: true,
    this.color,
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
    this.wordSpacing,
    this.textBaseline,
    this.height,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
  }) : assert(inherit != null);

  /// Whether null values are replaced with their value in an ancestor text
  /// style (e.g., in a [TextSpan] tree).
  ///
  /// If this is false, properties that don't have explicit values will revert
  /// to the defaults: white in color, a font size of 10 pixels, in a sans-serif
  /// font face.
  final bool inherit;

  /// The color to use when painting the text.
  final Color color;

  /// The name of the font to use when painting the text (e.g., Roboto).
  final String fontFamily;

  /// The size of glyphs (in logical pixels) to use when painting the text.
  ///
  /// During painting, the [fontSize] is multiplied by the current
  /// `textScaleFactor` to let users make it easier to read text by increasing
  /// its size.
  final double fontSize;

  /// The typeface thickness to use when painting the text (e.g., bold).
  final FontWeight fontWeight;

  /// The typeface variant to use when drawing the letters (e.g., italics).
  final FontStyle fontStyle;

  /// The amount of space (in logical pixels) to add between each letter.
  /// A negative value can be used to bring the letters closer.
  final double letterSpacing;

  /// The amount of space (in logical pixels) to add at each sequence of
  /// white-space (i.e. between each word). A negative value can be used to
  /// bring the words closer.
  final double wordSpacing;

  /// The common baseline that should be aligned between this text span and its
  /// parent text span, or, for the root text spans, with the line box.
  final TextBaseline textBaseline;

  /// The height of this text span, as a multiple of the font size.
  ///
  /// If applied to the root [TextSpan], this value sets the line height, which
  /// is the minimum distance between subsequent text baselines, as multiple of
  /// the font size.
  final double height;

  /// The decorations to paint near the text (e.g., an underline).
  final TextDecoration decoration;

  /// The color in which to paint the text decorations.
  final Color decorationColor;

  /// The style in which to paint the text decorations (e.g., dashed).
  final TextDecorationStyle decorationStyle;

  /// Creates a copy of this text style but with the given fields replaced with
  /// the new values.
  TextStyle copyWith({
    Color color,
    String fontFamily,
    double fontSize,
    FontWeight fontWeight,
    FontStyle fontStyle,
    double letterSpacing,
    double wordSpacing,
    TextBaseline textBaseline,
    double height,
    TextDecoration decoration,
    Color decorationColor,
    TextDecorationStyle decorationStyle,
  }) {
    return new TextStyle(
      inherit: inherit,
      color: color ?? this.color,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      textBaseline: textBaseline ?? this.textBaseline,
      height: height ?? this.height,
      decoration: decoration ?? this.decoration,
      decorationColor: decorationColor ?? this.decorationColor,
      decorationStyle: decorationStyle ?? this.decorationStyle,
    );
  }

  /// Creates a copy of this text style but with the numeric fields multiplied
  /// by the given factors and then incremented by the given deltas.
  ///
  /// For example, `style.apply(fontSizeFactor: 2.0, fontSizeDelta: 1.0)` would
  /// return a [TextStyle] whose [fontSize] is `style.fontSize * 2.0 + 1.0`.
  ///
  /// For the [fontWeight], the delta is applied to the [FontWeight] enum index
  /// values, so that for instance `style.apply(fontWeightDelta: -2)` when
  /// applied to a `style` whose [fontWeight] is [FontWeight.w500] will return a
  /// [TextStyle] with a [FontWeight.w300].
  ///
  /// The arguments must not be null.
  ///
  /// If the underlying values are null, then the corresponding factors and/or
  /// deltas must not be specified.
  ///
  /// The non-numeric fields can be controlled using the corresponding arguments.
  TextStyle apply({
    Color color,
    String fontFamily,
    double fontSizeFactor: 1.0,
    double fontSizeDelta: 0.0,
    int fontWeightDelta: 0,
    double letterSpacingFactor: 1.0,
    double letterSpacingDelta: 0.0,
    double wordSpacingFactor: 1.0,
    double wordSpacingDelta: 0.0,
    double heightFactor: 1.0,
    double heightDelta: 0.0,
  }) {
    assert(fontSizeFactor != null);
    assert(fontSizeDelta != null);
    assert(fontSize != null || (fontSizeFactor == 1.0 && fontSizeDelta == 0.0));
    assert(fontWeightDelta != null);
    assert(fontWeight != null || fontWeightDelta == 0.0);
    assert(letterSpacingFactor != null);
    assert(letterSpacingDelta != null);
    assert(letterSpacing != null || (letterSpacingFactor == 1.0 && letterSpacingDelta == 0.0));
    assert(wordSpacingFactor != null);
    assert(wordSpacingDelta != null);
    assert(wordSpacing != null || (wordSpacingFactor == 1.0 && wordSpacingDelta == 0.0));
    assert(heightFactor != null);
    assert(heightDelta != null);
    assert(heightFactor != null || (heightFactor == 1.0 && heightDelta == 0.0));
    return new TextStyle(
      inherit: inherit,
      color: color ?? this.color,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize == null ? null : fontSize * fontSizeFactor + fontSizeDelta,
      fontWeight: fontWeight == null ? null : FontWeight.values[(fontWeight.index + fontWeightDelta).clamp(0, FontWeight.values.length - 1)],
      fontStyle: fontStyle,
      letterSpacing: letterSpacing == null ? null : letterSpacing * letterSpacingFactor + letterSpacingDelta,
      wordSpacing: wordSpacing == null ? null : wordSpacing * wordSpacingFactor + wordSpacingDelta,
      textBaseline: textBaseline,
      height: height == null ? null : height * heightFactor + heightDelta,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
    );
  }

  /// Returns a new text style that matches this text style but with some values
  /// replaced by the non-null parameters of the given text style. If the given
  /// text style is null, simply returns this text style.
  TextStyle merge(TextStyle other) {
    if (other == null)
      return this;
    assert(other.inherit);
    return copyWith(
      color: other.color,
      fontFamily: other.fontFamily,
      fontSize: other.fontSize,
      fontWeight: other.fontWeight,
      fontStyle: other.fontStyle,
      letterSpacing: other.letterSpacing,
      wordSpacing: other.wordSpacing,
      textBaseline: other.textBaseline,
      height: other.height,
      decoration: other.decoration,
      decorationColor: other.decorationColor,
      decorationStyle: other.decorationStyle
    );
  }

  /// Interpolate between two text styles.
  ///
  /// This will not work well if the styles don't set the same fields.
  static TextStyle lerp(TextStyle begin, TextStyle end, double t) {
    assert(begin.inherit == end.inherit);
    return new TextStyle(
      inherit: end.inherit,
      color: Color.lerp(begin.color, end.color, t),
      fontFamily: t < 0.5 ? begin.fontFamily : end.fontFamily,
      fontSize: ui.lerpDouble(begin.fontSize ?? end.fontSize, end.fontSize ?? begin.fontSize, t),
      fontWeight: FontWeight.lerp(begin.fontWeight, end.fontWeight, t),
      fontStyle: t < 0.5 ? begin.fontStyle : end.fontStyle,
      letterSpacing: ui.lerpDouble(begin.letterSpacing ?? end.letterSpacing, end.letterSpacing ?? begin.letterSpacing, t),
      wordSpacing: ui.lerpDouble(begin.wordSpacing ?? end.wordSpacing, end.wordSpacing ?? begin.wordSpacing, t),
      textBaseline: t < 0.5 ? begin.textBaseline : end.textBaseline,
      height: ui.lerpDouble(begin.height ?? end.height, end.height ?? begin.height, t),
      decoration: t < 0.5 ? begin.decoration : end.decoration,
      decorationColor: Color.lerp(begin.decorationColor, end.decorationColor, t),
      decorationStyle: t < 0.5 ? begin.decorationStyle : end.decorationStyle
    );
  }

  /// The style information for text runs, encoded for use by `dart:ui`.
  ui.TextStyle getTextStyle({ double textScaleFactor: 1.0 }) {
    return new ui.TextStyle(
      color: color,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      textBaseline: textBaseline,
      fontFamily: fontFamily,
      fontSize: fontSize == null ? null : fontSize * textScaleFactor,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height
    );
  }

  /// The style information for paragraphs, encoded for use by `dart:ui`.
  ///
  /// The `textScaleFactor` argument must not be null. If omitted, it defaults
  /// to 1.0. The other arguments may be null. The `maxLines` argument, if
  /// specified and non-null, must be greater than zero.
  ui.ParagraphStyle getParagraphStyle({
      TextAlign textAlign,
      double textScaleFactor: 1.0,
      String ellipsis,
      int maxLines,
  }) {
    assert(textScaleFactor != null);
    assert(maxLines == null || maxLines > 0);
    return new ui.ParagraphStyle(
      textAlign: textAlign,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontFamily: fontFamily,
      fontSize: fontSize == null ? null : fontSize * textScaleFactor,
      lineHeight: height,
      maxLines: maxLines,
      ellipsis: ellipsis,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other))
      return true;
    if (other is! TextStyle)
      return false;
    final TextStyle typedOther = other;
    return inherit == typedOther.inherit &&
           color == typedOther.color &&
           fontFamily == typedOther.fontFamily &&
           fontSize == typedOther.fontSize &&
           fontWeight == typedOther.fontWeight &&
           fontStyle == typedOther.fontStyle &&
           letterSpacing == typedOther.letterSpacing &&
           wordSpacing == typedOther.wordSpacing &&
           textBaseline == typedOther.textBaseline &&
           height == typedOther.height &&
           decoration == typedOther.decoration &&
           decorationColor == typedOther.decorationColor &&
           decorationStyle == typedOther.decorationStyle;
  }

  @override
  int get hashCode {
    return hashValues(
      inherit,
      color,
      fontFamily,
      fontSize,
      fontWeight,
      fontStyle,
      letterSpacing,
      wordSpacing,
      textBaseline,
      height,
      decoration,
      decorationColor,
      decorationStyle
    );
  }

  @override
  String toString([String prefix = '']) {
    final List<DiagnosticsNode> properties = <DiagnosticsNode>[];
    debugFillProperties(properties);
    // TODO(jacobr): this is a strange toString method for TextStyle.
    // It would make more sense to specify something along the lines of
    // TextStyle(property1; property2; property3) as is done elsewhere.
    return properties
        .where((DiagnosticsNode property) => property.show)
        .map((DiagnosticsNode property) => '$prefix$property')
        .join('\n');
  }

  void debugFillProperties(List<DiagnosticsNode> properties) {
    final List<DiagnosticsNode> styles = <DiagnosticsNode>[];
    styles.add(new DiagnosticsNode.colorProperty('color', color, showNull: false));
    styles.add(new DiagnosticsNode.stringProperty('family', fontFamily, showNull: false));
    styles.add(new DiagnosticsNode.doubleProperty('size', fontSize, showNull: false));
    String weightDescription;
    if (fontWeight != null) {
      switch (fontWeight) {
        case FontWeight.w100:
          weightDescription = '100';
          break;
        case FontWeight.w200:
          weightDescription = '200';
          break;
        case FontWeight.w300:
          weightDescription = '300';
          break;
        case FontWeight.w400:
          weightDescription = '400';
          break;
        case FontWeight.w500:
          weightDescription = '500';
          break;
        case FontWeight.w600:
          weightDescription = '600';
          break;
        case FontWeight.w700:
          weightDescription = '700';
          break;
        case FontWeight.w800:
          weightDescription = '800';
          break;
        case FontWeight.w900:
          weightDescription = '900';
          break;
      }
    }
    styles.add(
      new DiagnosticsNode.objectProperty(
        'weight',
        fontWeight,
        header: weightDescription,
        showNull: false,
      ),
    );
    styles.add(new DiagnosticsNode.enumProperty('style', fontStyle, showNull: false));
    styles.add(new DiagnosticsNode.doubleProperty('letterSpacing', letterSpacing, suffix: 'x', showNull: false));
    styles.add(new DiagnosticsNode.doubleProperty('wordSpacing', wordSpacing, suffix: 'x', showNull: false));
    styles.add(new DiagnosticsNode.enumProperty('baseline', textBaseline, showNull: false));
    styles.add(new DiagnosticsNode.doubleProperty('height', height, suffix: 'x', showNull: false));
    if (decoration != null || decorationColor != null || decorationStyle != null) {
      final List<String> decorationDescription = <String>[];
      if (decorationStyle != null) {
        decorationDescription.add(describeEnum((decorationStyle)));
      }

      // Hide decorationColor from the default text view as we show it in the
      // terse decoration summary as well.
      styles.add(
        new DiagnosticsNode.colorProperty(
          'decorationColor',
          decorationColor,
          showNull: false,
          hidden: true,
        ),
      );

      if (decorationColor != null) {
        decorationDescription.add('$decorationColor');
      }
      // Note intentionally collide with the name 'decoration' shown bellow.
      // Tools that show hidden properties could choose the first property
      // matching the name to disambiguate.
      styles.add(new DiagnosticsNode.objectProperty('decoration', decoration,
          showNull: false, hidden: true));
      if (decoration != null) {
        decorationDescription.add('$decoration');
      }
      assert(decorationDescription.isNotEmpty);
      styles.add(new DiagnosticsNode.stringProperty('decoration',
          decorationDescription.join(' ')));
    }

    bool styleSpecified = false;
    for (DiagnosticsNode node in styles) {
      if (node.show) {
        styleSpecified = true;
        break;
      }
    }

    properties.add(
      new DiagnosticsNode.boolProperty(
        'inherit', inherit,
        hidden: !styleSpecified && inherit,
      ),
    );

    properties.addAll(styles);

    // TODO(jacobr): add a different <no style specified> message depending on
    // the value of inherited.
    if (!styleSpecified) {
      properties.add(new DiagnosticsNode.message(
          inherit ? '<all styles inherited>' : '<no style specified>'));
    }
  }

}
