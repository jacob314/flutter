// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class TestTree extends Object with TreeDiagnosticsMixin {
  TestTree({
    this.name,
    this.style,
    this.children: const <TestTree>[],
    this.properties: const <DiagnosticsNode>[],
  });

  final String name;
  final List<TestTree> children;
  final List<DiagnosticsNode> properties;
  final DiagnosticsTreeStyle style;

  @override
  void debugFillChildren(List<DiagnosticsNode> children) {
    for (TestTree child in this.children)
      children.add(child.toDiagnosticsNode(
          name: 'child ${child.name}', style: child.style));
  }

  @override
  void debugFillProperties(List<DiagnosticsNode> properties) {
    properties.addAll(this.properties);
  }
}

enum ExampleEnum {
  hello,
  world,
  deferToChild,
}

void main() {
  test('TreeDiagnosticsMixin control test', () async {
    void goldenStyleTest(String description,
        {DiagnosticsTreeStyle style,
        DiagnosticsTreeStyle lastChildStyle,
        String golden = ''}) {
      final TestTree tree = new TestTree(children: <TestTree>[
        new TestTree(name: 'node A', style: style),
        new TestTree(
          name: 'node B',
          children: <TestTree>[
            new TestTree(name: 'node B1', style: style),
            new TestTree(name: 'node B2', style: style),
            new TestTree(name: 'node B3', style: lastChildStyle ?? style),
          ],
          style: style,
        ),
        new TestTree(name: 'node C', style: lastChildStyle ?? style),
      ], style: lastChildStyle);

      expect(tree, hasAGoodToStringDeep);
      expect(tree.toDiagnosticsNode(style: style).toStringDeep(),
          equalsIgnoringHashCodes(golden),
          reason: description);
    }

    goldenStyleTest(
      'dense',
      style: DiagnosticsTreeStyle.dense,
      golden:
      'TestTree#00000\n'
      '├child node A: TestTree#00000\n'
      '├child node B: TestTree#00000\n'
      '│├child node B1: TestTree#00000\n'
      '│├child node B2: TestTree#00000\n'
      '│└child node B3: TestTree#00000\n'
      '└child node C: TestTree#00000\n',
    );

    goldenStyleTest(
        'standard',
        style: DiagnosticsTreeStyle.normal,
        golden:
        'TestTree#00000\n'
            ' ├─child node A: TestTree#00000\n'
            ' ├─child node B: TestTree#00000\n'
            ' │ ├─child node B1: TestTree#00000\n'
            ' │ ├─child node B2: TestTree#00000\n'
            ' │ └─child node B3: TestTree#00000\n'
            ' └─child node C: TestTree#00000\n',
    );

    goldenStyleTest(
        'dashed',
        style: DiagnosticsTreeStyle.dashed,
        golden:
        'TestTree#00000\n'
        ' ╎╌child node A: TestTree#00000\n'
        ' ╎╌child node B: TestTree#00000\n'
        ' ╎ ╎╌child node B1: TestTree#00000\n'
        ' ╎ ╎╌child node B2: TestTree#00000\n'
        ' ╎ └╌child node B3: TestTree#00000\n'
        ' └╌child node C: TestTree#00000\n',
    );

    goldenStyleTest(
        'box leaf children',
        style: DiagnosticsTreeStyle.normal,
        lastChildStyle: DiagnosticsTreeStyle.box,
        golden:
        'TestTree#00000\n'
        ' ├─child node A: TestTree#00000\n'
        ' ├─child node B: TestTree#00000\n'
        ' │ ├─child node B1: TestTree#00000\n'
        ' │ ├─child node B2: TestTree#00000\n'
        ' │ ╘═╦══ child node B3 ═══\n'
        ' │   ║ TestTree#00000\n'
        ' │   ╚═══════════\n'
        ' ╘═╦══ child node C ═══\n'
        '   ║ TestTree#00000\n'
        '   ╚═══════════\n',
    );

    // You would never really want to make everything a box child like this
    // but you can and still get a readable tree.
    // Box styling is better restricted to leaf nodes.
    // Note that the joint between single and double lines here is a bit clunky
    // but we could correct that if there is any real use for this style.
    goldenStyleTest(
      'box',
      style: DiagnosticsTreeStyle.box,
      golden:
      'TestTree#00000:\n'
      '  ╞═╦══ child node A ═══\n'
      '  │ ║ TestTree#00000\n'
      '  │ ╚═══════════\n'
      '  ╞═╦══ child node B ═══\n'
      '  │ ║ TestTree#00000:\n'
      '  │ ║   ╞═╦══ child node B1 ═══\n'
      '  │ ║   │ ║ TestTree#00000\n'
      '  │ ║   │ ╚═══════════\n'
      '  │ ║   ╞═╦══ child node B2 ═══\n'
      '  │ ║   │ ║ TestTree#00000\n'
      '  │ ║   │ ╚═══════════\n'
      '  │ ║   ╘═╦══ child node B3 ═══\n'
      '  │ ║     ║ TestTree#00000\n'
      '  │ ║     ╚═══════════\n'
      '  │ ╚═══════════\n'
      '  ╘═╦══ child node C ═══\n'
      '    ║ TestTree#00000\n'
      '    ╚═══════════\n',
    );

    goldenStyleTest(
        'whitespace',
        style: DiagnosticsTreeStyle.whitespace,
        golden:
        'TestTree#00000:\n'
        '  child node A: TestTree#00000\n'
        '  child node B: TestTree#00000:\n'
        '    child node B1: TestTree#00000\n'
        '    child node B2: TestTree#00000\n'
        '    child node B3: TestTree#00000\n'
        '  child node C: TestTree#00000\n',
    );

    // Single line mode does not display children.
    goldenStyleTest(
        'single line',
        style: DiagnosticsTreeStyle.singleLine,
        golden: 'TestTree#00000');
  });

  test('TreeDiagnosticsMixin tree with properties test', () async {
    void goldenStyleTest(String description,
        {DiagnosticsTreeStyle style,
        DiagnosticsTreeStyle lastChildStyle,
        String golden = ''}) {
      final TestTree tree = new TestTree(
        properties: <DiagnosticsNode>[
          new DiagnosticsNode.stringProperty('stringProperty1', 'value1'),
          new DiagnosticsNode.doubleProperty('doubleProperty1', 42.5),
          new DiagnosticsNode.doubleProperty('roundedProperty', 1.0 / 3.0,
              fractionDigits: 2),
          new DiagnosticsNode.stringProperty('DO_NOT_SHOW', 'DO_NOT_SHOW',
              hidden: true),
          new DiagnosticsNode.objectProperty('DO_NOT_SHOW_NULL', null,
              showNull: false),
          new DiagnosticsNode.objectProperty('nullProperty', null,
              showNull: true),
          new DiagnosticsNode.stringProperty('node_type', '<root node>',
              showName: false),
        ],
        children: <TestTree>[
          new TestTree(name: 'node A', style: style),
          new TestTree(
            name: 'node B',
            properties: <DiagnosticsNode>[
              new DiagnosticsNode.stringProperty('p1', 'v1'),
              new DiagnosticsNode.stringProperty('p2', 'v2'),
            ],
            children: <TestTree>[
              new TestTree(name: 'node B1', style: style),
              new TestTree(
                name: 'node B2',
                properties: <DiagnosticsNode>[
                  new DiagnosticsNode.stringProperty('property1', 'value1'),
                ],
                style: style,
              ),
              new TestTree(
                name: 'node B3',
                properties: <DiagnosticsNode>[
                  new DiagnosticsNode.stringProperty('node_type', '<leaf node>',
                      showName: false),
                  new DiagnosticsNode.intProperty('foo', 42),
                ],
                style: lastChildStyle ?? style,
              ),
            ],
            style: style,
          ),
          new TestTree(
            name: 'node C',
            properties: <DiagnosticsNode>[
              new DiagnosticsNode.stringProperty('foo', 'multi\nline\nvalue!'),
            ],
            style: lastChildStyle ?? style,
          ),
        ],
        style: lastChildStyle,
      );

      // Change the expectation line when the tree generation code in this test is fixed.
      expect(tree, hasAGoodToStringDeep);
      expect(tree.toDiagnosticsNode(style: style).toStringDeep(),
          equalsIgnoringHashCodes(golden),
          reason: description);
    }

    goldenStyleTest(
      'standard',
      style: DiagnosticsTreeStyle.normal,
      golden:
      'TestTree#00000\n'
      ' │ stringProperty1: value1\n'
      ' │ doubleProperty1: 42.5\n'
      ' │ roundedProperty: 0.33\n'
      ' │ nullProperty: null\n'
      ' │ <root node>\n'
      ' │\n'
      ' ├─child node A: TestTree#00000\n'
      ' ├─child node B: TestTree#00000\n'
      ' │ │ p1: v1\n'
      ' │ │ p2: v2\n'
      ' │ │\n'
      ' │ ├─child node B1: TestTree#00000\n'
      ' │ ├─child node B2: TestTree#00000\n'
      ' │ │   property1: value1\n'
      ' │ │\n'
      ' │ └─child node B3: TestTree#00000\n'
      ' │     <leaf node>\n'
      ' │     foo: 42\n'
      ' │\n'
      ' └─child node C: TestTree#00000\n'
      '     foo:\n'
      '     multi\n'
      '     line\n'
      '     value!\n'
    );

    goldenStyleTest(
      'dense',
      style: DiagnosticsTreeStyle.dense,
      golden:
      'TestTree#00000\n'
      '│stringProperty1: value1\n'
      '│doubleProperty1: 42.5\n'
      '│roundedProperty: 0.33\n'
      '│nullProperty: null\n'
      '│<root node>\n'
      '│\n'
      '├child node A: TestTree#00000\n'
      '├child node B: TestTree#00000\n'
      '││p1: v1\n'
      '││p2: v2\n'
      '││\n'
      '│├child node B1: TestTree#00000\n'
      '│├child node B2: TestTree#00000\n'
      '││ property1: value1\n'
      '│└child node B3: TestTree#00000\n'
      '│  <leaf node>\n'
      '│  foo: 42\n'
      '└child node C: TestTree#00000\n'
      '  foo:\n'
      '  multi\n'
      '  line\n'
      '  value!\n'
    );

    goldenStyleTest(
      'dashed',
      style: DiagnosticsTreeStyle.dashed,
      golden:
      'TestTree#00000\n'
      ' │ stringProperty1: value1\n'
      ' │ doubleProperty1: 42.5\n'
      ' │ roundedProperty: 0.33\n'
      ' │ nullProperty: null\n'
      ' │ <root node>\n'
      ' │\n'
      ' ╎╌child node A: TestTree#00000\n'
      ' ╎╌child node B: TestTree#00000\n'
      ' ╎ │ p1: v1\n'
      ' ╎ │ p2: v2\n'
      ' ╎ │\n'
      ' ╎ ╎╌child node B1: TestTree#00000\n'
      ' ╎ ╎╌child node B2: TestTree#00000\n'
      ' ╎ ╎   property1: value1\n'
      ' ╎ ╎\n'
      ' ╎ └╌child node B3: TestTree#00000\n'
      ' ╎     <leaf node>\n'
      ' ╎     foo: 42\n'
      ' ╎\n'
      ' └╌child node C: TestTree#00000\n'
      '     foo:\n'
      '     multi\n'
      '     line\n'
      '     value!\n'
    );

    goldenStyleTest(
      'box leaf children',
      style: DiagnosticsTreeStyle.normal,
      lastChildStyle: DiagnosticsTreeStyle.box,
      golden:
      'TestTree#00000\n'
      ' │ stringProperty1: value1\n'
      ' │ doubleProperty1: 42.5\n'
      ' │ roundedProperty: 0.33\n'
      ' │ nullProperty: null\n'
      ' │ <root node>\n'
      ' │\n'
      ' ├─child node A: TestTree#00000\n'
      ' ├─child node B: TestTree#00000\n'
      ' │ │ p1: v1\n'
      ' │ │ p2: v2\n'
      ' │ │\n'
      ' │ ├─child node B1: TestTree#00000\n'
      ' │ ├─child node B2: TestTree#00000\n'
      ' │ │   property1: value1\n'
      ' │ │\n'
      ' │ ╘═╦══ child node B3 ═══\n'
      ' │   ║ TestTree#00000:\n'
      ' │   ║   <leaf node>\n'
      ' │   ║   foo: 42\n'
      ' │   ╚═══════════\n'
      ' ╘═╦══ child node C ═══\n'
      '   ║ TestTree#00000:\n'
      '   ║   foo:\n'
      '   ║   multi\n'
      '   ║   line\n'
      '   ║   value!\n'
      '   ╚═══════════\n'
    );

    // You would never really want to make everything a box child like this
    // but you can and still get a readable tree.
    // Box styling is better restricted to leaf nodes.
    // Note that the joint between single and double lines here is a bit clunky
    // but we could correct that if there is any real use for this style.
    goldenStyleTest(
      'box',
      style: DiagnosticsTreeStyle.box,
      golden:
      'TestTree#00000:\n'
      '  stringProperty1: value1\n'
      '  doubleProperty1: 42.5\n'
      '  roundedProperty: 0.33\n'
      '  nullProperty: null\n'
      '  <root node>\n'
      '  ╞═╦══ child node A ═══\n'
      '  │ ║ TestTree#00000\n'
      '  │ ╚═══════════\n'
      '  ╞═╦══ child node B ═══\n'
      '  │ ║ TestTree#00000:\n'
      '  │ ║   p1: v1\n'
      '  │ ║   p2: v2\n'
      '  │ ║   ╞═╦══ child node B1 ═══\n'
      '  │ ║   │ ║ TestTree#00000\n'
      '  │ ║   │ ╚═══════════\n'
      '  │ ║   ╞═╦══ child node B2 ═══\n'
      '  │ ║   │ ║ TestTree#00000:\n'
      '  │ ║   │ ║   property1: value1\n'
      '  │ ║   │ ╚═══════════\n'
      '  │ ║   ╘═╦══ child node B3 ═══\n'
      '  │ ║     ║ TestTree#00000:\n'
      '  │ ║     ║   <leaf node>\n'
      '  │ ║     ║   foo: 42\n'
      '  │ ║     ╚═══════════\n'
      '  │ ╚═══════════\n'
      '  ╘═╦══ child node C ═══\n'
      '    ║ TestTree#00000:\n'
      '    ║   foo:\n'
      '    ║   multi\n'
      '    ║   line\n'
      '    ║   value!\n'
      '    ╚═══════════\n'
    );

    goldenStyleTest(
      'whitespace',
      style: DiagnosticsTreeStyle.whitespace,
      golden:
        'TestTree#00000:\n'
        '  stringProperty1: value1\n'
        '  doubleProperty1: 42.5\n'
        '  roundedProperty: 0.33\n'
        '  nullProperty: null\n'
        '  <root node>\n'
        '  child node A: TestTree#00000\n'
        '  child node B: TestTree#00000:\n'
        '    p1: v1\n'
        '    p2: v2\n'
        '    child node B1: TestTree#00000\n'
        '    child node B2: TestTree#00000:\n'
        '      property1: value1\n'
        '    child node B3: TestTree#00000:\n'
        '      <leaf node>\n'
        '      foo: 42\n'
        '  child node C: TestTree#00000:\n'
        '    foo:\n'
        '    multi\n'
        '    line\n'
        '    value!\n'
    );

    // Single line mode does not display children.
    goldenStyleTest(
        'single line',
        style: DiagnosticsTreeStyle.singleLine,
        golden: 'TestTree#00000(stringProperty1: value1, doubleProperty1: 42.5, roundedProperty: 0.33, nullProperty: null, <root node>)');

    // There isn't anything interesting for this case as the children look the
    // same with and without children. TODO(jacobr): this is an ugly test case.
    // only difference is odd not clearly desirable density of B3 being right
    // next to node C.
    goldenStyleTest(
        'single line last child',
        style: DiagnosticsTreeStyle.normal,
        lastChildStyle: DiagnosticsTreeStyle.singleLine,
        golden:
        'TestTree#00000\n'
        ' │ stringProperty1: value1\n'
        ' │ doubleProperty1: 42.5\n'
        ' │ roundedProperty: 0.33\n'
        ' │ nullProperty: null\n'
        ' │ <root node>\n'
        ' │\n'
        ' ├─child node A: TestTree#00000\n'
        ' ├─child node B: TestTree#00000\n'
        ' │ │ p1: v1\n'
        ' │ │ p2: v2\n'
        ' │ │\n'
        ' │ ├─child node B1: TestTree#00000\n'
        ' │ ├─child node B2: TestTree#00000\n'
        ' │ │   property1: value1\n'
        ' │ │\n'
        ' │ └─child node B3: TestTree#00000(<leaf node>, foo: 42)\n'
        ' └─child node C: TestTree#00000(foo:\n'
        '   multi\n'
        '   line\n'
        '   value!)\n'
    );
  });

  test('describeEnum test', () {
    expect(describeEnum(ExampleEnum.hello), equals('hello'));
    expect(describeEnum(ExampleEnum.world), equals('world'));
    expect(describeEnum(ExampleEnum.deferToChild), equals('deferToChild'));
  });

  test('toHyphenedName test', () {
    expect(toHyphenedName(''), equals(''));
    expect(toHyphenedName('hello'), equals('hello'));
    expect(toHyphenedName('Hello'), equals('hello'));
    expect(toHyphenedName('HELLO'), equals('h-e-l-l-o'));
    expect(toHyphenedName('deferToChild'), equals('defer-to-child'));
    expect(toHyphenedName('DeferToChild'), equals('defer-to-child'));
    expect(toHyphenedName('helloWorld'), equals('hello-world'));
  });

}
