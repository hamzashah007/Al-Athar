import 'package:flutter/material.dart';

enum ButtonType { elevated, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final double? width;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.elevated,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.width,
  }) : super(key: key);

  const CustomButton.elevated({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.width,
  }) : type = ButtonType.elevated,
       super(key: key);

  const CustomButton.outlined({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.width,
  }) : type = ButtonType.outlined,
       super(key: key);

  const CustomButton.text({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.width,
  }) : type = ButtonType.text,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    Widget buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: type == ButtonType.elevated
                  ? (foregroundColor ?? (isDark ? Colors.black : Colors.white))
                  : (foregroundColor ?? colorScheme.primary),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(
                text,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: type == ButtonType.elevated
                      ? (foregroundColor ??
                            (isDark ? Colors.black : Colors.white))
                      : (foregroundColor ?? colorScheme.primary),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );

    Widget button;
    switch (type) {
      case ButtonType.elevated:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: effectivePadding,
            shape: shape,
            backgroundColor: backgroundColor ?? colorScheme.primary,
            disabledBackgroundColor: (backgroundColor ?? colorScheme.primary)
                .withOpacity(0.7),
          ),
          child: buttonChild,
        );
        break;
      case ButtonType.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: effectivePadding,
            side: BorderSide(
              color: foregroundColor ?? colorScheme.primary,
              width: 2,
            ),
            shape: shape,
          ),
          child: buttonChild,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(padding: effectivePadding, shape: shape),
          child: buttonChild,
        );
        break;
    }

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}
