import 'package:flutter/material.dart';
import '../widgets/draggable_calculator.dart';

/// Floating calculator overlay controller
class CalculatorOverlay {
  CalculatorOverlay._internal();
  static final CalculatorOverlay instance = CalculatorOverlay._internal();

  OverlayEntry? _entry;
  Offset _position = const Offset(60, 80);

  bool get isShowing => _entry != null;

  void show(BuildContext context) {
    if (_entry != null) return;

    final overlay = Navigator.of(context, rootNavigator: true).overlay;
    if (overlay == null) return;

    _entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: _position.dx,
          top: _position.dy,
          child: _FloatingDraggable(
            initialPosition: _position,
            onPositionChanged: (pos) {
              _position = pos;
              _entry?.markNeedsBuild();
            },
            child: const DraggableCalculator(),
          ),
        );
      },
    );

    overlay.insert(_entry!);
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }

  void toggle(BuildContext context) {
    if (isShowing) {
      hide();
    } else {
      show(context);
    }
  }
}

/// Wrapper that allows dragging the calculator by grabbing anywhere
class _FloatingDraggable extends StatefulWidget {
  const _FloatingDraggable({
    required this.initialPosition,
    required this.onPositionChanged,
    required this.child,
  });

  final Offset initialPosition;
  final ValueChanged<Offset> onPositionChanged;
  final Widget child;

  @override
  State<_FloatingDraggable> createState() => _FloatingDraggableState();
}

class _FloatingDraggableState extends State<_FloatingDraggable> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (event) {
        setState(() {
          _position = Offset(
              _position.dx + event.delta.dx, _position.dy + event.delta.dy);
        });
        widget.onPositionChanged(_position);
      },
      child: widget.child,
    );
  }
}
