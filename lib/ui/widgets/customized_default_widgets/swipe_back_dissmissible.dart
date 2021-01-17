// ignore_for_file: prefer_asserts_with_message, unnecessary_null_comparison, always_put_control_body_on_new_line, unawaited_futures

// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const Curve _kResizeTimeCurve = Interval(0.4, 1, curve: Curves.ease);
const double _kMinFlingVelocity = 700;
const double _kMinFlingVelocityDelta = 400;
const double _kFlingVelocityScale = 1 / 300;
const double _kDismissThreshold = 0.4;
const double _kSwipeBackThreshold = 0.12;

typedef DismissDirectionCallback = void Function(CustomDismissDirection direction);

/// Signature used by [SwipeBackDismissible] to give the application an opportunity to
/// confirm or veto a dismiss gesture and return back by swipe back gesture.
///
/// Used by [SwipeBackDismissible.confirmDismiss].
typedef ConfirmDismissCallback = Future<bool?> Function(CustomDismissDirection direction);

/// The direction in which a [SwipeBackDismissible] can be dismissed.
enum CustomDismissDirection {
  /// The [SwipeBackDismissible] can be dismissed by dragging either up or down.
  vertical,

  /// The [SwipeBackDismissible] can be dismissed by dragging either left or right.
  horizontal,

  /// The [SwipeBackDismissible] can be dismissed by dragging in the reverse of the
  /// reading direction (e.g., from right to left in left-to-right languages).
  endToStart,

  /// The [SwipeBackDismissible] can be dismissed by dragging in the reading direction
  /// (e.g., from left to right in left-to-right languages).
  startToEnd,

  /// The [SwipeBackDismissible] can be dismissed by dragging up only.
  up,

  /// The [SwipeBackDismissible] can be dismissed by dragging down only.
  down,

  /// The [SwipeBackDismissible] cannot be dismissed by dragging.
  none
}

/// A Custom widget that can be dismissed by dragging in the indicated [direction].
///
/// Dragging or flinging this widget in the [CustomDismissDirection] causes the child
/// to slide out of view. Following the slide animation, if [resizeDuration] is
/// non-null, the SwipeBackDismissible widget animates its height (or width, whichever is
/// perpendicular to the dismiss direction) to zero over the [resizeDuration].
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=iEMgjrfuc58}
///
/// {@tool dartpad --template=stateful_widget_scaffold}

/// Backgrounds can be used to implement the "leave-behind" idiom. If a background
/// is specified it is stacked behind the SwipeBackDismissible's child and is exposed when
/// the child moves.
///
/// The widget calls the [onDismissed] callback either after its size has
/// collapsed to zero (if [resizeDuration] is non-null) or immediately after
/// the slide animation (if [resizeDuration] is null). If the SwipeBackDismissible is a
/// list item, it must have a key that distinguishes it from the other items and
/// its [onDismissed] callback must remove the item from the list.
class SwipeBackDismissible extends StatefulWidget {
  /// Creates a widget that can be dismissed and swiped to return back.
  ///
  /// The [key] argument must not be null because [SwipeBackDismissible]s are commonly
  /// used in lists and removed from the list when dismissed. Without keys, the
  /// default behavior is to sync widgets based on their index in the list,
  /// which means the item after the dismissed item would be synced with the
  /// state of the dismissed item. Using keys causes the widgets to sync
  /// according to their keys and avoids this pitfall.
  const SwipeBackDismissible({
    required Key key,
    required this.child,
    required this.onSwipeBack,
    this.background,
    this.secondaryBackground,
    this.confirmDismiss,
    this.onResize,
    this.onDismissed,
    this.direction = CustomDismissDirection.horizontal,
    this.resizeDuration = const Duration(milliseconds: 300),
    this.dismissThresholds = const <CustomDismissDirection, double>{},
    this.movementDuration = const Duration(milliseconds: 200),
    this.crossAxisEndOffset = 0,
    this.dragStartBehavior = DragStartBehavior.start,
    this.behavior = HitTestBehavior.opaque,
  })  : assert(key != null),
        assert(onSwipeBack != null),
        assert(secondaryBackground == null || background != null),
        assert(dragStartBehavior != null),
        super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// A widget that is stacked behind the child. If secondaryBackground is also
  /// specified then this widget only appears when the child has been dragged
  /// down or to the right.
  final Widget? background;

  /// A widget that is stacked behind the child and is exposed when the child
  /// has been dragged up or to the left. It may only be specified when background
  /// has also been specified.
  final Widget? secondaryBackground;

  /// Gives the app an opportunity to confirm or veto a pending dismissal.
  ///
  /// If the returned Future<bool> completes true, then this widget will be
  /// dismissed, otherwise it will be moved back to its original location.
  ///
  /// If the returned Future<bool?> completes to false or null the [onResize]
  /// and [onDismissed] callbacks will not run.
  final ConfirmDismissCallback? confirmDismiss;

  /// Called when the widget changes size (i.e., when contracting before being dismissed).
  final VoidCallback? onResize;

  /// Called when the widget has been dismissed, after finishing resizing.
  final DismissDirectionCallback? onDismissed;

  final Function onSwipeBack;

  /// The direction in which the widget can be dismissed.
  final CustomDismissDirection direction;

  /// The amount of time the widget will spend contracting before [onDismissed] is called.
  ///
  /// If null, the widget will not contract and [onDismissed] will be called
  /// immediately after the widget is dismissed.
  final Duration? resizeDuration;

  /// The offset threshold the item has to be dragged in order to be considered
  /// dismissed.
  ///
  /// Represented as a fraction, e.g. if it is 0.4 (the default), then the item
  /// has to be dragged at least 40% towards one direction to be considered
  /// dismissed. Clients can define different thresholds for each dismiss
  /// direction.
  ///
  /// Flinging is treated as being equivalent to dragging almost to 1.0, so
  /// flinging can dismiss an item past any threshold less than 1.0.
  ///
  /// Setting a threshold of 1.0 (or greater) prevents a drag in the given
  /// [CustomDismissDirection] even if it would be allowed by the [direction]
  /// property.
  ///
  /// See also:
  ///
  ///  * [direction], which controls the directions in which the items can
  ///    be dismissed.
  final Map<CustomDismissDirection, double> dismissThresholds;

  /// Defines the duration for card to dismiss or to come back to original position if not dismissed.
  final Duration movementDuration;

  /// Defines the end offset across the main axis after the card is dismissed.
  ///
  /// If non-zero value is given then widget moves in cross direction depending on whether
  /// it is positive or negative.
  final double crossAxisEndOffset;

  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], the drag gesture used to dismiss a
  /// dismissible will begin upon the detection of a drag gesture. If set to
  /// [DragStartBehavior.down] it will begin when a down event is first detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///  * [DragGestureRecognizer.dragStartBehavior], which gives an example for the different behaviors.
  final DragStartBehavior dragStartBehavior;

  /// How to behave during hit tests.
  ///
  /// This defaults to [HitTestBehavior.opaque].
  final HitTestBehavior behavior;

  @override
  _DismissibleState createState() => _DismissibleState();
}

class _DismissibleClipper extends CustomClipper<Rect> {
  _DismissibleClipper({
    required this.axis,
    required this.moveAnimation,
  })   : assert(axis != null),
        assert(moveAnimation != null),
        super(reclip: moveAnimation);

  final Axis axis;
  final Animation<Offset> moveAnimation;

  @override
  Rect getClip(Size size) {
    assert(axis != null);
    switch (axis) {
      case Axis.horizontal:
        final double offset = moveAnimation.value.dx * size.width;
        if (offset < 0) return Rect.fromLTRB(size.width + offset, 0, size.width, size.height);
        return Rect.fromLTRB(0, 0, offset, size.height);
      case Axis.vertical:
        final double offset = moveAnimation.value.dy * size.height;
        if (offset < 0) return Rect.fromLTRB(0, size.height + offset, size.width, size.height);
        return Rect.fromLTRB(0, 0, size.width, offset);
    }
  }

  @override
  Rect getApproximateClipRect(Size size) => getClip(size);

  @override
  bool shouldReclip(_DismissibleClipper oldClipper) =>
      oldClipper.axis != axis || oldClipper.moveAnimation.value != moveAnimation.value;
}

enum _FlingGestureKind { none, forward, reverse }

class _DismissibleState extends State<SwipeBackDismissible>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(duration: widget.movementDuration, vsync: this)
      ..addStatusListener(_handleDismissStatusChanged);
    _updateMoveAnimation();
  }

  AnimationController? _moveController;
  late Animation<Offset> _moveAnimation;

  AnimationController? _resizeController;
  Animation<double>? _resizeAnimation;

  double _dragExtent = 0, _dragBack = 0;
  bool _dragUnderway = false;
  Size? _sizePriorToCollapse;

  @override
  bool get wantKeepAlive => _moveController?.isAnimating == true || _resizeController?.isAnimating == true;

  @override
  void dispose() {
    _moveController!.dispose();
    _resizeController?.dispose();
    super.dispose();
  }

  bool get _directionIsXAxis =>
      widget.direction == CustomDismissDirection.horizontal ||
      widget.direction == CustomDismissDirection.endToStart ||
      widget.direction == CustomDismissDirection.startToEnd;

  CustomDismissDirection _extentToDirection(double extent) {
    if (extent == 0) return CustomDismissDirection.none;
    if (_directionIsXAxis) {
      switch (Directionality.of(context)) {
        case TextDirection.rtl:
          return extent < 0 ? CustomDismissDirection.startToEnd : CustomDismissDirection.endToStart;
        case TextDirection.ltr:
          return extent > 0 ? CustomDismissDirection.startToEnd : CustomDismissDirection.endToStart;
      }
    }
    return extent > 0 ? CustomDismissDirection.down : CustomDismissDirection.up;
  }

  CustomDismissDirection get _dismissDirection => _extentToDirection(_dragExtent);

  bool get _isActive => _dragUnderway || _moveController!.isAnimating;

  double get _overallDragAxisExtent {
    final Size size = context.size!;
    return _directionIsXAxis ? size.width : size.height;
  }

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;
    if (_moveController!.isAnimating) {
      _dragExtent = _moveController!.value * _overallDragAxisExtent * _dragExtent.sign;
      _moveController!.stop();
    } else {
      _dragExtent = 0;
      _moveController!.value = 0;
    }
    setState(_updateMoveAnimation);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isActive || _moveController!.isAnimating) return;

    final double delta = details.primaryDelta!;
    final double oldDragExtent = _dragExtent;

    if (_dragBack > (_overallDragAxisExtent * _kSwipeBackThreshold)) {
      _dragBack = 0;
      widget.onSwipeBack();
      return;
    }
    switch (widget.direction) {
      case CustomDismissDirection.horizontal:
      case CustomDismissDirection.vertical:
        _dragExtent += delta;
        break;

      case CustomDismissDirection.up:
        if (_dragExtent + delta < 0) _dragExtent += delta;
        break;

      case CustomDismissDirection.down:
        if (_dragExtent + delta > 0) _dragExtent += delta;
        break;

      case CustomDismissDirection.endToStart:
        switch (Directionality.of(context)) {
          case TextDirection.rtl:
            if (_dragExtent + delta > 0) _dragExtent += delta;
            break;
          case TextDirection.ltr:
            if (_dragExtent + delta < 0) {
              _dragExtent += delta;
            } else {
              _dragBack += delta;
            }
            break;
        }
        break;

      case CustomDismissDirection.startToEnd:
        switch (Directionality.of(context)) {
          case TextDirection.rtl:
            if (_dragExtent + delta < 0) _dragExtent += delta;
            break;
          case TextDirection.ltr:
            if (_dragExtent + delta > 0) _dragExtent += delta;
            break;
        }
        break;

      case CustomDismissDirection.none:
        _dragExtent = 0;
        break;
    }

    if (oldDragExtent.sign != _dragExtent.sign) {
      setState(_updateMoveAnimation);
    }
    if (!_moveController!.isAnimating) {
      _moveController!.value = _dragExtent.abs() / _overallDragAxisExtent;
    }
  }

  void _updateMoveAnimation() {
    final double end = _dragExtent.sign;
    _moveAnimation = _moveController!.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: _directionIsXAxis ? Offset(end, widget.crossAxisEndOffset) : Offset(widget.crossAxisEndOffset, end),
      ),
    );
  }

  _FlingGestureKind _describeFlingGesture(Velocity velocity) {
    assert(widget.direction != null);
    if (_dragExtent == 0) {
      // If it was a fling, then it was a fling that was let loose at the exact
      // middle of the range (i.e. when there's no displacement). In that case,
      // we assume that the user meant to fling it back to the center, as
      // opposed to having wanted to drag it out one way, then fling it past the
      // center and into and out the other side.
      return _FlingGestureKind.none;
    }
    final double vx = velocity.pixelsPerSecond.dx;
    final double vy = velocity.pixelsPerSecond.dy;
    CustomDismissDirection flingDirection;
    // Verify that the fling is in the generally right direction and fast enough.
    if (_directionIsXAxis) {
      if (vx.abs() - vy.abs() < _kMinFlingVelocityDelta || vx.abs() < _kMinFlingVelocity) return _FlingGestureKind.none;
      assert(vx != 0);
      flingDirection = _extentToDirection(vx);
    } else {
      if (vy.abs() - vx.abs() < _kMinFlingVelocityDelta || vy.abs() < _kMinFlingVelocity) return _FlingGestureKind.none;
      assert(vy != 0);
      flingDirection = _extentToDirection(vy);
    }
    assert(_dismissDirection != null);
    if (flingDirection == _dismissDirection) return _FlingGestureKind.forward;
    return _FlingGestureKind.reverse;
  }

  Future<void> _handleDragEnd(DragEndDetails details) async {
    _dragBack = 0;
    if (!_isActive || _moveController!.isAnimating) return;
    _dragUnderway = false;
    if (_moveController!.isCompleted && await _confirmStartResizeAnimation() == true) {
      _startResizeAnimation();
      return;
    }
    final double flingVelocity =
        _directionIsXAxis ? details.velocity.pixelsPerSecond.dx : details.velocity.pixelsPerSecond.dy;
    switch (_describeFlingGesture(details.velocity)) {
      case _FlingGestureKind.forward:
        assert(_dragExtent != 0);
        assert(!_moveController!.isDismissed);
        if ((widget.dismissThresholds[_dismissDirection] ?? _kDismissThreshold) >= 1.0) {
          _moveController!.reverse();
          break;
        }
        _dragExtent = flingVelocity.sign;
        _moveController!.fling(velocity: flingVelocity.abs() * _kFlingVelocityScale);
        break;
      case _FlingGestureKind.reverse:
        assert(_dragExtent != 0);
        assert(!_moveController!.isDismissed);
        _dragExtent = flingVelocity.sign;
        _moveController!.fling(velocity: -flingVelocity.abs() * _kFlingVelocityScale);
        break;
      case _FlingGestureKind.none:
        if (!_moveController!.isDismissed) {
          // we already know it's not completed, we check that above
          if (_moveController!.value > (widget.dismissThresholds[_dismissDirection] ?? _kDismissThreshold)) {
            _moveController!.forward();
          } else {
            _moveController!.reverse();
          }
        }
        break;
    }
  }

  Future<void> _handleDismissStatusChanged(AnimationStatus status) async {
    if (status == AnimationStatus.completed && !_dragUnderway) {
      if (await _confirmStartResizeAnimation() == true) {
        _startResizeAnimation();
      } else {
        _moveController!.reverse();
      }
    }
    updateKeepAlive();
  }

  Future<bool?> _confirmStartResizeAnimation() async {
    if (widget.confirmDismiss != null) {
      final CustomDismissDirection direction = _dismissDirection;
      return widget.confirmDismiss!(direction);
    }
    return true;
  }

  void _startResizeAnimation() {
    assert(_moveController != null);
    assert(_moveController!.isCompleted);
    assert(_resizeController == null);
    assert(_sizePriorToCollapse == null);
    if (widget.resizeDuration == null) {
      if (widget.onDismissed != null) {
        final CustomDismissDirection direction = _dismissDirection;
        widget.onDismissed!(direction);
      }
    } else {
      _resizeController = AnimationController(duration: widget.resizeDuration, vsync: this)
        ..addListener(_handleResizeProgressChanged)
        ..addStatusListener((AnimationStatus status) => updateKeepAlive());
      _resizeController!.forward();
      setState(() {
        _sizePriorToCollapse = context.size;
        _resizeAnimation =
            _resizeController!.drive(CurveTween(curve: _kResizeTimeCurve)).drive(Tween<double>(begin: 1, end: 0));
      });
    }
  }

  void _handleResizeProgressChanged() {
    if (_resizeController!.isCompleted) {
      if (widget.onDismissed != null) {
        final CustomDismissDirection direction = _dismissDirection;
        widget.onDismissed!(direction);
      }
    } else {
      if (widget.onResize != null) widget.onResize!();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.

    assert(!_directionIsXAxis || debugCheckHasDirectionality(context));

    Widget? background = widget.background;
    if (widget.secondaryBackground != null) {
      final CustomDismissDirection direction = _dismissDirection;
      if (direction == CustomDismissDirection.endToStart || direction == CustomDismissDirection.up) {
        background = widget.secondaryBackground;
      }
    }

    if (_resizeAnimation != null) {
      // we've been dragged aside, and are now resizing.
      assert(() {
        if (_resizeAnimation!.status != AnimationStatus.forward) {
          assert(_resizeAnimation!.status == AnimationStatus.completed);
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('A dismissed SwipeBackDismissible widget is still part of the tree.'),
            ErrorHint(
                'Make sure to implement the onDismissed handler and to immediately remove the SwipeBackDismissible '
                'widget from the application once that handler has fired.')
          ]);
        }
        return true;
      }());

      return SizeTransition(
        sizeFactor: _resizeAnimation!,
        axis: _directionIsXAxis ? Axis.vertical : Axis.horizontal,
        child: SizedBox(
          width: _sizePriorToCollapse!.width,
          height: _sizePriorToCollapse!.height,
          child: background,
        ),
      );
    }

    Widget content = SlideTransition(
      position: _moveAnimation,
      child: widget.child,
    );

    if (background != null) {
      content = Stack(children: <Widget>[
        if (!_moveAnimation.isDismissed)
          Positioned.fill(
            child: ClipRect(
              clipper: _DismissibleClipper(
                axis: _directionIsXAxis ? Axis.horizontal : Axis.vertical,
                moveAnimation: _moveAnimation,
              ),
              child: background,
            ),
          ),
        content,
      ]);
    }
    // We are not resizing but we may be being dragging in widget.direction.
    return GestureDetector(
      onHorizontalDragStart: _directionIsXAxis ? _handleDragStart : null,
      onHorizontalDragUpdate: _directionIsXAxis ? _handleDragUpdate : null,
      onHorizontalDragEnd: _directionIsXAxis ? _handleDragEnd : null,
      onVerticalDragStart: _directionIsXAxis ? null : _handleDragStart,
      onVerticalDragUpdate: _directionIsXAxis ? null : _handleDragUpdate,
      onVerticalDragEnd: _directionIsXAxis ? null : _handleDragEnd,
      behavior: widget.behavior,
      dragStartBehavior: widget.dragStartBehavior,
      child: content,
    );
  }
}