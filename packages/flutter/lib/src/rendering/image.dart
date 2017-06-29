// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui show Image;

import 'box.dart';
import 'object.dart';

export 'package:flutter/painting.dart' show
  BoxFit,
  ImageRepeat;

/// An image in the render tree.
///
/// The render image attempts to find a size for itself that fits in the given
/// constraints and preserves the image's intrinisc aspect ratio.
///
/// The image is painted using [paintImage], which describes the meanings of the
/// various fields on this class in more detail.
class RenderImage extends RenderBox {
  /// Creates a render box that displays an image.
  RenderImage({
    ui.Image image,
    double width,
    double height,
    double scale: 1.0,
    Color color,
    BlendMode colorBlendMode,
    BoxFit fit,
    FractionalOffset alignment,
    ImageRepeat repeat: ImageRepeat.noRepeat,
    Rect centerSlice
  }) : _image = image,
      _width = width,
      _height = height,
      _scale = scale,
      _color = color,
      _colorBlendMode = colorBlendMode,
      _fit = fit,
      _alignment = alignment,
      _repeat = repeat,
      _centerSlice = centerSlice {
    _updateColorFilter();
  }

  /// The image to display.
  ui.Image get image => _image;
  ui.Image _image;
  set image(ui.Image value) {
    if (value == _image)
      return;
    _image = value;
    markNeedsPaint();
    if (_width == null || _height == null)
      markNeedsLayout();
  }

  /// If non-null, requires the image to have this width.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  double get width => _width;
  double _width;
  set width(double value) {
    if (value == _width)
      return;
    _width = value;
    markNeedsLayout();
  }

  /// If non-null, require the image to have this height.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  double get height => _height;
  double _height;
  set height(double value) {
    if (value == _height)
      return;
    _height = value;
    markNeedsLayout();
  }

  /// Specifies the image's scale.
  ///
  /// Used when determining the best display size for the image.
  double get scale => _scale;
  double _scale;
  set scale(double value) {
    assert(value != null);
    if (value == _scale)
      return;
    _scale = value;
    markNeedsLayout();
  }

  ColorFilter _colorFilter;

  void _updateColorFilter() {
    if (_color == null)
      _colorFilter = null;
    else
      _colorFilter = new ColorFilter.mode(_color, _colorBlendMode ?? BlendMode.srcIn);
  }

  /// If non-null, this color is blended with each image pixel using [colorBlendMode].
  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (value == _color)
      return;
    _color = value;
    _updateColorFilter();
    markNeedsPaint();
  }

  /// Used to combine [color] with this image.
  ///
  /// The default is [BlendMode.srcIn]. In terms of the blend mode, [color] is
  /// the source and this image is the destination.
  ///
  /// See also:
  ///
  ///  * [BlendMode], which includes an illustration of the effect of each blend mode.
  BlendMode get colorBlendMode => _colorBlendMode;
  BlendMode _colorBlendMode;
  set colorBlendMode(BlendMode value) {
    if (value == _colorBlendMode)
      return;
    _colorBlendMode;
    _updateColorFilter();
    markNeedsPaint();
  }

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  BoxFit get fit => _fit;
  BoxFit _fit;
  set fit(BoxFit value) {
    if (value == _fit)
      return;
    _fit = value;
    markNeedsPaint();
  }

  /// How to align the image within its bounds.
  FractionalOffset get alignment => _alignment;
  FractionalOffset _alignment;
  set alignment(FractionalOffset value) {
    if (value == _alignment)
      return;
    _alignment = value;
    markNeedsPaint();
  }

  /// How to repeat this image if it doesn't fill its layout bounds.
  ImageRepeat get repeat => _repeat;
  ImageRepeat _repeat;
  set repeat(ImageRepeat value) {
    if (value == _repeat)
      return;
    _repeat = value;
    markNeedsPaint();
  }

  /// The center slice for a nine-patch image.
  ///
  /// The region of the image inside the center slice will be stretched both
  /// horizontally and vertically to fit the image into its destination. The
  /// region of the image above and below the center slice will be stretched
  /// only horizontally and the region of the image to the left and right of
  /// the center slice will be stretched only vertically.
  Rect get centerSlice => _centerSlice;
  Rect _centerSlice;
  set centerSlice(Rect value) {
    if (value == _centerSlice)
      return;
    _centerSlice = value;
    markNeedsPaint();
  }

  /// Find a size for the render image within the given constraints.
  ///
  ///  - The dimensions of the RenderImage must fit within the constraints.
  ///  - The aspect ratio of the RenderImage matches the instrinsic aspect
  ///    ratio of the image.
  ///  - The RenderImage's dimension are maximal subject to being smaller than
  ///    the intrinsic size of the image.
  Size _sizeForConstraints(BoxConstraints constraints) {
    // Folds the given |width| and |height| into |constraints| so they can all
    // be treated uniformly.
    constraints = new BoxConstraints.tightFor(
      width: _width,
      height: _height
    ).enforce(constraints);

    if (_image == null)
      return constraints.smallest;

    return constraints.constrainSizeAndAttemptToPreserveAspectRatio(new Size(
      _image.width.toDouble() / _scale,
      _image.height.toDouble() / _scale
    ));
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    assert(height >= 0.0);
    if (_width == null && _height == null)
      return 0.0;
    return _sizeForConstraints(new BoxConstraints.tightForFinite(height: height)).width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    assert(height >= 0.0);
    return _sizeForConstraints(new BoxConstraints.tightForFinite(height: height)).width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    assert(width >= 0.0);
    if (_width == null && _height == null)
      return 0.0;
    return _sizeForConstraints(new BoxConstraints.tightForFinite(width: width)).height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    assert(width >= 0.0);
    return _sizeForConstraints(new BoxConstraints.tightForFinite(width: width)).height;
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void performLayout() {
    size = _sizeForConstraints(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_image == null)
      return;
    paintImage(
      canvas: context.canvas,
      rect: offset & size,
      image: _image,
      colorFilter: _colorFilter,
      fit: _fit,
      alignment: _alignment,
      centerSlice: _centerSlice,
      repeat: _repeat
    );
  }

  @override
  void debugFillProperties(List<DiagnosticsNode> description) {
    super.debugFillProperties(description);
    description.add(new DiagnosticsNode.objectProperty('image', image));
    description.add(new DiagnosticsNode.doubleProperty('width', width, showNull: false));
    description.add(new DiagnosticsNode.doubleProperty('height', height, showNull: false));
    description.add(new DiagnosticsNode.doubleProperty('scale', scale, hidden: scale == 1.0));
    description.add(new DiagnosticsNode.colorProperty('color', color, showNull: false));
    description.add(new DiagnosticsNode.objectProperty('colorBlendMode', colorBlendMode, showNull: false));

    description.add(new DiagnosticsNode.enumProperty('fit', fit, showNull: false));
    description.add(new DiagnosticsNode.objectProperty('alignment', alignment, showNull: false));
    description.add(new DiagnosticsNode.enumProperty(
        'repeat', repeat, hidden: repeat == ImageRepeat.noRepeat));
    description.add(new DiagnosticsNode.rectProperty(
        'centerSlice', centerSlice, showNull: false));
  }
}
