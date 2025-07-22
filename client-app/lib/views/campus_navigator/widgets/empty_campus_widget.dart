import 'package:flutter/material.dart';

class EmptyCampusWidget extends StatelessWidget {
  const EmptyCampusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 48, color: colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'No campus locations found.',
            style: TextStyle(
              color: colorScheme.outline,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
