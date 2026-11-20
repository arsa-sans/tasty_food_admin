import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'animated_pressable.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 46.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? AppColors.primary : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isOutlined
                      ? (textColor ?? AppColors.textPrimary)
                      : (textColor ?? Colors.white),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          );

    final buttonDecoration = isOutlined
        ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: backgroundColor ?? AppColors.border,
              width: 1.2,
            ),
          )
        : BoxDecoration(
            color: onPressed == null || isLoading
                ? (backgroundColor ?? AppColors.primary).withValues(alpha: 0.5)
                : (backgroundColor ?? AppColors.primary),
            borderRadius: BorderRadius.circular(12),
            boxShadow: onPressed != null && !isLoading && !isOutlined
                ? [
                    BoxShadow(
                      color: (backgroundColor ?? AppColors.primary).withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          );

    return AnimatedPressable(
      onTap: isLoading ? null : onPressed,
      pressedScale: 0.97,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: buttonDecoration,
        child: effectiveChild,
      ),
    );
  }
}
