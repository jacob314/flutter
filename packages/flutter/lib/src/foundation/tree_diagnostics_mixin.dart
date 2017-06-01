// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

/// Styles for displaying a [DiagnosticsNode] tree.
enum DiagnosticsTreeStyle {
  normal,
  dashed,
  dense,
  box,
  whitespace,
  singleLine,
}

/// Style defining how to rendering a tree of DiagnosticsNodes as text art.
///
/// See [_normalTextTreeStyle] for a typical style using only
/// the common parameters. See [boxTextTreeStyle] for an example of a complex
/// tree style. See [TreeDiagnosticsMixin.toStringDeep] for code
/// applying [_TextTreeStyle] objects to render a tree of [DiagnosticsNode]
/// objects.
///
/// A [_TextTreeStyle] style is expected to be applied as follows:
/// beforeName {name} afterName
/// {header} afterHeaderIfBody beforeProperties lineBreak
/// {property1} memberSeparator lineBreak
/// {property1} memberSeparator lineBreak
/// ...
/// {propertyN} lastProperty lineBreak
/// verticalAndRight horizontal {child1} memberSeparator lineBreak
/// vertical horizontalSpace {child1 content}
/// verticalAndRight horizontal {child2 line one }
/// vertical horizontalSpace {child2 other lines}
/// memberSeparator lineBreak
/// ...
/// {childN} lineBreak afterMembers
///
/// TODO(jacobr): provide a concrete example.
class _TextTreeStyle {
  _TextTreeStyle({
    @required this.prefixLineOne,
    @required this.prefixOtherLines,
    @required this.prefixLastChildLineOne,
    @required this.linkCharacter,
    @required this.prefixOtherLinesRootNode,
    @required this.propertyPrefixIfChildren,
    @required this.propertyPrefixNoChildren,
    this.lineBreak: '\n',
    this.afterName: ':',
    this.afterHeaderIfBody: '',
    this.beforeProperties: '',
    this.afterProperties: '',
    this.propertySeparator: '',
    this.bodyIndent: '',
    this.footer: '',
    this.showChildren: true,
    this.addBlankLineIfNoChildren: true,
    this.isNameOnOwnLine: false,
    this.isBlankLineBetweenPropertiesAndChildren: false,
  }) : childLinkSpace = ' ' * linkCharacter.length;

  /// Prefix to add to the first line to display a child with this style.
  final String prefixLineOne;
  /// Prefix to add to other lines to display a child with this style.
  ///
  /// [prefixOtherLines] should typically be one character shorter than
  /// [prefixLineOne] as
  final String prefixOtherLines;
  /// Prefix to add to the first line to display the last child of a node with
  /// this style.
  final String prefixLastChildLineOne;
  /// Additional prefix to add to other lines of a node if this is the root node
  /// of the tree.
  final String prefixOtherLinesRootNode;
  /// Prefix to add before each property if the node as children.
  final String propertyPrefixIfChildren;
  /// Prefix to add before each property if the node does not have children.
  ///
  /// This string is typically a whitespace string the same length as
  /// [propertyPrefixIfChildren] but can have a different length.
  final String propertyPrefixNoChildren;

  /// Character to use to draw line linking parent to child.
  ///
  /// The first child does not require a line but all subsequent children do
  /// with the line drawn immediately before the left edge of the previous
  /// sibling.
  final String linkCharacter;
  /// Whitespace to draw instead of the childLink character if this node is the
  /// last child of its parent so no link line is required.
  final String childLinkSpace;

  /// Character(s) to use to separate lines.
  ///
  /// Typically leave set at the default value of '\n' but override if
  final String lineBreak;

  /// Text added immediately after the name of the node.
  ///
  /// See [boxTextTreeStyle] for an example of using a value other than ':'
  /// to display a more complex line art style.
  final String afterName;
  /// Text to add immediately after the header of a node with properties or
  /// children.
  final String afterHeaderIfBody;
  /// Optional string to add before the properties of a node.
  ///
  /// Only displayed if the node has properties.
  /// See [singleLineTextTreeStyle] for an example of using this field
  /// to enclose the property list with parenthesis.
  final String beforeProperties;
  /// Optional string to add after the properties of a node.
  ///
  /// See documentation for [beforeProperties].
  final String afterProperties;
  /// Property separator to add between properties.
  /// See [singleLineTextTreeStyle] for an example of using this field
  /// to render properties as a comma separated list.
  final String propertySeparator;
  /// Prefix to add to all lines of the body of the tree node.
  ///
  /// The body is all content in the node other than the name and header.
  final String bodyIndent;
  /// Whether the children of a node should be shown.
  ///
  /// See [singleLineTextTreeStyle] for an example of using this field to hide
  /// all children of a node.
  final bool showChildren;
  /// Whether to add a blank line at the end of the output for a node if it has
  /// no children.
  ///
  /// See [_denseTextTreeStyle] for an example of setting this to false.
  final bool addBlankLineIfNoChildren;
  /// Whether the name should be displayed on the same line as the header.
  final bool isNameOnOwnLine;
  /// Footer to add as its own line at the end of a non-root node.
  ///
  /// See [boxTextTreeStyle] for an example of using footer to draw a box around
  /// the node.  [footer] is indented the same amount as [prefixOtherLines].
  final String footer;
  /// Add a blank line between properties and children if both are present.
  final bool isBlankLineBetweenPropertiesAndChildren;

  /// Whether all text should be added to a single line.
  bool get isSingleLine => lineBreak.isEmpty;
}

/// Default text tree style.
///
/// Example:
/// <root_name>: <root_header>
///  │ <property1>
///  │ <property2>
///  │ ...
///  │ <propertyN>
///  ├─<child_name>: <child_header>
///  │ │ <property1>
///  │ │ <property2>
///  │ │ ...
///  │ │ <propertyN>
///  │ │
///  │ └─<child_name>: <child_header>
///  │     <property1>
///  │     <property2>
///  │     ...
///  │     <propertyN>
///  │
///  └─<child_name>: <child_header>'
///    <property1>
///    <property2>
///    ...
///    <propertyN>
final _TextTreeStyle _normalTextTreeStyle = new _TextTreeStyle(
  prefixLineOne: '├─',
  prefixOtherLines: ' ',
  prefixLastChildLineOne:    '└─',
  linkCharacter: '│',
  propertyPrefixIfChildren: '│ ',
  propertyPrefixNoChildren: '  ',
  prefixOtherLinesRootNode: ' ',
  isBlankLineBetweenPropertiesAndChildren: true,
);

/// Renders the same
/// Example:
/// <root_name>: <root_header>
///  │ <property1>
///  │ <property2>
///  │ ...
///  │ <propertyN>
///  ├─<normal_child_name>: <child_header>
///  ╎ │ <property1>
///  ╎ │ <property2>
///  ╎ │ ...
///  ╎ │ <propertyN>
///  ╎ │
///  ╎ └─<child_name>: <child_header>
///  ╎     <property1>
///  ╎     <property2>
///  ╎     ...
///  ╎     <propertyN>
///  ╎
///  ╎╌<dashed_child_name>: <child_header>
///  ╎ │ <property1>
///  ╎ │ <property2>
///  ╎ │ ...
///  ╎ │ <propertyN>
///  ╎ │
///  ╎ └─<child_name>: <child_header>
///  ╎     <property1>
///  ╎     <property2>
///  ╎     ...
///  ╎     <propertyN>
///  ╎
///  └╌<dashed_child_name>: <child_header>'
///    <property1>
///    <property2>
///    ...
///    <propertyN>
final _TextTreeStyle _dashedTextTreeStyle = new _TextTreeStyle(
  prefixLineOne: '╎╌',
  prefixLastChildLineOne: '└╌',
  prefixOtherLines: ' ',
  linkCharacter: '╎',
  // We intentionally do not dash the line associating properties with the node.
  propertyPrefixIfChildren: '│ ',
  propertyPrefixNoChildren: '  ',
  prefixOtherLinesRootNode: ' ',
  isBlankLineBetweenPropertiesAndChildren: true,
);

/// Dense text tree style that minimizes extra whitespace.
///
/// Example:
/// <root_name>: <root_header>
/// │<property1>
/// │<property2>
/// │...
/// │<propertyN>
/// │
/// ├<child_name>: <child_header>
/// │ <property1>
/// │ <property2>
/// │ ...
/// │ <propertyN>
/// │
/// └<child_name>: <child_header>'
///   <property1>
///   <property2>
///   ...
///   <propertyN>
final _TextTreeStyle _denseTextTreeStyle = new _TextTreeStyle(
  prefixLineOne: '├',
  prefixOtherLines: '',
  prefixLastChildLineOne:    '└',
  linkCharacter: '│',
  propertyPrefixIfChildren: '│',
  propertyPrefixNoChildren: ' ',
  prefixOtherLinesRootNode: '',
  addBlankLineIfNoChildren: false,
  isBlankLineBetweenPropertiesAndChildren: true,
);

/// Draw a full box around nodes.
///
/// Typically this style should only be used to for leaf nodes
/// such as [TextSpan] to draw a clear border around the content of the node.
///
/// Example:
///  <parent_node>
///  ╞═╦══ <name> ═══
///  │ ║  <header>:
///  │ ║    <body>
///  │ ║    ...
///  │ ╚═══════════
///  ╘═╦══ <name> ═══
///    ║  <header>:
///    ║    <body>
///    ║    ...
///    ╚═══════════
final _TextTreeStyle boxTextTreeStyle = new _TextTreeStyle(
  prefixLineOne:          '╞═╦══ ',
  prefixLastChildLineOne: '╘═╦══ ',
  prefixOtherLines:        ' ║ ',
  footer:                  ' ╚═══════════\n',
  linkCharacter: '│',
  // Subtree boundaries are unambiguous due to the box around the node so
  // we omit a property prefix.
  propertyPrefixIfChildren: '',
  propertyPrefixNoChildren: '',
  prefixOtherLinesRootNode: '',
  afterName: ' ═══',
  // Add a colon after the header if the node has a body to make the connection
  // between the header and the body clearer.
  afterHeaderIfBody: ':',
  // Members of the box style are indented an extra two spaces to disambiguate
  // as the header is placed within the box instead of along side the name as
  // is the case for other styles.
  bodyIndent: '  ',
  isNameOnOwnLine: true,
  // No need to add a blank line as the footer makes the boundary of this
  // subtree clear.
  addBlankLineIfNoChildren: false,
  isBlankLineBetweenPropertiesAndChildren: false,
);

/// Whitespace only style where children are consistently indented two spaces.
///
/// Example:
/// <parent_node>
///   <name>: <header>:
///     <properties>
///     <children>
///   <name>: <header>:
///     <properties>
///     <children>
///
/// Use this style for displaying properties with structured values or for
/// displaying children within a [boxTextTreeStyle] as using a style that draws
/// line art would be visually distracting for those cases.
final _TextTreeStyle whitespaceTextTreeStyle = new _TextTreeStyle(
  prefixLineOne: '',
  prefixLastChildLineOne: '',
  prefixOtherLines: '',
  prefixOtherLinesRootNode: '',
  bodyIndent: '  ',
  propertyPrefixIfChildren: '',
  propertyPrefixNoChildren: '',
  linkCharacter: '',
  addBlankLineIfNoChildren: false,
  // Add an extra colon after the header and before the properties to link the
  // properties to the header line.
  afterHeaderIfBody: ':',
);

/// Render a node as a single line omitting children.
///
/// Example:
/// <name>: <header>(<property1>, <property2>, ..., <propertyN>)
final _TextTreeStyle singleLineTextTreeStyle = new _TextTreeStyle(
  prefixLineOne: '',
  prefixOtherLines: '',
  prefixLastChildLineOne: '',
  lineBreak: '',
  propertySeparator: ', ',
  beforeProperties: '(',
  afterProperties: ')',
  addBlankLineIfNoChildren: false,
  showChildren: false,
  propertyPrefixIfChildren: '',
  propertyPrefixNoChildren: '',
  linkCharacter: '',
  prefixOtherLinesRootNode: '',
);

// TODO(jacobr): remove this typedef when the DartSDK used supports the new
// function type syntax.
typedef void FillDiagnostics(List<DiagnosticsNode> out);

/// A class for concatenating string with specified prefixes for the first and
/// subsequent lines.
///
/// Allows for the incremental building of strings using `write*()` methods.
/// The strings are concatenated into a single string with the first line
/// prefixed by [prefixLineOne] and subsequent lines prefixed by
/// [prefixOtherLines].
class _PrefixedStringBuilder {
  _PrefixedStringBuilder(this.prefixLineOne, this.prefixOtherLines);

  /// Prefix to add to the first line.
  String prefixLineOne;
  /// Prefix to add to subsequent lines.
  ///
  /// The prefix can be modified while the string is being built in which case
  /// subsequent lines will be added with the modified prefix.
  String prefixOtherLines;

  final StringBuffer _buffer = new StringBuffer();
  bool _atLineStart = true;
  bool _hasMultipleLines = false;

  /// Whether the string being built already has more than 1 line.
  bool get hasMultipleLines => _hasMultipleLines;

  /// Write text ensuring the specified prefixes for the first and subsequent
  /// lines.
  void write(String s) {
    if (s.isEmpty)
      return;

    if (s == '\n') {
      // Special case to avoid adding trailing whitespace if the caller has not
      // added trailing whitespace.
      if (_buffer.isEmpty) {
        _buffer.write(prefixLineOne.trimRight());
      } else if (_atLineStart) {
        _buffer.write(prefixOtherLines.trimRight());
        _hasMultipleLines = true;
      }
      _buffer.write('\n');
      _atLineStart = true;
      return;
    }

    if (_buffer.isEmpty) {
      _buffer.write(prefixLineOne);
    } else if (_atLineStart) {
      _buffer.write(prefixOtherLines);
      _hasMultipleLines = true;
    }
    bool lineTerminated = false;

    if (s.endsWith('\n')) {
      s = s.substring(0, s.length - 1);
      lineTerminated = true;
    }
    final List<String> parts = s.split('\n');
    _buffer.write(parts[0]);
    for (int i = 1; i < parts.length; ++i) {
      _buffer..write('\n')..write(prefixOtherLines)..write(parts[i]);
    }
    if (lineTerminated) {
      _buffer.write('\n');
    }
    _atLineStart = lineTerminated;
  }

  /// Write text assuming the text already obeys the specified prefixes for the
  /// first and subsequent lines.
  void writeRaw(String s) {
    if (s.isEmpty)
      return;
    _buffer.write(s);
    _atLineStart = s.endsWith('\n');
  }


  /// Write a line assuming the line obeys the specified prefixes. Ensures that
  /// a newline is added if one is not present.
  /// The same as [writeRaw] except a newline is added at the end of [s] if one
  /// is not already present.
  ///
  /// A new line is not added if the input string already contains a newline.
  void writeRawLine(String s) {
    if (s.isEmpty)
      return;
    _buffer.write(s);
    if (!s.endsWith('\n'))
      _buffer.write('\n');
    _atLineStart = true;
  }

  @override
  String toString() => _buffer.toString();
}

/// Defines diagnostics data for an [Object].
///
/// DiagnosticsNode provide high quality multi-line string views via
/// [toStringDeep] and
/// The core data stored in a node is the string [name], string [header]
/// describing the node, lists of [DiagnosticNode] objects describing
/// the properties and children of the node, and associated [object] the node is
/// providing diagnostics for. All other members exist to provide hints for
/// how [toStringDeep] should convert the structured data to user readable text.
abstract class DiagnosticsNode {
  DiagnosticsNode({
    this.name,
    this.header,
    this.style=DiagnosticsTreeStyle.normal,
    bool hidden = false,
    this.showNull = false,
    this.showName = true,
    this.showSeparator = true,
    this.emptyDescription
  }) : _hidden = hidden {
    // A name ending with ':' indicates that the user forgot that the ':' will
    // be automatically added for them when generating descriptions of the
    // property.
    assert(name == null || !name.endsWith(':'));
  }

  factory DiagnosticsNode.stringProperty(
    String name,
    String value,
      {
        bool showNull: true,
        String header,
        bool showName: true,
        bool hidden: false}) {
    return new LeafDiagnosticsValue(
        name: name,
        header: header ?? value,
        object: value,
        showNull: showNull,
        showName: showName,
        hidden: hidden);
  }

  factory DiagnosticsNode.boolProperty(
      String name,
      bool value,
      {String header,
        bool showNull: true,
        bool showName: true,
        bool hidden: false,
        String nullDescription,
        bool showSeparator: true}) {
    if (value == null)
      header = nullDescription;
    return new LeafDiagnosticsValue(
        name: name, header: header ?? value.toString(), object: value, showNull: showNull, hidden: hidden, showName: showName, showSeparator: showSeparator);
  }

  factory DiagnosticsNode.numProperty(String name, num value, {bool showNull=true}) {
    return new LeafDiagnosticsValue(name: name, header: value.toString(), object: value, showNull: showNull);
  }

  factory DiagnosticsNode.withUnit(String name, Object value, {@required String unit}) {
    return new LeafDiagnosticsValue(
      name: name,
      object: value,
      header: '$value ($unit)'
    );
  }

  factory DiagnosticsNode.doubleProperty(String name, double value, {bool showNull=true, int fractionDigits, bool hidden=false, String nullDescription, String suffix}) {
    String description;
    // TODO(jacobr): consider splitting up doubleProperty into separate constructors
    // with subsets of these options. Specifically, header only really ma
    if (value == null) {
      description = nullDescription ?? value.toString();
    } else {
      description = fractionDigits != null ?
         value.toStringAsFixed(fractionDigits) : value.toString();
    }
    if (suffix != null) {
      // TODO(jacobr): store the unit in the leaf diagnostic node to assist
      // debugging clients that have custom renders for various units.
      description = '$description$suffix';
    }
    return new LeafDiagnosticsValue(
      name: name,
      header: description,
      object: value,
      showNull: showNull,
      hidden: hidden,
    );
  }

  factory DiagnosticsNode.describeBoolProperty(String name, bool value, {String trueDescription, String falseDescription, bool showName=true, bool hidden=false}) {
    return new DiagnosticsNode.boolProperty(name, value, header: value ? trueDescription: falseDescription, showName: showName, hidden: hidden);
  }

  factory DiagnosticsNode.enumProperty(String name, Object value, {bool showNull=true, bool hidden=false}) {
    return new LeafDiagnosticsValue(
      name: name,
      header: value != null ? toHyphenedName(describeEnum(value)) : 'null',
      object: value,
      showNull: showNull,
      hidden: hidden,
    );
  }

  factory DiagnosticsNode.intProperty(String name, int value, {bool showNull=true}) {
    return new LeafDiagnosticsValue(name: name, header: value.toString(), object: value, showNull: showNull);
  }

  factory DiagnosticsNode.objectProperty(String name, Object value, {String header, bool hidden=false, bool showNull=true, String nullDescription, bool showName=true, bool showSeparator=true}) {
    if (nullDescription != null && value == null)
      header = nullDescription;

    return new LeafDiagnosticsValue(name: name, header: header ?? value.toString(), object: value, hidden: hidden, showNull: showNull, showName: showName, showSeparator: showSeparator);
  }

  factory DiagnosticsNode.lazyObjectProperty(String name, Object computeValue(), {@required String header, bool hidden=false, bool showNull=true, String nullDescription, bool showName=true}) {
    return new LazyLeafDiagnosticsValue(name: name, header: header, computeValue: computeValue, hidden: hidden, showNull: showNull, showName: showName);
  }

  // These are stubs for adding more detailed diagnostics for these types.
  factory DiagnosticsNode.colorProperty(String name, Color value, {String header, bool hidden=false, bool showNull=true}) {
    return new LeafDiagnosticsValue(name: name, header: header ?? value.toString(), object: value, hidden: hidden, showNull: showNull);
  }

  factory DiagnosticsNode.rectProperty(String name, Rect value, {String header, bool hidden=false, bool showNull=true}) {
    return new LeafDiagnosticsValue(name: name, header: header ?? value.toString(), object: value, hidden: hidden, showNull: showNull);
  }
  
  factory DiagnosticsNode.boxConstraintsProperty(String name, BoxConstraints value, {String header, bool hidden=false, bool showNull=true}) {
    return new LeafDiagnosticsValue(name: name, header: header ?? value.toString(), object: value, hidden: hidden, showNull: showNull);
  }

  factory DiagnosticsNode.conditionalMessage(String propertyName, bool value, String trueMessage) {
    return new LeafDiagnosticsValue(name: propertyName, header: value ? trueMessage : '', object: value, hidden: !value, showName: false);
  }

  factory DiagnosticsNode.transformProperty(String name, Matrix4 value, {bool showNull: true}) {
    return new LeafDiagnosticsValue(name: name, object: value, header: debugDescribeTransform(value).join('\n'), showNull: showNull);
  }

  factory DiagnosticsNode.changeNotifierProperty(String name, ChangeNotifier value, {String header, bool hidden=false, bool showNull=true}) {
    return new LeafDiagnosticsValue(name: name,
        header: header ?? value.toString(),
        object: value,
        hidden: hidden,
        showNull: showNull);
  }

  factory DiagnosticsNode.iterableProperty(String name, Iterable<Object> value, {bool showNull=true, DiagnosticsTreeStyle style=DiagnosticsTreeStyle.singleLine}) {
    return new LeafDiagnosticsValue(
        name: name,
        object: value,
        header: value?.join(', '),
        showNull: showNull,
        style: style,
    );
  }

  /// Create a property for a double valued property that could throw an
  /// exception if accessed.
  factory DiagnosticsNode.unsafeDoubleProperty(
      String name, double computeValue(), {int fractionDigits}) {
    try {
      return new DiagnosticsNode.doubleProperty(name, computeValue(), fractionDigits: fractionDigits);
    } catch (e) {
      // TODO(jacobr): track the exception thrown as part of the Diagnostics node.
      return new DiagnosticsNode.doubleProperty(
          name,
          null,
          fractionDigits: fractionDigits,
          nullDescription: 'EXCEPTION (${e.runtimeType})');
    }
  }


  /// Diagnostics node that doesn't correspond to any concrete property name.
  factory DiagnosticsNode.message(
      String message,
      {DiagnosticsTreeStyle style=DiagnosticsTreeStyle.singleLine}) {
    return new LeafDiagnosticsValue(name: '', header: message, style: style);
  }

  factory DiagnosticsNode.lazy({
    String name,
    Object object,
    String header,
    FillDiagnostics fillProperties,
    FillDiagnostics fillChildren,
    String emptyDescription,
    DiagnosticsTreeStyle style=DiagnosticsTreeStyle.normal}) {
    return new _LazyDiagnosticsNode(name: name,
        object: object,
        header: header,
        fillProperties: fillProperties,
        fillChildren: fillChildren,
        style: style,
        emptyDescription: emptyDescription);
  }

  final String name;
  final String header;
  final bool showNull;
  final bool _hidden;
  final bool showSeparator;

  bool get hidden {
    if (showNull || _hidden)
      return _hidden;
    try {
      return object == null;
    } catch (e) {
      return false;
    }
  }

  final bool showName;
  /// Description to show if a node has no other content.
  final String emptyDescription;

  /// Dart object this is diagnostics data for.
  Object get object;

  /// Returns a new [DiagnosticNode] with the new [value] if this node is
  /// mutable.
  DiagnosticsNode setValue(Object value);
  bool get isReadOnly;
  bool get show => !hidden && (object != null || showNull);

  final DiagnosticsTreeStyle style;

  List<DiagnosticsNode> getProperties();
  List<DiagnosticsNode> getChildren();

  String get _separator => showSeparator ? ':' : '';

  @override
  String toString() {
    if (style == DiagnosticsTreeStyle.singleLine)
      return toStringDeep();

    if (name == null || name.isEmpty || showName == false)
      return header;
    return header.contains('\n') ? '$name$_separator\n$header' : '$name$_separator $header';
  }

  _TextTreeStyle get _textTreeStyle {
    switch (style) {
      case DiagnosticsTreeStyle.dense:
        return _denseTextTreeStyle;
      case DiagnosticsTreeStyle.normal:
        return _normalTextTreeStyle;
      case DiagnosticsTreeStyle.dashed:
        return _dashedTextTreeStyle;
      case DiagnosticsTreeStyle.whitespace:
        return whitespaceTextTreeStyle;
      case DiagnosticsTreeStyle.box:
        return boxTextTreeStyle;
      case DiagnosticsTreeStyle.singleLine:
        return singleLineTextTreeStyle;
      default:
        return _normalTextTreeStyle;
    }
  }

  _TextTreeStyle _childTextStyle(DiagnosticsNode child, _TextTreeStyle textStyle) {
    return (child != null && child.style != DiagnosticsTreeStyle.singleLine) ?
       child._textTreeStyle : textStyle;
  }

  String toStringDeep([String prefixLineOne = '', String prefixOtherLines = '']) {
    prefixOtherLines ??= prefixLineOne;
    final List<DiagnosticsNode> children = getChildren();
    final _TextTreeStyle textStyle = _textTreeStyle;
    if (prefixOtherLines.isEmpty)
      prefixOtherLines += textStyle.prefixOtherLinesRootNode;

    final _PrefixedStringBuilder builder =  new _PrefixedStringBuilder(
        prefixLineOne, prefixOtherLines);
    if (header == null || header.isEmpty) {
      if (showName && name != null)
        builder.write(name);
    } else {
      if (name != null && name.isNotEmpty && showName) {
        builder.write(name);
        if (showSeparator)
          builder.write(textStyle.afterName);

        builder.write(textStyle.isNameOnOwnLine || header.contains('\n') ?
            '\n' : ' ');
      }
      builder.prefixOtherLines += children.isEmpty ?
      textStyle.propertyPrefixNoChildren : textStyle.propertyPrefixIfChildren;
      builder.write(header);
    }

    final List<DiagnosticsNode> properties = getProperties().where(
            (DiagnosticsNode n) => !n.hidden).toList();
    if (properties.isNotEmpty || children.isNotEmpty || emptyDescription != null)
      builder.write(textStyle.afterHeaderIfBody);

    if (properties.isNotEmpty)
      builder.write(textStyle.beforeProperties);
    builder.write(textStyle.lineBreak);

    // Indent properties.
    builder.prefixOtherLines += textStyle.bodyIndent;

    if (emptyDescription != null && properties.isEmpty && children.isEmpty && prefixLineOne.isNotEmpty) {
      builder..write(emptyDescription)..write(textStyle.lineBreak);
    }

    for (int i = 0; i < properties.length; ++i) {
      final DiagnosticsNode property = properties[i];
      if (i > 0)
        builder.write(textStyle.propertySeparator);
      final int kWrapWidth = 65;
      if (property.style == DiagnosticsTreeStyle.whitespace) {
        builder.writeRaw(property.toStringDeep(builder.prefixOtherLines,
            builder.prefixOtherLines));
        continue;
      }
      assert (property.style == null ||
          property.style == DiagnosticsTreeStyle.singleLine);
      final String message =
          property == null ? '<null>' : property.toString();
      if (textStyle.isSingleLine || message.length < kWrapWidth) {
        builder.write(message);
      } else {
        // TODO(jacobr): make wrapIndent configurable.
        final List<String> lines = message.split('\n');
        for (int j = 0; j < lines.length; ++j) {
          final String line = lines[j];
          if (j > 0)
            builder.write(textStyle.lineBreak);
          // debugWordWrap doesn't handle line breaks so we have to call it on
          // each line.
          builder
            ..write(debugWordWrap(line, kWrapWidth, wrapIndent: '  ')
                .join('\n'));
        }
      }
      builder.write(textStyle.lineBreak);
    }
    if (properties.isNotEmpty)
      builder.write(textStyle.afterProperties);

    final String prefixChildren = '$prefixOtherLines${textStyle.bodyIndent}';

    if (children.isEmpty && textStyle.addBlankLineIfNoChildren && builder.hasMultipleLines) {
      final String prefix = prefixChildren.trimRight();
      if (prefix.isNotEmpty)
        builder.writeRaw('$prefix${textStyle.lineBreak}');
    }

    if (children.isNotEmpty && textStyle.showChildren) {
      if (textStyle.isBlankLineBetweenPropertiesAndChildren && properties.isNotEmpty &&
          children.first._textTreeStyle.isBlankLineBetweenPropertiesAndChildren) {
        builder.write(textStyle.lineBreak);
      }

      for (int i = 0; i < children.length; i++) {
        final DiagnosticsNode child = children[i];

        // XXX explain why we have to special case single line children.
        final _TextTreeStyle childStyle = _childTextStyle(child, textStyle);
        if (i == children.length - 1) {
          final String lastChildPrefixLineOne =
              '$prefixChildren${childStyle.prefixLastChildLineOne}';
          if (child == null) {
            builder.writeRawLine('$lastChildPrefixLineOne<null>');
            continue;
          }
          builder.writeRawLine(child.toStringDeep(
              lastChildPrefixLineOne,
              '$prefixChildren${childStyle.childLinkSpace}${childStyle.prefixOtherLines}'));
          if (childStyle.footer.isNotEmpty)
            builder.writeRaw('$prefixChildren${childStyle.childLinkSpace}${childStyle.footer}');

        } else {
          final _TextTreeStyle nextChildStyle =
              _childTextStyle(children[i + 1], textStyle);

          final String childPrefixLineOne = '$prefixChildren${childStyle.prefixLineOne}';
          final String childPrefixOtherLines = '$prefixChildren${nextChildStyle.linkCharacter}${childStyle.prefixOtherLines}';

          if (child == null) {
            builder.writeRawLine('$childPrefixLineOne<null>');
            continue;
          }
          builder.writeRawLine(child.toStringDeep(
              childPrefixLineOne, childPrefixOtherLines));
          if (childStyle.footer.isNotEmpty)
            builder.writeRaw('$prefixChildren${nextChildStyle.linkCharacter}${childStyle.footer}');
        }
      }
    }
    return builder.toString();
  }
}

class LeafDiagnosticsValue extends DiagnosticsNode {
  LeafDiagnosticsValue({
      String name,
      String header,
      this.object,
      bool hidden=false,
      bool showNull=true,
      bool showName=true,
      bool showSeparator=true,
      DiagnosticsTreeStyle style=DiagnosticsTreeStyle.singleLine}) :
        super(name: name, header: header != null ? header : object.toString(), style: style, hidden: hidden, showNull: showNull, showName: showName, showSeparator: showSeparator);

  @override
  final Object object;

  @override
  bool get isReadOnly => true;

  @override
  LeafDiagnosticsValue setValue(Object value) {
    throw new FlutterError('Cannot set read only property');
  }

  @override
  List<DiagnosticsNode> getProperties() => <DiagnosticsNode>[];

  @override
  List<DiagnosticsNode> getChildren() => <DiagnosticsNode>[];
}

typedef Object _ComputeValue();

class LazyLeafDiagnosticsValue extends DiagnosticsNode {
  LazyLeafDiagnosticsValue({
    String name,
    String header,
    _ComputeValue computeValue,
    bool hidden=false,
    bool showNull=true,
    bool showName=true,
    DiagnosticsTreeStyle style = DiagnosticsTreeStyle.singleLine}) :
        _computeValue = computeValue,
        super(name: name, header: header, style: style, hidden: hidden, showNull: showNull, showName: showName);

  @override
  Object get object => _computeValue();

  _ComputeValue _computeValue;

  @override
  bool get isReadOnly => true;

  @override
  LeafDiagnosticsValue setValue(Object value) {
    throw new FlutterError('Cannot set read only property');
  }

  @override
  List<DiagnosticsNode> getProperties() => <DiagnosticsNode>[];

  @override
  List<DiagnosticsNode> getChildren() => <DiagnosticsNode>[];
}

class _LazyDiagnosticsNode extends DiagnosticsNode {
  @override
  final Object object;
  final FillDiagnostics _fillChildren;
  final FillDiagnostics _fillProperties;

  _LazyDiagnosticsNode({String name, String header, this.object, FillDiagnostics fillChildren,
    FillDiagnostics fillProperties,
    String emptyDescription,
    DiagnosticsTreeStyle style=DiagnosticsTreeStyle.normal}) :
        _fillChildren = fillChildren,
        _fillProperties = fillProperties,
        super(name: name, header: header != null ? header : object.toString(), emptyDescription: emptyDescription, style: style);

  @override
  bool get isReadOnly => true;

  @override
  LeafDiagnosticsValue setValue(Object value) {
    throw new FlutterError('Cannot set read only value');
  }

  @override
  List<DiagnosticsNode> getProperties() {
    final List<DiagnosticsNode> properties = <DiagnosticsNode>[];
    if (_fillProperties != null)
      _fillProperties(properties);
    return properties;
  }

  @override
  List<DiagnosticsNode> getChildren() {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[];
    if (_fillChildren != null)
      _fillChildren(children);
    return children;
  }
}

class TreeDiagnosticsMixinNode extends DiagnosticsNode {
  @override
  final TreeDiagnosticsMixin object;

  TreeDiagnosticsMixinNode(
      {String name, String header, this.object, DiagnosticsTreeStyle style})
      :
        super(name: name,
          header: header,
          style: style);

  @override
  DiagnosticsNode setValue(Object value) {
    throw new FlutterError('Cannot set read only property');
  }

  @override
  bool get isReadOnly => true;

  @override
  List<DiagnosticsNode> getProperties() {
    final List<DiagnosticsNode> description = <DiagnosticsNode>[];
    if (object != null)
      object.debugFillProperties(description);
    return description;
  }

  @override
  List<DiagnosticsNode> getChildren() {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[];
    if (object != null)
      object.debugFillChildren(children);
    return children;
  }
}
abstract class TreeDiagnostics {
  String toStringDeep([String prefixLineOne = '', String prefixOtherLines = '']);
  DiagnosticsNode toDiagnosticsNode({ String name, DiagnosticsTreeStyle style });
}

/// Returns a 5 character long hexadecimal string generated from
/// Object.hashCode's 20 least-significant bits.
String shortHash(Object object) {
  return object.hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0');
}

/// Returns a summary of the runtime type and hash code of `object`.
String describeIdentity(Object object) =>
    '${object.runtimeType}#${shortHash(object)}';

// This method exists as a workaround for https://github.com/dart-lang/sdk/issues/30021
/// Returns a short description of an enum value.
///
/// Strips off the enum class name from the `enumEntry.toString()`.
///
/// For example:
///
/// ```dart
/// enum Day {
///   monday, tuesday, wednesday, thursday, friday, saturday, sunday
/// }
///
/// main() {
///   assert(Day.monday.toString() == 'Day.monday');
///   assert(describeEnum(Day.monday) == 'monday');
/// }
/// ```
String describeEnum(Object enumEntry) {
  final String description = enumEntry.toString();
  final int indexOfDot = description.indexOf('.');
  assert(indexOfDot != -1 && indexOfDot < description.length - 1);
  return description.substring(indexOfDot + 1);
}

/// Returns a lower case hyphen separated version of a camel case name.
///
/// For example:
///
/// ```dart
///
/// main() {
///   assert(toHyphenedName('deferToChild') == 'defer-to-child');
///   assert(toHyphenedName('Monday') == 'monday');
///   assert(toHyphenedName('monday') == 'monday');
/// }
/// ```
String toHyphenedName(String word) {
  final String lowerWord = word.toLowerCase();
  if (word == lowerWord)
    return word;

  var sb = new StringBuffer();
  for (int i = 0; i < word.length; i++) {
    var lower = lowerWord[i];
    if (word[i] != lower && i > 0)
      sb.write('-');
    sb.write(lower);
  }
  return sb.toString();
}

/// A mixin that helps dump string representations of trees.
abstract class TreeDiagnosticsMixin implements TreeDiagnostics {
  // This class is intended to be used as a mixin, and should not be
  // extended directly.
  factory TreeDiagnosticsMixin._() => null;

  /// A brief description of this object, usually just the [runtimeType] and the
  /// [hashCode].
  ///
  /// See also:
  ///
  ///  * [toStringShallow], for a detailed description of the object.
  ///  * [toStringDeep], for a description of the subtree rooted at this object.
  @override
  String toString() => describeIdentity(this);

  /// Returns a one-line detailed description of the object.
  /// This description is often somewhat long.
  ///
  /// This includes the same information given by [toStringDeep], but does not
  /// recurse to any children.
  ///
  /// The [toStringShallow] method can take an argument, which is the string to
  /// place between each part obtained from [debugFillProperties]. Passing a
  /// string such as `'\n '` will result in a multiline string that indents the
  /// properties of the object below its name (as per [toString]).
  ///
  /// See also:
  ///
  ///  * [toString], for a brief description of the object.
  ///  * [toStringDeep], for a description of the subtree rooted at this object.
  String toStringShallow([String joiner = '; ']) {
    final StringBuffer result = new StringBuffer();
    result.write(toString());
    result.write(joiner);
    final List<DiagnosticsNode> description = <DiagnosticsNode>[];
    debugFillProperties(description);
    result.write(
      description
        .where((DiagnosticsNode n) => n.show)
        .join(joiner));
    return result.toString();
  }

  /// Returns a string representation of this node and its descendants.
  @override
  String toStringDeep([String prefixLineOne = '', String prefixOtherLines = '']) {
    return toDiagnosticsNode().toStringDeep(prefixLineOne, prefixOtherLines);
  }

  @override
  DiagnosticsNode toDiagnosticsNode({String name, DiagnosticsTreeStyle style}) {
    return new TreeDiagnosticsMixinNode(
        name: name, object: this, header: toString(), style: style);
  }

  /// Add additional information to the given description for use by
  /// [toStringDeep], [toDiagnosticsNode] and [toStringShallow].
  @protected
  @mustCallSuper
  void debugFillProperties(List<DiagnosticsNode> properties) { }

  /// Returns a description of this node's children.
  ///
  /// Used by [toStringDeep] and [toDiagnosticsNode].
  @protected
  void debugFillChildren(List<DiagnosticsNode> children) { }
}