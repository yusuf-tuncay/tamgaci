import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps the entire app to enable keyboard-based scrolling (arrow keys, PgUp/PgDn)
/// whenever a vertical scrollable is present and no text input is focused.
class KeyboardScrollWrapper extends StatefulWidget {
  const KeyboardScrollWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<KeyboardScrollWrapper> createState() => _KeyboardScrollWrapperState();
}

class _KeyboardScrollWrapperState extends State<KeyboardScrollWrapper> {
  ScrollPosition? _lastVerticalPosition;

  static const Duration _animationDuration = Duration(milliseconds: 180);
  static const Curve _animationCurve = Curves.easeOutCubic;
  static const double _lineScrollDelta = 240;
  static const double _pageScrollFactor = 0.8;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (_lastVerticalPosition == null) return false;
    if (_isTextFieldFocused()) return false;

    double? targetOffset;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      targetOffset = _lastVerticalPosition!.pixels + _lineScrollDelta;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      targetOffset = _lastVerticalPosition!.pixels - _lineScrollDelta;
    } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      targetOffset =
          _lastVerticalPosition!.pixels + _pageExtent * _pageScrollFactor;
    } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      targetOffset =
          _lastVerticalPosition!.pixels - _pageExtent * _pageScrollFactor;
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      targetOffset = _lastVerticalPosition!.minScrollExtent;
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      targetOffset = _lastVerticalPosition!.maxScrollExtent;
    }

    if (targetOffset == null) return false;
    final notificationContext =
        _lastVerticalPosition!.context.notificationContext;
    if (!_lastVerticalPosition!.hasPixels ||
        notificationContext == null ||
        !notificationContext.mounted) {
      return false;
    }

    final clamped = targetOffset.clamp(
      _lastVerticalPosition!.minScrollExtent,
      _lastVerticalPosition!.maxScrollExtent,
    );

    _lastVerticalPosition!.animateTo(
      clamped,
      duration: _animationDuration,
      curve: _animationCurve,
    );
    return true;
  }

  double get _pageExtent =>
      _lastVerticalPosition?.viewportDimension ?? _lineScrollDelta;

  bool _isTextFieldFocused() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null) return false;
    return focus.context?.widget is EditableText;
  }

  bool _onScrollNotification(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) return false;
    final notificationContext = notification.context;
    if (notificationContext == null) return false;
    final scrollable = Scrollable.maybeOf(notificationContext);
    if (scrollable != null) {
      _lastVerticalPosition = scrollable.position;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: widget.child,
    );
  }
}
