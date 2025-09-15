import 'package:flutter/material.dart';

/// Floating action button widget
class FabWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? tooltip;
  final IconData? icon;

  const FabWidget({
    super.key,
    this.onPressed,
    this.tooltip,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon ?? Icons.add),
    );
  }
}
