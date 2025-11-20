import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool isShaking;
  final double intensity; // New parameter

  const ShakeWidget({
    super.key,
    required this.child,
    required this.isShaking,
    this.intensity = 1.0, // Default standard shake
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    // Base shake is -5 to 5 pixels
    _offsetAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_controller);

    if (widget.isShaking) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      _controller.repeat(reverse: true);
    } else if (!widget.isShaking && oldWidget.isShaking) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        // Multiply the base offset by the intensity
        final offset = widget.isShaking
            ? _offsetAnimation.value * widget.intensity
            : 0.0;

        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: widget.child,
    );
  }
}
