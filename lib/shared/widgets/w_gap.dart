import 'package:flutter/widgets.dart';
class WGap extends StatelessWidget {
  final double h, w;
  const WGap.h(this.h, {super.key}) : w = 0;
  const WGap.w(this.w, {super.key}) : h = 0;
  @override
  Widget build(BuildContext context) => SizedBox(height: h, width: w);
}
