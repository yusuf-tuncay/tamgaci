import 'package:flutter/material.dart';

/// Layout hatalarını önlemek için güvenli widget wrapper
class SafeLayoutWrapper extends StatelessWidget {
  final Widget child;
  final bool enableSafeArea;
  final EdgeInsets? padding;

  const SafeLayoutWrapper({
    super.key,
    required this.child,
    this.enableSafeArea = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Layout constraints kontrolü
        if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
          return const SizedBox.shrink();
        }

        Widget wrappedChild = child;

        // SafeArea wrapper
        if (enableSafeArea) {
          wrappedChild = SafeArea(child: wrappedChild);
        }

        // Padding wrapper
        if (padding != null) {
          wrappedChild = Padding(
            padding: padding!,
            child: wrappedChild,
          );
        }

        // RepaintBoundary wrapper - layout hatalarını önler
        return RepaintBoundary(
          child: wrappedChild,
        );
      },
    );
  }
}

/// Layout hatalarını önlemek için güvenli container
class SafeContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;

  const SafeContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.width,
    this.height,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return SafeLayoutWrapper(
      child: Container(
        padding: padding,
        margin: margin,
        color: color,
        width: width,
        height: height,
        decoration: decoration,
        child: child,
      ),
    );
  }
}

/// Layout hatalarını önlemek için güvenli column
class SafeColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const SafeColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return SafeLayoutWrapper(
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      ),
    );
  }
}

/// Layout hatalarını önlemek için güvenli row
class SafeRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const SafeRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return SafeLayoutWrapper(
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      ),
    );
  }
}

/// Layout hatalarını önlemek için güvenli flex
class SafeFlex extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const SafeFlex({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return SafeLayoutWrapper(
      child: Flex(
        direction: direction,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      ),
    );
  }
}
