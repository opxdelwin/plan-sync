import 'package:flutter/material.dart';

class BreathingStatusIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const BreathingStatusIndicator({
    Key? key,
    required this.color,
    this.size = 12,
  }) : super(key: key);

  @override
  _BreathingStatusIndicatorState createState() =>
      _BreathingStatusIndicatorState();
}

class _BreathingStatusIndicatorState extends State<BreathingStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCirc,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.32),
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
