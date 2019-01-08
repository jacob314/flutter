// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import '../flutter_test_alternative.dart';

import 'capture_output.dart';

void main() {
  test('debugPrintStack', () {
    final List<String> log = captureOutput(() {
      debugPrintStack(label: 'Example label', maxFrames: 7);
    });
    expect(log[0], contains('Example label'));
    expect(log[1], contains('debugPrintStack'));
  });

  test('debugPrintStack', () {
    final List<String> log = captureOutput(() {
      final FlutterErrorDetails details = FlutterErrorDetails(
        exception: 'Example exception',
        stack: StackTrace.current,
        library: 'Example library',
        contextName: 'Example context',
        diagnosticsCollector: () => <DiagnosticsNode>[
          descriptionMessage('Example information'),
        ],
      );

      FlutterError.dumpErrorToConsole(details);
    });

    expect(log[0], contains('EXAMPLE LIBRARY'));
    expect(log[1], contains('Example context'));
    expect(log[2], contains('Example exception'));

    final String joined = log.join('\n');

    expect(joined, contains('captureOutput'));
    expect(joined, contains('\nExample information\n'));
  });

  test('FlutterErrorDetails.toString', () {
    expect(
      FlutterErrorDetails(
        exception: 'MESSAGE',
        library: 'LIBRARY',
        contextName: 'CONTEXTING',
        diagnosticsCollector: () => <DiagnosticsNode>[
          descriptionMessage('INFO'),
        ],
      ).toString(),
      'Error caught by LIBRARY, thrown CONTEXTING.\n'
      'MESSAGE\n'
      'INFO',
    );
    expect(
      FlutterErrorDetails(
        library: 'LIBRARY',
        contextName: 'CONTEXTING',
        diagnosticsCollector: () => <DiagnosticsNode>[
          descriptionMessage('INFO'),
        ],
      ).toString(),
      'Error caught by LIBRARY, thrown CONTEXTING.\n'
      '  null\n'
      'INFO',
    );
    expect(
      FlutterErrorDetails(
        exception: 'MESSAGE',
        contextName: 'CONTEXTING',
        diagnosticsCollector: () => <DiagnosticsNode>[
          descriptionMessage('INFO'),
        ],
      ).toString(),
      'Error caught by Flutter framework, thrown CONTEXTING.\n'
      'MESSAGE\n'
      'INFO',
    );
    expect(
      const FlutterErrorDetails(
        exception: 'MESSAGE',
      ).toString(),
      'Error caught by Flutter framework.\n'
      'MESSAGE'
    );
    expect(
      const FlutterErrorDetails().toString(),
      'Error caught by Flutter framework.\n'
      '  null'
    );
  });
}
