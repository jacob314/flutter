// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'basic_types.dart';
import 'diagnostics.dart';
import 'print.dart';

/// Signature for [FlutterError.onError] handler.
typedef FlutterExceptionHandler = void Function(FlutterErrorDetails details);

/// Signature for [FlutterErrorDetails.informationCollector] callback
/// and other callbacks that collect information into a string buffer.
typedef InformationCollector = void Function(List<DiagnosticsNode> information);

class _ErrorDiagnostic extends DiagnosticsProperty<List<Object>> {
  _ErrorDiagnostic._fromParts(
      List<Object> messageParts, {
        DiagnosticsTreeStyle style = DiagnosticsTreeStyle.whitespace,
        DiagnosticLevel level = DiagnosticLevel.info,
      }) : assert(messageParts != null),
        super(
        null,
        messageParts,
        showName: false,
        showSeparator: false,
        defaultValue: null,
        style: style,
        level: level,
      );

  String valueToString({ TextTreeConfiguration parentConfiguration }) {
    return value.join('');
  }
}

/// Diagnostics describing an error message.
///
/// An error message should start with a summary that is typically
/// no longer than 2 lines that concisely states what the assertion
/// failure or contract violation was. The summary should be separated from the
/// rest of the error message with a line break.
///
/// The client (e.g., an IDE) usually displays the error summary in red.
///
/// The full error message should include at least the following elements:
/// * Claim: Explanation of the assertion failure or contract violation.
/// * Grounds: Facts about the user's code that led to the error.
/// * Warranty: Connections between the grounds and the claim.
///
/// Error messages may include references to objects relevant to the error using
/// string interpolation and those objects will be directly available to
/// debugging tools when error messages are generating as part of a debug builds.
/// Other builds will see the same string error message but will not be able to
/// extract the contents of the object.
class ErrorDetails extends _ErrorDiagnostic {
  // This constructor provides a reliable hook for a kernel transformer to find
  // error messages that need to be rewritten to include object references.
  //
  // The message will display with the same text regardless of whether the
  // kernel transformer is used but without the kernel transformer, debugging
  // tools are unable to provide interactive displays of objects referenced by
  // the string.
  /// In debug builds, a kernel transformer rewrites calls to the default
  /// constructor into calls to this constructor.
  ///
  /// of this class as follows so that the objects referenced in the
  /// string literal can be captured by debuggers.
  /// ```dart
  /// ErrorMessage('Element $element must be color $color')
  /// ```
  /// Desugars to:
  /// ```dart
  /// ErrorMessage._structured(<Object>['Element ', element, ' must be ', color]);
  /// ```
  ///
  /// Slightly more complext case:
  /// ```dart
  /// ErrorMessage('Element ${element.runtimeType} must be must be $color')
  /// ```
  /// Desugars to:
  ///```dart
  /// ErrorMessage._structured(<Object>[
  ///   'Element ',
  ///    DiagnosticsProperty(null, element, description: element.runtimeType?.toString()),
  ///    ' must be ',
  ///    color,
  /// ]);
  /// ```
  ErrorDetails(String message) : super._fromParts([message], level: DiagnosticLevel.summary);

  // Calls to the default constructor are rewritten to use this constructor
  // debug mode using a kernel transformer.
  ErrorDetails._fromParts(List<Object> messageParts) : super._fromParts(messageParts, level: DiagnosticLevel.summary);
}

class ErrorSummary extends _ErrorDiagnostic {
  // This constructor provides a reliable hook for a kernel transformer to find
  // error messages that need to be rewritten to include object references.
  //
  // The message will display with the same text regardless of whether the
  // kernel transformer is used but without the kernel transformer, debugging
  // tools are unable to provide interactive displays of objects referenced by
  // the string.
  /// In debug builds, a kernel transformer rewrites calls to the default
  /// constructor into calls to this constructor.
  ///
  /// of this class as follows so that the objects referenced in the
  /// string literal can be captured by debuggers.
  /// ```dart
  /// ErrorMessage('Element $element must be color $color')
  /// ```
  /// Desugars to:
  /// ```dart
  /// ErrorMessage._structured(<Object>['Element ', element, ' must be ', color]);
  /// ```
  ///
  /// Slightly more complext case:
  /// ```dart
  /// ErrorMessage('Element ${element.runtimeType} must be must be $color')
  /// ```
  /// Desugars to:
  ///```dart
  /// ErrorMessage._structured(<Object>[
  ///   'Element ',
  ///    DiagnosticsProperty(null, element, description: element.runtimeType?.toString()),
  ///    ' must be ',
  ///    color,
  /// ]);
  /// ```
  ErrorSummary(String message) : super._fromParts([message], level: DiagnosticLevel.summary);

  // Use this constructor if and only if the string passed in needs to be a
  // variabile instead of a string literal. Using this constructor loses out
  // on the debugger benefits of using ErrorSummary.
  ErrorSummary.fromString(String message) : super._fromParts([message], level: DiagnosticLevel.summary);

  // Calls to the default constructor are rewritten to use this constructor
  // debug mode using a kernel transformer.
  ErrorSummary._fromParts(List<Object> messageParts) : super._fromParts(messageParts, level: DiagnosticLevel.summary);
}

/// An [ErrorHint] provides specific, non-obvious advice that may be applicable.
///
/// Information that is always true (e.g. "this argument is required" or
/// "you must include this argument") goes in the description.
/// Information that may not be useful in all situations
/// ("Consider using the Foo widget...") goes in a "hint" section.
/// Urls may be be included in the hint to reference external material.
class ErrorHint extends _ErrorDiagnostic {
  // A lint enforces that this constructor can only be called with a string
  // literal to match the limitations of the Dart Kernel transformer that
  // optionally extracts out objects referenced using string interpolation in
  // the message passed in.
  ErrorHint(String message) : super._fromParts([message], level:DiagnosticLevel.hint);

  // Calls to the default constructor are rewritten to use this constructor
  // debug mode using a kernel transformer.
  ErrorHint._fromParts(List<Object> messageParts) : super._fromParts(messageParts, level:DiagnosticLevel.hint);
}

class ErrorProperty<T> extends DiagnosticsProperty<T> {
  ErrorProperty(
      String name,
      T value,
      {
        String description,
        String ifNull,
        String ifEmpty,
        bool showName = true,
        bool showSeparator = true,
        Object defaultValue = kNoDefaultValue,
        String tooltip,
        bool missingIfNull = false,
        String linePrefix,
        bool expandableValue = false,
        bool allowWrap = true,
        bool allowNameWrap = true,
        DiagnosticsTreeStyle style = DiagnosticsTreeStyle.indentedSingleLine,
        DiagnosticLevel level = DiagnosticLevel.info,
      }) : super(
      name,
      value,
       description: description,
      ifNull: ifNull,
      ifEmpty: ifEmpty,
      showName: showName,
      showSeparator: showSeparator,
      defaultValue: defaultValue,
      tooltip: tooltip,
      missingIfNull: missingIfNull,
      linePrefix: linePrefix,
      expandableValue: expandableValue,
      allowWrap: allowWrap,
      allowNameWrap: allowNameWrap,
      style: style,
      level: level,
    );
}
/// Class for information provided to [FlutterExceptionHandler] callbacks.
///
/// See [FlutterError.onError].
class FlutterErrorDetails extends Diagnosticable {
  /// Creates a [FlutterErrorDetails] object with the given arguments setting
  /// the object's properties.
  ///
  /// The framework calls this constructor when catching an exception that will
  /// subsequently be reported using [FlutterError.onError].
  ///
  /// The [exception] must not be null; other arguments can be left to
  /// their default values. (`throw null` results in a
  /// [NullThrownError] exception.)
  const FlutterErrorDetails({
    this.exception,
    this.stack,
    this.library = 'Flutter framework',
    this.context,
    this.stackFilter,
    this.informationCollector,
    this.silent = false
  });

  /// The exception. Often this will be an [AssertionError], maybe specifically
  /// a [FlutterError]. However, this could be any value at all.
  final dynamic exception;

  /// The stack trace from where the [exception] was thrown (as opposed to where
  /// it was caught).
  ///
  /// StackTrace objects are opaque except for their [toString] function.
  ///
  /// If this field is not null, then the [stackFilter] callback, if any, will
  /// be called with the result of calling [toString] on this object and
  /// splitting that result on line breaks. If there's no [stackFilter]
  /// callback, then [FlutterError.defaultStackFilter] is used instead. That
  /// function expects the stack to be in the format used by
  /// [StackTrace.toString].
  final StackTrace stack;

  /// A human-readable brief name describing the library that caught the error
  /// message. This is used by the default error handler in the header dumped to
  /// the console.
  final String library;

  /// A human-readable description of where the error was caught (as opposed to
  /// where it was thrown).
  ///
  /// The string should be in a form that will make sense in English when
  /// following the word "thrown", as in "thrown while obtaining the image from
  /// the network" (for the context "while obtaining the image from the
  /// network").
  final DiagnosticsNode context;

  /// A callback which filters the [stack] trace. Receives an iterable of
  /// strings representing the frames encoded in the way that
  /// [StackTrace.toString()] provides. Should return an iterable of lines to
  /// output for the stack.
  ///
  /// If this is not provided, then [FlutterError.dumpErrorToConsole] will use
  /// [FlutterError.defaultStackFilter] instead.
  ///
  /// If the [FlutterError.defaultStackFilter] behavior is desired, then the
  /// callback should manually call that function. That function expects the
  /// incoming list to be in the [StackTrace.toString()] format. The output of
  /// that function, however, does not always follow this format.
  ///
  /// This won't be called if [stack] is null.
  final IterableFilter<String> stackFilter;

  /// A callback which, when called with a [StringBuffer] will write to that buffer
  /// information that could help with debugging the problem.
  ///
  /// Information collector callbacks can be expensive, so the generated information
  /// should be cached, rather than the callback being called multiple times.
  ///
  /// The text written to the information argument may contain newlines but should
  /// not end with a newline.
  final InformationCollector informationCollector;

  /// Whether this error should be ignored by the default error reporting
  /// behavior in release mode.
  ///
  /// If this is false, the default, then the default error handler will always
  /// dump this error to the console.
  ///
  /// If this is true, then the default error handler would only dump this error
  /// to the console in checked mode. In release mode, the error is ignored.
  ///
  /// This is used by certain exception handlers that catch errors that could be
  /// triggered by environmental conditions (as opposed to logic errors). For
  /// example, the HTTP library sets this flag so as to not report every 404
  /// error to the console on end-user devices, while still allowing a custom
  /// error handler to see the errors even in release builds.
  final bool silent;

  /// Converts the [exception] to a string.
  ///
  /// This applies some additional logic to make [AssertionError] exceptions
  /// prettier, to handle exceptions that stringify to empty strings, to handle
  /// objects that don't inherit from [Exception] or [Error], and so forth.
  String exceptionAsString() {
    String longMessage;
    if (exception is AssertionError) {
      // Regular _AssertionErrors thrown by assert() put the message last, after
      // some code snippets. This leads to ugly messages. To avoid this, we move
      // the assertion message up to before the code snippets, separated by a
      // newline, if we recognise that format is being used.
      final String message = exception.message;
      final String fullMessage = exception.toString();
      if (message is String && message != fullMessage) {
        if (fullMessage.length > message.length) {
          final int position = fullMessage.lastIndexOf(message);
          if (position == fullMessage.length - message.length &&
              position > 2 &&
              fullMessage.substring(position - 2, position) == ': ') {
            longMessage = '${message.trimRight()}\n${fullMessage.substring(0, position - 2)}';
          }
        }
      }
      longMessage ??= fullMessage;
    } else if (exception is String) {
      longMessage = exception;
    } else if (exception is Error || exception is Exception) {
      longMessage = exception.toString();
    } else {
      longMessage = '  ${exception.toString()}';
    }
    longMessage = longMessage.trimRight();
    if (longMessage.isEmpty)
      longMessage = '  <no message available>';
    return longMessage;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    // TODO(jacobr): add back the rest of what was in the toString.
    // This is purely for illustration of how this fits together.
    if (exception is FlutterError) {
      exception.debugFillProperties(properties);
    } else {
      properties.add(DiagnosticsNode.message(exceptionAsString()));
    }
    // XXX: fully implement aligning more with dumpErrorToConsole
    // than with the existing toString which is inconsistent for somewhat
    // arbitrary reasons.
  }
}

/// Error class used to report Flutter-specific assertion failures and
/// contract violations.
class FlutterError extends AssertionError with DiagnosticableTreeMixin {
  /// Creates a [FlutterError].
  ///
  /// See [message] for details on the format that the message should
  /// take.
  ///
  /// Include as much detail as possible in the full error message,
  /// including specifics about the state of the app that might be
  /// relevant to debugging the error.
  FlutterError(this._diagnostics) : super(null);

  final List<DiagnosticsNode> _diagnostics;

  /// The message associated with this error.
  ///
  /// The message may have newlines in it. The first line should be a terse
  /// description of the error, e.g. "Incorrect GlobalKey usage" or "setState()
  /// or markNeedsBuild() called during build". Subsequent lines should contain
  /// substantial additional information, ideally sufficient to develop a
  /// correct solution to the problem.
  ///
  /// In some cases, when a FlutterError is reported to the user, only the first
  /// line is included. For example, Flutter will typically only fully report
  /// the first exception at runtime, displaying only the first line of
  /// subsequent errors.
  ///
  /// All sentences in the error should be correctly punctuated (i.e.,
  /// do end the error message with a period).
  @override
  String get message => toStringDeep();

  /// Called whenever the Flutter framework catches an error.
  ///
  /// The default behavior is to call [dumpErrorToConsole].
  ///
  /// You can set this to your own function to override this default behavior.
  /// For example, you could report all errors to your server.
  ///
  /// If the error handler throws an exception, it will not be caught by the
  /// Flutter framework.
  ///
  /// Set this to null to silently catch and ignore errors. This is not
  /// recommended.
  static FlutterExceptionHandler onError = dumpErrorToConsole;

  static int _errorCount = 0;

  /// Resets the count of errors used by [dumpErrorToConsole] to decide whether
  /// to show a complete error message or an abbreviated one.
  ///
  /// After this is called, the next error message will be shown in full.
  static void resetErrorCount() {
    _errorCount = 0;
  }

  /// The width to which [dumpErrorToConsole] will wrap lines.
  ///
  /// This can be used to ensure strings will not exceed the length at which
  /// they will wrap, e.g. when placing ASCII art diagrams in messages.
  static const int wrapWidth = 100;

  /// Prints the given exception details to the console.
  ///
  /// The first time this is called, it dumps a very verbose message to the
  /// console using [debugPrint].
  ///
  /// Subsequent calls only dump the first line of the exception, unless
  /// `forceReport` is set to true (in which case it dumps the verbose message).
  ///
  /// Call [resetErrorCount] to cause this method to go back to acting as if it
  /// had not been called before (so the next message is verbose again).
  ///
  /// The default behavior for the [onError] handler is to call this function.
  static void dumpErrorToConsole(FlutterErrorDetails details, { bool forceReport = false }) {
    throw 'Reimplement';
  }

  /// Converts a stack to a string that is more readable by omitting stack
  /// frames that correspond to Dart internals.
  ///
  /// This is the default filter used by [dumpErrorToConsole] if the
  /// [FlutterErrorDetails] object has no [FlutterErrorDetails.stackFilter]
  /// callback.
  ///
  /// This function expects its input to be in the format used by
  /// [StackTrace.toString()]. The output of this function is similar to that
  /// format but the frame numbers will not be consecutive (frames are elided)
  /// and the final line may be prose rather than a stack frame.
  static Iterable<String> defaultStackFilter(Iterable<String> frames) {
    const List<String> filteredPackages = <String>[
      'dart:async-patch',
      'dart:async',
      'package:stack_trace',
    ];
    const List<String> filteredClasses = <String>[
      '_AssertionError',
      '_FakeAsync',
      '_FrameCallbackEntry',
    ];
    final RegExp stackParser = RegExp(r'^#[0-9]+ +([^.]+).* \(([^/\\]*)[/\\].+:[0-9]+(?::[0-9]+)?\)$');
    final RegExp packageParser = RegExp(r'^([^:]+):(.+)$');
    final List<String> result = <String>[];
    final List<String> skipped = <String>[];
    for (String line in frames) {
      final Match match = stackParser.firstMatch(line);
      if (match != null) {
        assert(match.groupCount == 2);
        if (filteredPackages.contains(match.group(2))) {
          final Match packageMatch = packageParser.firstMatch(match.group(2));
          if (packageMatch != null && packageMatch.group(1) == 'package') {
            skipped.add('package ${packageMatch.group(2)}'); // avoid "package package:foo"
          } else {
            skipped.add('package ${match.group(2)}');
          }
          continue;
        }
        if (filteredClasses.contains(match.group(1))) {
          skipped.add('class ${match.group(1)}');
          continue;
        }
      }
      result.add(line);
    }
    if (skipped.length == 1) {
      result.add('(elided one frame from ${skipped.single})');
    } else if (skipped.length > 1) {
      final List<String> where = Set<String>.from(skipped).toList()..sort();
      if (where.length > 1)
        where[where.length - 1] = 'and ${where.last}';
      if (where.length > 2) {
        result.add('(elided ${skipped.length} frames from ${where.join(", ")})');
      } else {
        result.add('(elided ${skipped.length} frames from ${where.join(" ")})');
      }
    }
    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    _diagnostics?.forEach(properties.add);
  }

  /// Calls [onError] with the given details, unless it is null.
  static void reportError(FlutterErrorDetails details) {
    assert(details != null);
    assert(details.exception != null);
    if (onError != null)
      onError(details);
  }
}

/// Dump the current stack to the console using [debugPrint] and
/// [FlutterError.defaultStackFilter].
///
/// The current stack is obtained using [StackTrace.current].
///
/// The `maxFrames` argument can be given to limit the stack to the given number
/// of lines. By default, all non-filtered stack lines are shown.
///
/// The `label` argument, if present, will be printed before the stack.
void debugPrintStack({ String label, int maxFrames }) {
  if (label != null)
    debugPrint(label);
  Iterable<String> lines = StackTrace.current.toString().trimRight().split('\n');
  if (maxFrames != null)
    lines = lines.take(maxFrames);
  debugPrint(FlutterError.defaultStackFilter(lines).join('\n'));
}

/// Diagnostic with a [StackTrace] [value] suitable for displaying stacktraces
/// as part of a [FlutterError] object.
///
/// See also:
///
/// * [FlutterErrorBuilder.addStackTrace], which is the typical way [StackTrace]
///   objects are added to a [FlutterError].
class DiagnosticsStackTrace extends DiagnosticsBlock {

  /// Creates a diagnostic for a stack trace.
  ///
  /// [name] describes a name the stacktrace is given, e.g.
  /// `When the exception was thrown, this was the stack`.
  /// [stackFilter] provides an optional filter to use to filter which frames
  /// are included. If no filter is specified, [FlutterError.defaultStackFilter]
  /// is used.
  /// [showSeparator] indicates whether to include a ':' after the [name].
  DiagnosticsStackTrace(
      String name,
      StackTrace stack, {
        IterableFilter<String> stackFilter,
        bool showSeparator = true,
      }) : super(
    name: name,
    value: stack,
    properties: (stackFilter ?? FlutterError.defaultStackFilter)(stack.toString().trimRight().split('\n'))
        .map<DiagnosticsNode>(_createStackFrame)
        .toList(),
    style: DiagnosticsTreeStyle.flat,
    showSeparator: showSeparator,
    allowTruncate: true,
  );

  /// Creates a diagnostic describing a single frame from a StackTrace.
  DiagnosticsStackTrace.singleFrame(
      String name, {
        @required String frame,
        bool showSeparator = true,
      }) : super(
    name: name,
    properties: <DiagnosticsNode>[_createStackFrame(frame)],
    style: DiagnosticsTreeStyle.indentedSingleLine,
    showSeparator: showSeparator,
  );

  static DiagnosticsNode _createStackFrame(String frame) {
    return DiagnosticsNode.message(frame, allowWrap: false);
  }
}
