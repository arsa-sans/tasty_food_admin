import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final num value;
  final TextStyle? textStyle;
  final Duration duration;
  final Curve curve;
  final String prefix;
  final String suffix;
  final int decimalDigits;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.textStyle,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOutCubic,
    this.prefix = '',
    this.suffix = '',
    this.decimalDigits = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        final formatted = decimalDigits == 0
            ? animatedValue.round().toString()
            : animatedValue.toStringAsFixed(decimalDigits);

        return Text(
          '$prefix$formatted$suffix',
          style: textStyle,
        );
      },
    );
  }
}
