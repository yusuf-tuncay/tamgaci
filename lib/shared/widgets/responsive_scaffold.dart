import 'package:flutter/material.dart';

/// Responsive scaffold that keeps the drawer persistently visible on large screens
/// and uses a standard drawer on small screens. It also constrains content width
/// to avoid unlimited stretching on desktop/web.
class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget drawerContent;
  final double sidePanelWidth;
  final double breakpoint;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    required this.drawerContent,
    this.sidePanelWidth = 280,
    this.breakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool isLarge = width >= breakpoint;

    if (isLarge) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: sidePanelWidth,
              child: drawerContent,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: body,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Small screens: standard drawer behavior
    return Scaffold(
      appBar: appBar,
      drawer: Drawer(child: drawerContent),
      body: body,
    );
  }
}
