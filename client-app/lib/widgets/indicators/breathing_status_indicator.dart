import 'package:flutter/material.dart';
import 'package:plan_sync/controllers/remote_config_controller.dart';
import 'package:provider/provider.dart';

class BreathingStatusIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const BreathingStatusIndicator({
    super.key,
    required this.color,
    this.size = 12,
  });

  @override
  State<BreathingStatusIndicator> createState() =>
      _BreathingStatusIndicatorState();
}

// TODO: Remove this temporary easter egg
// ( The Sigma Male Loading Indicator )
// * Change [TickerProviderStateMixin] to [SingleTickerProviderStateMixin] *
class _BreathingStatusIndicatorState extends State<BreathingStatusIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  late AnimationController _sigmaController;
  late Animation<double> _sigmaAnimation;

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

    // TODO: Remove this temporary easter egg
    // ( The Sigma Male Loading Indicator )

    _sigmaController = AnimationController(
      duration: const Duration(seconds: 50),
      vsync: this,
    )..repeat(reverse: true);

    _sigmaAnimation = Tween<double>(begin: 0, end: 360).animate(
      CurvedAnimation(
        parent: _sigmaController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _sigmaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<RemoteConfigController>(context, listen: false);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          // TODO: Remove this temporary easter egg
          // ( The Sigma Male Loading Indicator )
          scale: config.canShowSigmaEmoji() ? 1 : _animation.value,
          child: config.canShowSigmaEmoji()
              ? Transform.rotate(
                  angle: _sigmaAnimation.value,
                  child: const Text(
                    "🗿",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                )
              : AnimatedContainer(
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
