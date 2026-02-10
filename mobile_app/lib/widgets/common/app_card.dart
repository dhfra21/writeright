// Common reusable card widget
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;

  const AppCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement app card styling
    return Card(child: child);
  }
}
