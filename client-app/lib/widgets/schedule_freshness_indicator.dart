import 'package:flutter/material.dart';
import 'package:plan_sync/widgets/breathing_status_indicator.dart';

/// Wrapper of BreathingStatusIndicator
class ScheduleFreshnessIndicator extends StatelessWidget {
  const ScheduleFreshnessIndicator({
    super.key,
    required this.isFresh,
  });
  final bool isFresh;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isFresh ? 0 : 1,
      duration: const Duration(seconds: 1, milliseconds: 500),
      curve: Curves.easeInOutExpo,
      child: BreathingStatusIndicator(
        color: isFresh ? Colors.green : Colors.red,
      ),
    );
  }
}
