// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Wrap test; toStringDeep', () {
    final renderWrap = new RenderWrap();
    expect(renderWrap, hasAGoodToStringDeep);
    expect(
      renderWrap.toStringDeep(),
      equalsIgnoringHashCodes(
        'RenderWrap#00000 NEEDS-LAYOUT NEEDS-PAINT DETACHED\n'
        '   parentData: null\n'
        '   constraints: null\n'
        '   size: MISSING\n'
        '   direction: horizontal\n'
        '   alignment: start\n'
        '   spacing: 0.0\n'
        '   runAlignment: start\n'
        '   runSpacing: 0.0\n'
        '   crossAxisAlignment: 0.0\n'
      ),
    );
  });
}
