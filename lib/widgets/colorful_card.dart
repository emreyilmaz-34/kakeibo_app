import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'animations/spring_animation.dart';

class ColorfulCard extends StatefulWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final int? colorIndex;
  final bool animated;

  const ColorfulCard({
    super.key,
    required this.child,
    this.gradient,
    this.color,
    this.padding,
    this.margin,
    this.onTap,
    this.colorIndex,
    this.animated = true,
  });

  @override
  State<ColorfulCard> createState() => _ColorfulCardState();
}

class _ColorfulCardState extends State<ColorfulCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = widget.gradient ??
        (widget.colorIndex != null
            ? AppTheme.getCategoryGradient(widget.colorIndex!)
            : AppTheme.primaryGradient);

    Widget cardContent = Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: isDark ? null : gradient,
        color: isDark
            ? (widget.color ?? Theme.of(context).cardTheme.color)
            : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark
                    ? Colors.black.withOpacity(0.3)
                    : (gradient.colors.first).withOpacity(0.3))
                .withOpacity(_isPressed ? 0.2 : 0.3),
            blurRadius: _isPressed ? 15 : 25,
            offset: Offset(0, _isPressed ? 4 : 10),
            spreadRadius: _isPressed ? 0 : 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: widget.onTap != null ? _handleTapDown : null,
          onTapUp: widget.onTap != null ? _handleTapUp : null,
          onTapCancel: widget.onTap != null ? _handleTapCancel : null,
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(20),
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.animated) {
      cardContent = SpringAnimation(
        delay: const Duration(milliseconds: 100),
        child: cardContent,
      );
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: cardContent,
        );
      },
    );
  }
}
