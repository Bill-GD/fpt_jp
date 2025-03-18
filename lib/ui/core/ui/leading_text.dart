import 'package:flutter/material.dart';

class LeadingText extends StatelessWidget {
  final String text;
  final bool bold;
  final double size;

  const LeadingText(
    this.text, {
    super.key,
    this.bold = true,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
