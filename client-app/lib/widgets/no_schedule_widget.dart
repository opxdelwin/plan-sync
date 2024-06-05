import 'package:flutter/material.dart';

class NoScheduleWidget extends StatelessWidget {
  const NoScheduleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.view_timeline_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 32),
          Text(
            "Nothing found, must be an off day :)",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          )
        ],
      ),
    );
  }
}
