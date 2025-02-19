import 'package:flutter/material.dart';

/// A badge with accent color as background
class Badge extends StatelessWidget {
  final Widget child;
  final BorderRadiusGeometry borderRadius;

  const Badge({
    @required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 25,
      decoration: BoxDecoration(
        color: theme.accentColor,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: child,
      ),
    );
  }
}
