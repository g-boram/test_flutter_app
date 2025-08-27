import 'package:flutter/material.dart';

class WPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const WPrimaryButton({super.key, required this.label, this.onPressed});
  @override
  Widget build(BuildContext context) =>
      FilledButton(onPressed: onPressed, child: Text(label));
}
