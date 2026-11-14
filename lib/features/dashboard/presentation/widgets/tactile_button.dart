import 'package:material_ui/material_ui.dart';

import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';

enum TactileColor { lime, cyan, lavender, amber, surface }

/// A playful Duolingo-inspired 3D tactile button with physical push depth.
class TactileButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final TactileColor color;
  final Widget? icon;
  final double? width;
  final double height;
  final double fontSize;
  final bool fullWidth;

  const TactileButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = TactileColor.lime,
    this.icon,
    this.width,
    this.height = 44,
    this.fontSize = 13,
    this.fullWidth = false,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _isPressed = false;

  Color get _faceColor {
    switch (widget.color) {
      case TactileColor.lime:
        return AppColor.lime;
      case TactileColor.cyan:
        return AppColor.cyan;
      case TactileColor.lavender:
        return AppColor.lavender;
      case TactileColor.amber:
        return AppColor.amber;
      case TactileColor.surface:
        return AppColor.surfaceLight;
    }
  }

  Color get _bottomColor {
    switch (widget.color) {
      case TactileColor.lime:
        return AppColor.limeDark;
      case TactileColor.cyan:
        return AppColor.cyanDark;
      case TactileColor.lavender:
        return AppColor.lavenderDark;
      case TactileColor.amber:
        return AppColor.amberDark;
      case TactileColor.surface:
        return AppColor.surface;
    }
  }

  Color get _textColor {
    switch (widget.color) {
      case TactileColor.surface:
        return AppColor.textPrimary;
      default:
        return AppColor.background;
    }
  }

  @override
  Widget build(BuildContext context) {
    const depth = AppTactile.depthMd;
    final topOffset = _isPressed ? depth : 0.0;

    Widget buttonContent = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        margin: EdgeInsets.only(top: topOffset, bottom: depth - topOffset),
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: _faceColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: _bottomColor,
                offset: const Offset(0, depth),
                blurRadius: 0,
              ),
          ],
        ),
        child: Row(
          mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              widget.label,
              style: TextStyle(
                color: _textColor,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.width != null) {
      return SizedBox(width: widget.width, child: buttonContent);
    }

    if (widget.fullWidth) {
      return SizedBox(width: double.infinity, child: buttonContent);
    }

    return buttonContent;
  }
}
