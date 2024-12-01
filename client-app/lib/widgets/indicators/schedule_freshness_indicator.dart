import 'package:flutter/material.dart';
import 'package:plan_sync/widgets/indicators/breathing_status_indicator.dart';

/// Wrapper of BreathingStatusIndicator
class ScheduleFreshnessIndicator extends StatefulWidget {
  const ScheduleFreshnessIndicator({
    super.key,
    required this.isFresh,
  });
  final bool isFresh;

  @override
  State<ScheduleFreshnessIndicator> createState() =>
      _ScheduleFreshnessIndicatorState();
}

class _ScheduleFreshnessIndicatorState
    extends State<ScheduleFreshnessIndicator> {
  /// this is required to remove [BreathingStatusIndicator]
  /// from the widget tree.
  bool showIndicator = true;

  @override
  Widget build(BuildContext context) {
    if (widget.isFresh && showIndicator) {
      // Remove after 2s, as opacity animation
      // is 1.5s
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;

        setState(() {
          showIndicator = false;
        });
      });
    }
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedOpacity(
      opacity: widget.isFresh ? 0 : 1,
      duration: const Duration(seconds: 1, milliseconds: 500),
      curve: Curves.easeInOutExpo,
      child: showIndicator
          ? BreathingStatusIndicator(
              key: ValueKey('BreathingStatusIndicator:${widget.isFresh}'),
              color: widget.isFresh ? colorScheme.primary : colorScheme.error,
            )
          : const SizedBox(),
    );
  }
}
