// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer' as developer;
import 'dart:math' as math;
import 'dart:ui' as ui show window;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import 'basic.dart';
import 'binding.dart';
import 'framework.dart';
import 'gesture_detector.dart';

/// A widget that enables inspecting the child widget's structure.
///
/// This widget is useful for understand how an app is structured enabling
/// interactive
class WidgetInspector extends StatefulWidget {
  /// Creates a widget that enables inspection for the child.
  ///
  /// The [child] argument must not be null.
  const WidgetInspector({Key key, this.child}) : super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  _WidgetInspectorState createState() => new _WidgetInspectorState();
}

class _WidgetInspectorState extends State<WidgetInspector>
    with WidgetsBindingObserver {
  _WidgetClient _client;

  Offset _lastPointerLocation;

  /// Selected [RenderObject] being inspected.
  RenderObject _selected;

  /// Whether the inspector is in select mode.
  ///
  /// In select mode pointer interactions trigger widget selection instead of
  /// normal interactions.
  /// Not in select mode, the selected widget is highlighted but the application
  /// can be interacted with normally.
  bool isSelectMode = false;

  /// Key tracking where the root in the widget tree
  final GlobalKey _ignorePointerKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    // TODO(jacobr): We shouldn't reach out to the WidgetsBinding.instance
    // static here because we might not be in a tree that's attached to that
    // binding. Instead, we should find a way to get to the PipelineOwner from
    // the BuildContext.
    _client = new _WidgetClient(WidgetsBinding.instance.pipelineOwner)
      ..addListener(_update);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _client
      ..removeListener(_update)
      ..dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {
      // The root transform may have changed, we have to repaint.
    });
  }

  void _update() {
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      // We want the update to take effect next frame, so to make that
      // explicit we call setState() in a post-frame callback.
      if (mounted) {
        // If we got disposed this frame, we will still get an update,
        // because the inactive list is flushed after the widget updates
        // are transmitted to the widget clients.
        setState(() {
          // The generation of the _WidgetInspectorListener has changed.
        });
      }
    });
  }

  bool _hitTestHelper(List<RenderObject> result, Offset position, RenderObject object, Matrix4 transform) {
    final Matrix4 inverse = new Matrix4.inverted(transform);
    final Offset localPosition = MatrixUtils.transformPoint(inverse, position);

    List<RenderObject> children = <RenderObject>[];

    object.visitChildren((RenderObject child) {
      children.add(child);
    });

    bool hit = false;
    for (int i = children.length - 1; i >= 0; i--) {
      final RenderObject child = children[i];
      final Rect paintClip = object.describeApproximatePaintClip(child);
      if (paintClip != null && !paintClip.contains(localPosition))
        continue;

      final Matrix4 childTransform = transform.clone();
      object.applyPaintTransform(child, childTransform);
      if (_hitTestHelper(result, position, child, childTransform)) {
        hit = true;
      }
    }

    if (hit == false &&  children.length > 0) return false;
    hit = hit || object.semanticBounds.contains(localPosition);
    if (hit) {
      result.add(object);
    }
    return hit;
  }

  /// Hit test method that hit tests against all visible elements rather than
  /// just elements that would normally participate in hit testing.
  bool hitTest(List<RenderObject> result, Offset position, RenderBox root) {
    return _hitTestHelper(result, position, root, root.getTransformTo(null));
  }

  void _inspectAt(Offset position) {
    if (!isSelectMode)
      return;

    final List<RenderObject> result = <RenderObject>[];
    final RenderIgnorePointer ignorePointer =
        _ignorePointerKey.currentContext.findRenderObject();
    final RenderBox userRender = ignorePointer.child;
    hitTest(result, position, userRender);
    /*
    result.sort((RenderObject a, RenderObject b) {
      return _rectSize(a.semanticBounds).compareTo(_rectSize(b.semanticBounds));
    });
    */
    setState(() {
      _selected = result.first;
    });
  }

  double _rectSize(Rect r) => r.width * r.height;
  void _handlePointerDown(PointerDownEvent event) {
    _lastPointerLocation = event.position;
    _inspectAt(event.position);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    _lastPointerLocation = event.position;
    _inspectAt(event.position);
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    setState(() {
      isSelectMode = false;
      _selected = null;
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    _lastPointerLocation = event.position;

    // If the pointer up position is on the edge of the window assume that it
    // indicates the pointer is being dragged off the edge of the display not
    // a regular mouse up near the edge of the display. If the pointer is being
    // dragged off the edge of the display we do not want to select anything.
    final Rect bounds =
        (Offset.zero & (ui.window.physicalSize / ui.window.devicePixelRatio))
            .deflate(_kOffScreenMargin);
    if (!bounds.contains(event.position)) {
      setState(() {
        _selected = null;
      });
      return;
    }
    _inspectAt(event.position);
  }

  void _handleTap() {
    if (!isSelectMode)
      return;
    if (_lastPointerLocation == null)
      return;
    setState(() {
      _inspectAt(_lastPointerLocation);

      if (_selected != null) {
        // Notify debuggers to open an inspector on the object.
        developer.inspect(_selected);
        print(_selected.toStringDeep());
      }
      isSelectMode = false;
    });
  }

  void _handleEnableSelect() {
    setState(() {
      isSelectMode = true;
    });
  }

  // TODO(jacobr): This shouldn't be a static. We should get the pipeline owner
  // from [context] somehow.
  PipelineOwner get _pipelineOwner => WidgetsBinding.instance.pipelineOwner;

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
        foregroundPainter: new _WidgetInspectorPainter(
            _pipelineOwner, _client.generation, _selected),
        child: new Stack(children: <Widget>[
          new GestureDetector(
              onTap: _handleTap,
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              child: new Listener(
                  onPointerDown: _handlePointerDown,
                  onPointerMove: _handlePointerMove,
                  onPointerUp: _handlePointerUp,
                  onPointerCancel: _handlePointerCancel,
                  behavior: HitTestBehavior.opaque,
                  child: isSelectMode
                      ? new IgnorePointer(
                          key: _ignorePointerKey,
                          ignoringSemantics: false,
                          child: widget.child)
                      : widget.child)),
          new Positioned(
            left: _kInspectButtonMargin,
            bottom: _kInspectButtonMargin,
            child: isSelectMode
                ? new Container()
                : new FloatingActionButton(
                    child: const Icon(Icons.search),
                    onPressed: _handleEnableSelect,
                    mini: true,
                  ),
          ),
        ]));
  }
}

const double _kScreenEdgeMargin = 10.0;
const double _kTooltipPadding = 5.0;
const double _kInspectButtonMargin = 10.0;

/// Interpret pointer up events within with this margin as indicating the
/// pointer is moving off the device.
const double _kOffScreenMargin = 1.0;

// TODO(jacobr): merge with similar code in tooltip.dart.
class _TooltipPositionCalculator {
  _TooltipPositionCalculator({
    this.target,
    this.verticalOffset,
    this.preferBelow,
    this.size,
    this.childSize,
  }) {
    // VERTICAL DIRECTION
    final bool fitsBelow = target.dy + verticalOffset + childSize.height <=
        size.height - _kScreenEdgeMargin;
    final bool fitsAbove =
        target.dy - verticalOffset - childSize.height >= _kScreenEdgeMargin;
    _tooltipBelow =
        preferBelow ? fitsBelow || !fitsAbove : !(fitsAbove || !fitsBelow);
    double y;
    if (_tooltipBelow)
      y = math.min(
          target.dy + verticalOffset, size.height - _kScreenEdgeMargin);
    else
      y = math.max(
          target.dy - verticalOffset - childSize.height, _kScreenEdgeMargin);
    // HORIZONTAL DIRECTION
    final double normalizedTargetX =
        target.dx.clamp(_kScreenEdgeMargin, size.width - _kScreenEdgeMargin);
    double x;
    if (normalizedTargetX > size.width - _kScreenEdgeMargin - childSize.width) {
      // Make room for content to the right.
      x = size.width - _kScreenEdgeMargin - childSize.width;
    } else {
      x = normalizedTargetX;
    }
    _childPosition = new Offset(x, y);
  }

  final Offset target;
  final double verticalOffset;
  final bool preferBelow;
  final Size size;
  final Size childSize;

  Offset _childPosition;
  bool _tooltipBelow;

  bool get tooltipBelow => _tooltipBelow;
  Offset get childPosition => _childPosition;
}

// FOR DISCUSSION: this is clearly not quite right: should I even even bother
// listening for changes? This code is copied from semantics_debugger where
// it made sense.
class _WidgetClient extends ChangeNotifier {
  _WidgetClient(PipelineOwner pipelineOwner) {
    _semanticsHandle =
        pipelineOwner.ensureSemantics(listener: _didUpdateSemantics);
  }

  SemanticsHandle _semanticsHandle;

  @override
  void dispose() {
    _semanticsHandle.dispose();
    _semanticsHandle = null;
    super.dispose();
  }

  int generation = 0;

  void _didUpdateSemantics() {
    generation += 1;
    notifyListeners();
  }
}

const TextStyle _messageStyle = const TextStyle(
    color: const Color(0xFFFFFFFF), fontSize: 10.0, height: 1.2);
final int _kMaxTooltipLines = 5;
const Color _kTooltipBackgroundColor = const Color.fromARGB(230, 60, 60, 60);

void _paintDescription(Canvas canvas, RenderBox render, Offset target,
    double verticalOffset, Size size, Rect targetRect) {
  // TODO(jacobr): craft a better description message.
  final String message = '$render\n\n'
      '${render.debugCreator}';
  canvas.save();
  final TextPainter textPainter = new TextPainter()
    ..maxLines = _kMaxTooltipLines
    ..ellipsis = '...'
    ..text = new TextSpan(style: _messageStyle, text: message)
    ..layout(
        maxWidth: size.width - 2 * (_kScreenEdgeMargin + _kTooltipPadding));

  final Size tooltipSize =
      textPainter.size + const Offset(_kTooltipPadding * 2, _kTooltipPadding * 2);
  final _TooltipPositionCalculator calc = new _TooltipPositionCalculator(
      target: target,
      verticalOffset: verticalOffset,
      preferBelow: false,
      size: size,
      childSize: tooltipSize);
  final Offset tipOffset = calc.childPosition;

  final Paint tooltipBackground = new Paint()
    ..style = PaintingStyle.fill
    ..color = _kTooltipBackgroundColor;
  canvas.drawRect(
      new Rect.fromPoints(tipOffset,
          tipOffset.translate(tooltipSize.width, tooltipSize.height)),
      tooltipBackground);

  double wedgeY = tipOffset.dy;
  if (!calc.tooltipBelow) {
    wedgeY += tooltipSize.height;
  }
  final double wedgeSize = _kTooltipPadding * 2;
  double wedgeX = math.max(tipOffset.dx, target.dx) + wedgeSize * 2;
  wedgeX = math.min(wedgeX, tipOffset.dx + tooltipSize.width - wedgeSize * 2);
  canvas.drawPath(
      new Path()
        ..addPolygon(<Offset>[
          new Offset(wedgeX - wedgeSize, wedgeY),
          new Offset(wedgeX + wedgeSize, wedgeY),
          new Offset(
              wedgeX, wedgeY + (calc.tooltipBelow ? -wedgeSize : wedgeSize)),
        ], true),
      tooltipBackground);

  textPainter.paint(
      canvas, tipOffset + const Offset(_kTooltipPadding, _kTooltipPadding));
  canvas.restore();
}

final Color _kHighlightedRenderObjectFillColor =
    const Color.fromARGB(128, 128, 128, 255);
final Color _kHighlightedRenderObjectBorderColor =
    const Color.fromARGB(128, 64, 64, 128);

class _WidgetInspectorPainter extends CustomPainter {
  const _WidgetInspectorPainter(this.owner, this.generation, this.selected);

  final PipelineOwner owner;
  final int generation;
  final RenderObject selected;

  bool get isSelectionActive => selected != null && selected.attached;

  @override
  void paint(Canvas canvas, Size size) {
    if (!isSelectionActive)
      return;

    canvas.save();

    final Matrix4 transform = selected.getTransformTo(null);
    // Highlight the selected renderObject.
    canvas
      ..save()
      ..transform(transform.storage)
      ..drawRect(
          selected.semanticBounds.deflate(0.5),
          new Paint()
            ..style = PaintingStyle.fill
            ..color = _kHighlightedRenderObjectFillColor)
      ..drawRect(
          selected.semanticBounds.deflate(0.5),
          new Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = _kHighlightedRenderObjectBorderColor)
      ..restore();

    final Rect targetRect = MatrixUtils.transformRect(transform, selected.semanticBounds);

    final Offset target = new Offset(targetRect.left, targetRect.center.dy);
    final double offsetFromWidget = 9.0;
    final double verticalOffset = (targetRect.height) / 2 + offsetFromWidget;

    _paintDescription(
        canvas, selected, target, verticalOffset, size, targetRect);

    // TODO(jacobr): provide an option to perform a debug paint of just the
    // selected widget.

    canvas.restore();
  }

  @override
  bool shouldRepaint(_WidgetInspectorPainter oldDelegate) {
    return isSelectionActive ||
        isSelectionActive != oldDelegate.isSelectionActive ||
        selected != oldDelegate.selected ||
        owner != oldDelegate.owner ||
        generation != oldDelegate.generation;
  }
}
