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
  final bool persistentOnLarge;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    required this.drawerContent,
    this.sidePanelWidth = 280,
    this.breakpoint = 1024,
    this.persistentOnLarge = true,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool isLarge = width >= breakpoint;

    if (isLarge && persistentOnLarge) {
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        child: body,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // Small screens: standard drawer behavior
    return Scaffold(
      appBar: appBar,
      drawer: Drawer(
        width: sidePanelWidth,
        backgroundColor: Theme.of(context).drawerTheme.backgroundColor ??
            Theme.of(context).colorScheme.surface,
        child: drawerContent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: body,
              ),
            ),
          );
        },
      ),
    );
  }
}
